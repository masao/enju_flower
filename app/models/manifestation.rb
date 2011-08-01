class Manifestation < ActiveRecord::Base
  scope :periodical_master, where(:periodical_master => true)
  scope :periodical_children, where(:periodical_master => false)
  has_many :creates, :dependent => :destroy, :foreign_key => 'work_id'
  has_many :creators, :through => :creates, :source => :patron
  has_many :realizes, :dependent => :destroy, :foreign_key => 'expression_id'
  has_many :contributors, :through => :realizes, :source => :patron
  has_many :produces, :dependent => :destroy, :foreign_key => 'manifestation_id'
  has_many :publishers, :through => :produces, :source => :patron
  has_many :exemplifies, :foreign_key => 'manifestation_id'
  has_many :items, :through => :exemplifies #, :foreign_key => 'manifestation_id'
  has_many :children, :foreign_key => 'parent_id', :class_name => 'ManifestationRelationship', :dependent => :destroy
  has_many :parents, :foreign_key => 'child_id', :class_name => 'ManifestationRelationship', :dependent => :destroy
  has_many :derived_manifestations, :through => :children, :source => :child
  has_many :original_manifestations, :through => :parents, :source => :parent
  has_many :work_has_subjects, :foreign_key => 'work_id', :dependent => :destroy
  has_many :subjects, :through => :work_has_subjects
  has_many :bookmarks, :include => :tags, :dependent => :destroy, :foreign_key => :manifestation_id
  has_many :users, :through => :bookmarks
  has_many :reserves, :foreign_key => :manifestation_id
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  belongs_to :language
  belongs_to :carrier_type
  belongs_to :content_type
  belongs_to :series_statement
  belongs_to :manifestation_relationship_type
  belongs_to :frequency
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_one :resource_import_result

  searchable do
    text :title, :default_boost => 2 do
      titles
    end
    text :fulltext, :note, :creator, :contributor, :publisher, :description
    text :subject do
      subjects.collect(&:term) + subjects.collect(&:term_transcription)
    end
    string :title, :multiple => true
    # text フィールドだと区切りのない文字列の index が上手く作成
    #できなかったので。 downcase することにした。
    #他の string 項目も同様の問題があるので、必要な項目は同様の処置が必要。
    string :connect_title do
      title.join('').gsub(/\s/, '').downcase
    end
    string :connect_creator do
      creator.join('').gsub(/\s/, '').downcase
    end
    string :connect_publisher do
      publisher.join('').gsub(/\s/, '').downcase
    end
    text :tag do
      tags.collect(&:name)
    end
    string :isbn, :multiple => true do
      [isbn, isbn10, wrong_isbn]
    end
    string :issn
    string :lccn
    string :nbn
    string :tag, :multiple => true do
      tags.collect(&:name)
    end
    string :subject, :multiple => true do
      subjects.collect(&:term) + subjects.collect(&:term_transcription)
    end
    string :classification, :multiple => true do
      classifications.collect(&:category)
    end
    string :carrier_type do
      carrier_type.name
    end
    string :library, :multiple => true do
      items.map{|i| i.shelf.library.name}
    end
    string :language do
      language.try(:name)
    end
    string :item_identifier, :multiple => true do
      items.collect(&:item_identifier)
    end
    string :shelf, :multiple => true do
      items.collect{|i| "#{i.shelf.library.name}_#{i.shelf.name}"}
    end
    string :user, :multiple => true do
    end
    time :created_at
    time :updated_at
    time :deleted_at
    time :date_of_publication
    integer :creator_ids, :multiple => true
    integer :contributor_ids, :multiple => true
    integer :publisher_ids, :multiple => true
    integer :item_ids, :multiple => true
    integer :original_manifestation_ids, :multiple => true
    integer :subject_ids, :multiple => true
    integer :required_role_id
    integer :height
    integer :width
    integer :depth
    integer :volume_number, :multiple => true
    integer :issue_number, :multiple => true
    integer :serial_number, :multiple => true
    integer :start_page
    integer :end_page
    integer :number_of_pages
    float :price
    boolean :reservable do
      self.reservable?
    end
    integer :series_statement_id
    boolean :repository_content
    # for OpenURL
    text :aulast do
      creators.map{|creator| creator.last_name}
    end
    text :aufirst do
      creators.map{|creator| creator.first_name}
    end
    # OTC start
    string :creator, :multiple => true do
      creator.map{|au| au.gsub(' ', '')}
    end
    text :au do
      creator
    end
    text :atitle do
      title if original_manifestations.present? # 親がいることが条件
    end
    text :btitle do
      title if frequency_id == 1  # 発行頻度1が単行本
    end
    text :jtitle do
      if frequency_id != 1  # 雑誌の場合
        title
      else                  # 雑誌以外（雑誌の記事も含む）
        titles = []
        original_manifestations.each do |m|
          if m.frequency_id != 1
            titles << m.title
          end
        end
        titles.flatten
      end
    end
    text :isbn do  # 前方一致検索のためtext指定を追加
      [isbn, isbn10, wrong_isbn]
    end
    text :issn  # 前方一致検索のためtext指定を追加
    text :ndl_jpno do
      # TODO 詳細不明
    end
    string :ndl_dpid do
      # TODO 詳細不明
    end
    # OTC end
    string :sort_title
    boolean :periodical do
      serial?
    end
    time :acquired_at do
      items.order(:acquired_at).last.try(:acquired_at)
    end
  end

  enju_manifestation_viewer
  enju_amazon
  enju_oai
  enju_mozshot
  #enju_calil_check
  #enju_cinii
  #has_ipaper_and_uses 'Paperclip'
  #enju_scribd
  has_paper_trail
  if configatron.uploaded_file.storage == :s3
    has_attached_file :attachment, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml"
  else
    has_attached_file :attachment
  end

  validates_presence_of :original_title, :carrier_type, :language
  validates_associated :carrier_type, :language
  validates :start_page, :numericality => true, :allow_blank => true
  validates :end_page, :numericality => true, :allow_blank => true
  validates :isbn, :uniqueness => true, :allow_blank => true, :unless => proc{|manifestation| manifestation.series_statement}
  validates :nbn, :uniqueness => true, :allow_blank => true
  validates :identifier, :uniqueness => true, :allow_blank => true
  validates :pub_date, :format => {:with => /^\d+(-\d{0,2}){0,2}$/}, :allow_blank => true
  validates :access_address, :url => true, :allow_blank => true, :length => {:maximum => 255}
  validate :check_isbn, :check_issn, :check_lccn, :unless => :during_import
  before_validation :set_wrong_isbn, :check_issn, :check_lccn, :if => :during_import
  before_validation :convert_isbn
  before_create :set_digest
  after_create :clear_cached_numdocs
  before_save :set_date_of_publication
  normalize_attributes :identifier, :pub_date, :isbn, :issn, :nbn, :lccn, :original_title
  attr_accessor :during_import
  attr_protected :periodical_master

  def self.per_page
    10
  end

  def check_isbn
    if isbn.present?
      unless ISBN_Tools.is_valid?(isbn)
        errors.add(:isbn)
      end
    end
  end

  def check_issn
    self.issn = ISBN_Tools.cleanup(issn)
    if issn.present?
      unless StdNum::ISSN.valid?(issn)
        errors.add(:issn)
      end
    end
  end

  def check_lccn
    if lccn.present?
      unless StdNum::LCCN.valid?(issn)
        errors.add(:issn)
      end
    end
  end

  def set_wrong_isbn
    if isbn.present?
      unless ISBN_Tools.is_valid?(isbn)
        self.wrong_isbn
        self.isbn = nil
      end
    end
  end

  def convert_isbn
    num = ISBN_Tools.cleanup(isbn) if isbn
    if num
      if num.length == 10
        self.isbn10 = num
        self.isbn = ISBN_Tools.isbn10_to_isbn13(num)
      elsif num.length == 13
        self.isbn10 = ISBN_Tools.isbn13_to_isbn10(num)
      end
    end
  end

  def set_date_of_publication
    return if pub_date.blank?
    begin
      date = Time.zone.parse("#{pub_date}")
    rescue ArgumentError
      begin
        date = Time.zone.parse("#{pub_date}-01")
      rescue ArgumentError
        begin
          date = Time.zone.parse("#{pub_date}-01-01")
        rescue ArgumentError
          nil
        end
      end
    end
    self.date_of_publication = date
  end

  def self.cached_numdocs
    Rails.cache.fetch("manifestation_search_total"){Manifestation.search.total}
  end

  def clear_cached_numdocs
    Rails.cache.delete("manifestation_search_total")
  end

  def parent_of_series
    original_manifestations
  end

  def next_reservation
    self.reserves.waiting.order('reserves.created_at ASC').first
  end

  def serial?
    if series_statement.try(:periodical) and !periodical_master
      return true unless  series_statement.initial_manifestation == self
    end
    false
  end

  def number_of_pages
    if self.start_page and self.end_page
      page = self.end_page.to_i - self.start_page.to_i + 1
    end
  end

  def tags
    if self.bookmarks.first
      self.bookmarks.tag_counts
    else
      []
    end
  end

  def titles
    title = []
    title << original_title.to_s.strip
    title << title_transcription.to_s.strip
    title << title_alternative.to_s.strip
    #title << original_title.wakati
    #title << title_transcription.wakati rescue nil
    #title << title_alternative.wakati rescue nil
    title
  end

  def url
    #access_address
    "#{LibraryGroup.site_config.url}#{self.class.to_s.tableize}/#{self.id}"
  end

  def available_checkout_types(user)
    if user
      user.user_group.user_group_has_checkout_types.available_for_carrier_type(self.carrier_type)
    end
  end

  def checkout_period(user)
    if available_checkout_types(user)
      available_checkout_types(user).collect(&:checkout_period).max || 0
    end
  end

  def reservation_expired_period(user)
    if available_checkout_types(user)
      available_checkout_types(user).collect(&:reservation_expired_period).max || 0
    end
  end

  def patrons
    (creators + contributors + publishers).flatten
  end

  def bookmarked?(user)
    self.users.include?(user)
  end

  def set_serial_number
    if m = series_statement.try(:last_issue)
      self.original_title = m.original_title
      self.title_transcription = m.title_transcription
      self.title_alternative = m.title_alternative
      self.issn = m.issn
      unless m.serial_number_list.blank?
        self.serial_number_list = m.serial_number_list.to_i + 1
        unless m.issue_number_list.blank?
          self.issue_number_list = m.issue_number_list.split.last.to_i + 1
        else
          self.issue_number_list = m.issue_number_list
        end
        self.volume_number_list = m.volume_number_list
      else
        unless m.issue_number_list.blank?
          self.issue_number_list = m.issue_number_list.split.last.to_i + 1
          self.volume_number_list = m.volume_number_list
        else
          unless m.volume_number_list.blank?
            self.volume_number_list = m.volume_number_list.split.last.to_i + 1
          end
        end
      end
    end
    self
  end

  def reservable?
    return false if items.for_checkout.empty?
    true
  end

  def is_reserved_by(user = nil)
    if user
      Reserve.waiting.where(:user_id => user.id, :manifestation_id => self.id).first
    else
      false
    end
  end

  def is_reserved?
    if self.reserves.present?
      true
    else
      false
    end
  end

  def checkouts(start_date, end_date)
    Checkout.completed(start_date, end_date).where(:item_id => self.items.collect(&:id))
  end

  def creator
    creators.collect(&:name).flatten
  end

  def contributor
    contributors.collect(&:name).flatten
  end

  def publisher
    publishers.collect(&:name).flatten
  end

  def title
    titles
  end

  def hyphenated_isbn
    ISBN_Tools.hyphenate(isbn)
  end

  # TODO: よりよい推薦方法
  def self.pickup(keyword = nil)
    return nil if self.cached_numdocs < 5
    manifestation = nil
    # TODO: ヒット件数が0件のキーワードがあるときに指摘する
    response = Manifestation.search(:include => [:creators, :contributors, :publishers, :subjects, :items]) do
      fulltext keyword if keyword
      order_by(:random)
      paginate :page => 1, :per_page => 1
    end
    manifestation = response.results.first
  end

  def set_digest(options = {:type => 'sha1'})
    if attachment.queued_for_write[:original]
      if File.exists?(attachment.queued_for_write[:original])
        self.file_hash = Digest::SHA1.hexdigest(File.open(attachment.queued_for_write[:original].path, 'rb').read)
      end
    end
  end

  def extract_text
    extractor = ExtractContent::Extractor.new
    text = Tempfile::new("text")
    case self.attachment_content_type
    when "application/pdf"
      system("pdftotext -q -enc UTF-8 -raw #{attachment(:path)} #{text.path}")
      self.fulltext = text.read
    when "application/msword"
      system("antiword #{attachment(:path)} 2> /dev/null > #{text.path}")
      self.fulltext = text.read
    when "application/vnd.ms-excel"
      system("xlhtml #{attachment(:path)} 2> /dev/null > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    when "application/vnd.ms-powerpoint"
      system("ppthtml #{attachment(:path)} 2> /dev/null > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    when "text/html"
      # TODO: 日本語以外
      system("w3m -dump #{attachment(:path)} 2> /dev/null | nkf -w > #{text.path}")
      self.fulltext = extractor.analyse(text.read)
    end

    #self.indexed_at = Time.zone.now
    save(:validate => false)
    text.close
  end

  def created(patron)
    creates.where(:patron_id => patron.id).first
  end

  def realized(patron)
    realizes.where(:patron_id => patron.id).first
  end

  def produced(patron)
    produces.where(:patron_id => patron.id).first
  end

  def sort_title
    NKF.nkf('-w --katakana', title_transcription) if title_transcription
  end

  def classifications
    subjects.collect(&:classifications).flatten
  end

  def volume_number
    volume_number_list.gsub(/\D/, ' ').split(" ") if volume_number_list
  end

  def issue_number
    issue_number_list.gsub(/\D/, ' ').split(" ") if issue_number_list
  end

  def serial_number
    serial_number_list.gsub(/\D/, ' ').split(" ") if serial_number_list
  end

  def questions(options = {})
    id = self.id
    options = {:page => 1, :per_page => Question.per_page}.merge(options)
    page = options[:page]
    per_page = options[:per_page]
    user = options[:user]
    Question.search do
      with(:manifestation_id).equal_to id
      any_of do
        unless user.try(:has_role?, 'Librarian')
          with(:shared).equal_to true
        #  with(:username).equal_to user.try(:username)
        end
      end
      paginate :page => page, :per_page => per_page
    end.results
  end

  def web_item
    items.where(:shelf_id => Shelf.web.id).first
  end

  def self.find_by_isbn(isbn)
    if ISBN_Tools.is_valid?(isbn)
      ISBN_Tools.cleanup!(isbn)
      if isbn.size == 10
        Manifestation.where(:isbn => ISBN_Tools.isbn10_to_isbn13(isbn)).first || Manifestation.where(:isbn => isbn).first
      else
        Manifestation.where(:isbn => isbn).first || Manifestation.where(:isbn => ISBN_Tools.isbn13_to_isbn10(isbn)).first
      end
    end
  end
end
