# -*- encoding: utf-8 -*-
class Item < ActiveRecord::Base
  scope :for_checkout, :conditions => ['item_identifier IS NOT NULL']
  scope :not_for_checkout, where(:item_identifier => nil)
  scope :on_shelf, :conditions => ['shelf_id != 1']
  scope :on_web, where(:shelf_id => 1)
  #belongs_to :manifestation, :class_name => 'Manifestation'
  has_one :exemplify
  has_one :manifestation, :through => :exemplify
  has_many :checkouts
  has_many :reserves
  has_many :reserved_patrons, :through => :reserves, :class_name => 'Patron'
  has_many :owns
  has_many :patrons, :through => :owns
  belongs_to :shelf, :counter_cache => true, :validate => true
  delegate :display_name, :to => :shelf, :prefix => true
  has_many :checked_items, :dependent => :destroy
  has_many :baskets, :through => :checked_items
  belongs_to :circulation_status, :validate => true
  belongs_to :bookstore, :validate => true
  has_many :donates
  has_many :donors, :through => :donates, :source => :patron
  has_many :item_has_use_restrictions, :dependent => :destroy
  has_many :use_restrictions, :through => :item_has_use_restrictions
  has_many :reserves
  has_many :inter_library_loans, :dependent => :destroy
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  belongs_to :checkout_type
  #has_many :inventories, :dependent => :destroy
  #has_many :inventory_files, :through => :inventories
  has_many :lending_policies, :dependent => :destroy
  has_many :answer_has_items, :dependent => :destroy
  has_many :answers, :through => :answer_has_items
  has_one :resource_import_result

  validates_associated :circulation_status, :shelf, :bookstore, :checkout_type
  validates_presence_of :circulation_status, :checkout_type
  validates :item_identifier, :allow_blank => true, :uniqueness => {:if => proc{|item| !item.item_identifier.blank? and !item.manifestation.try(:series_statement)}}, :format => {:with => /\A\w+\Z/}
  validates :url, :url => true, :allow_blank => true, :length => {:maximum => 255}
  before_validation :set_circulation_status, :on => :create

  #enju_union_catalog
  has_paper_trail
  normalize_attributes :item_identifier

  searchable do
    text :item_identifier, :note, :title, :creator, :contributor, :publisher, :library
    string :item_identifier
    string :library
    integer :required_role_id
    integer :circulation_status_id
    integer :manifestation_id do
      manifestation.id if manifestation
    end
    integer :shelf_id
    integer :patron_ids, :multiple => true
    #integer :inventory_file_ids, :multiple => true
    time :created_at
    time :updated_at
  end

  attr_accessor :library_id, :manifestation_id

  def self.per_page
    10
  end

  def set_circulation_status
    self.circulation_status = CirculationStatus.first(:conditions => {:name => 'In Process'}) if self.circulation_status.nil?
  end

  def checkout_status(user)
    user.user_group.user_group_has_checkout_types.find_by_checkout_type_id(self.checkout_type.id)
  end

  def next_reservation
    Reserve.waiting.where(:manifestation_id => self.manifestation.id).first
  end

  def reserved?
    return true if self.next_reservation
    false
  end

  def reservable?
    return false if ['Lost', 'Missing', 'Claimed Returned Or Never Borrowed'].include?(self.circulation_status.name)
    return false if self.item_identifier.blank?
    true
  end

  def rent?
    return true if self.checkouts.not_returned.detect{|checkout| checkout.item_id == self.id}
    false
  end

  def reserved_by_user?(user)
    if self.next_reservation
      return true if self.next_reservation.user == user
    end
    false
  end

  def available_for_checkout?
    circulation_statuses = CirculationStatus.available_for_checkout
    return true if circulation_statuses.include?(self.circulation_status)
    false
  end

  def checkout!(user)
    self.circulation_status = CirculationStatus.where(:name => 'On Loan').first
    if self.reserved_by_user?(user)
      self.next_reservation.update_attributes(:checked_out_at => Time.zone.now)
      self.next_reservation.sm_complete!
    end
    save!
  end

  def checkin!
    self.circulation_status = CirculationStatus.where(:name => 'Available On Shelf').first
    save(:validate => false)
  end

  def retain(librarian)
    Item.transaction do
      reservation = self.manifestation.next_reservation
      unless reservation.nil?
        reservation.item = self
        reservation.sm_retain!
        reservation.update_attributes({:request_status_type => RequestStatusType.find_by_name('In Process')})
        request = MessageRequest.new(:sender_id => librarian.id, :receiver_id => reservation.user_id)
        message_template = MessageTemplate.localized_template('item_received', reservation.user.locale)
        request.message_template = message_template
        request.save!
      end
    end
  end

  def inter_library_loaned?
    true if self.inter_library_loans.size > 0
  end

  def title
    manifestation.try(:original_title)
  end

  def creator
    manifestation.try(:creator)
  end

  def contributor
    manifestation.try(:contributor)
  end

  def publisher
    manifestation.try(:publisher)
  end

  def library
    shelf.library.name if shelf
  end

  def shelf_name
    shelf.name
  end

  def hold?(library)
    return true if self.shelf.library == library
    false
  end

  #def self.inventory_items(inventory_file, mode = 'not_on_shelf')
  #  item_ids = Item.all(:select => :id).collect(&:id)
  #  inventory_item_ids = inventory_file.items.all(:select => ['items.id']).collect(&:id)
  #  case mode
  #  when 'not_on_shelf'
  #    Item.find(item_ids - inventory_item_ids)
  #  when 'not_in_catalog'
  #    Item.find(inventory_item_ids - item_ids)
  #  end
  #rescue
  #  nil
  #end

  def lending_rule(user)
    lending_policies.first(:conditions => {:user_group_id => user.user_group.id})
  end

  def owned(patron)
    owns.first(:conditions => {:patron_id => patron.id})
  end

  def library_url
    "#{LibraryGroup.site_config.url}libraries/#{self.shelf.library.name}"
  end

  def manifestation_url
    Addressable::URI.parse("#{LibraryGroup.site_config.url}manifestations/#{self.manifestation.id}").normalize.to_s if self.manifestation
  end

  #def create_lending_policy
  #  UserGroupHasCheckoutType.available_for_carrier_type(manifestation.carrier_type).each do |rule|
  #    LendingPolicy.create(:item_id => self.id, :user_group_id => rule.user_group_id, :fixed_due_date => rule.fixed_due_date, :loan_period => rule.checkout_period, :renewal => rule.checkout_renewal_limit)
  #  end
  #end

  def deletable?
    checkouts.not_returned.first.nil?
  end
end
