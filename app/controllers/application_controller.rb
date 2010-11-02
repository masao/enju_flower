# -*- encoding: utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  include SslRequirement
  include Oink::MemoryUsageLogger
  include Oink::InstanceTypeCounter

  rescue_from CanCan::AccessDenied, :with => :render_403
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  before_filter :get_library_group, :set_locale, :set_available_languages

  def render_403
    if user_signed_in?
      respond_to do |format|
        format.html {render :template => 'page/403', :status => 403}
        format.xml {render :template => 'page/403', :status => 403}
      end
    else
      respond_to do |format|
        format.html {redirect_to new_user_session_url}
        format.xml {render :template => 'page/403', :status => 403}
      end
    end
  end

  def render_404
    respond_to do |format|
      format.html {render :template => 'page/404', :status => 404}
      format.xml {render :template => 'page/404', :status => 404}
    end
  end

  private
  def get_library_group
    @library_group = LibraryGroup.site_config
  end

  def set_locale
    if params[:locale]
      unless I18n.available_locales.include?(params[:locale].to_s.intern)
        raise InvalidLocaleError
      end
    end
    if user_signed_in?
      locale = params[:locale] || session[:locale] || current_user.locale
    else
      locale = params[:locale] || session[:locale]
    end
    I18n.locale = locale.to_sym if locale
    @locale = session[:locale] = locale ||= I18n.default_locale.to_s
  rescue InvalidLocaleError
    @locale = I18n.default_locale.to_s
  end

  def default_url_options(options={})
    {:locale => nil}
  end

  def set_available_languages
    @available_languages = Language.available_languages
  end

  def reset_params_session
    session[:params] = nil
  end

  def not_found
    raise ActiveRecord::RecordNotFound
  end

  def access_denied
    raise CanCan::AccessDenied
  end

  def get_patron
    @patron = Patron.find(params[:patron_id]) if params[:patron_id]
    authorize! :show, @patron if @patron
  end

  def get_work
    @work = Manifestation.find(params[:work_id]) if params[:work_id]
    authorize! :show, @work if @work
  end

  def get_expression
    @expression = Manifestation.find(params[:expression_id]) if params[:expression_id]
    authorize! :show, @expression if @expression
  end

  def get_manifestation
    @manifestation = Manifestation.find(params[:manifestation_id]) if params[:manifestation_id]
    authorize! :show, @manifestation if @manifestation
  end

  def get_item
    @item = Item.find(params[:item_id]) if params[:item_id]
    authorize! :show, @item if @item
  end

  def get_carrier_type
    @carrier_type = CarrierType.find(params[:carrier_type_id]) if params[:carrier_type_id]
  end

  def get_shelf
    @shelf = Shelf.find(params[:shelf_id], :include => :library) if params[:shelf_id]
  end

  def get_basket
    @basket = Basket.find(params[:basket_id]) if params[:basket_id]
  end

  def get_patron_merge_list
    @patron_merge_list = PatronMergeList.find(params[:patron_merge_list_id]) if params[:patron_merge_list_id]
  end

  def get_user
    @user = User.first(:conditions => {:username => params[:user_id]}) if params[:user_id]
    if @user
      authorize! :show, @user
    else
      raise ActiveRecord::RecordNotFound
    end
    return @user
  end

  def get_user_if_nil
    @user = User.first(:conditions => {:username => params[:user_id]}) if params[:user_id]
    #authorize! :show, @user if @user
  end
  
  def get_user_group
    @user_group = UserGroup.find(params[:user_group_id]) if params[:user_group_id]
  end
                    
  def get_library
    @library = Library.find(params[:library_id]) if params[:library_id]
  end

  def get_libraries
    @libraries = Rails.cache.fetch('library_all'){Library.all}
  end

  def get_library_group
    @library_group = LibraryGroup.site_config
  end

  def get_question
    @question = Question.find(params[:question_id]) if params[:question_id]
    authorize! :show, @question if @question
  end

  def get_event
    @event = Event.find(params[:event_id]) if params[:event_id]
  end

  def get_bookstore
    @bookstore = Bookstore.find(params[:bookstore_id]) if params[:bookstore_id]
  end

  def get_subject
    @subject = Subject.find(params[:subject_id]) if params[:subject_id]
  end

  def get_classification
    @classification = Classification.find(params[:classification_id]) if params[:classification_id]
  end

  def get_subscription
    @subscription = Subscription.find(params[:subscription_id]) if params[:subscription_id]
  end

  def get_order_list
    @order_list = OrderList.find(params[:order_list_id]) if params[:order_list_id]
  end

  def get_purchase_request
    @purchase_request = PurchaseRequest.find(params[:purchase_request_id]) if params[:purchase_request_id]
  end

  def get_checkout_type
    @checkout_type = CheckoutType.find(params[:checkout_type_id]) if params[:checkout_type_id]
  end

  def get_inventory_file
    @inventory_file = InventoryFile.find(params[:inventory_file_id]) if params[:inventory_file_id]
  end

  def get_subject_heading_type
    @subject_heading_type = SubjectHeadingType.find(params[:subject_heading_type_id]) if params[:subject_heading_type_id]
  end

  def get_series_statement
    @series_statement = SeriesStatement.find(params[:series_statement_id]) if params[:series_statement_id]
  end

  def convert_charset
    #if params[:format] == 'ics'
    #  response.body = NKF::nkf('-w -Lw', response.body)
    case params[:format]
    when 'csv'
      return unless configatron.csv_charset_conversion
      # TODO: 他の言語
      if @locale == 'ja'
        headers["Content-Type"] = "text/csv; charset=Shift_JIS"
        response.body = NKF::nkf('-Ws', response.body)
      end
    when 'xml'
      if @locale == 'ja'
        headers["Content-Type"] = "application/xml; charset=Shift_JIS"
        response.body = NKF::nkf('-Ws', response.body)
      end
    end
  end

  def my_networks?
    return true if LibraryGroup.site_config.network_access_allowed?(request.remote_ip, :network_type => 'lan')
    false
  end

  def admin_networks?
    return true if LibraryGroup.site_config.network_access_allowed?(request.remote_ip, :network_type => 'admin')
    false
  end

  def check_client_ip_address
    access_denied unless my_networks?
  end

  def check_admin_network
    access_denied unless admin_networks?
  end

  def check_dsbl
    library_group = LibraryGroup.site_config
    return true if library_group.network_access_allowed?(request.remote_ip, :network_type => 'lan')
    begin
      dsbl_hosts = library_group.dsbl_list.split.compact
      reversed_address = request.remote_ip.split(/\./).reverse.join(".")
      dsbl_hosts.each do |dsbl_host|
        result = Socket.gethostbyname("#{reversed_address}.#{dsbl_host}.").last.unpack("C4").join(".")
        raise SocketError unless result =~ /^127\.0\.0\./
        access_denied
      end
    rescue SocketError
      nil
    end
  end

  def store_page
    flash[:page] = params[:page].to_i if params[:page]
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default = '/')
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def set_role_query(user, search)
    role = user.try(:role) || Role.default_role
    search.build do
      with(:required_role_id).less_than role.id
    end
  end

  def make_internal_query(search)
    # 内部的なクエリ
    set_role_query(current_user, search)

    unless params[:mode] == "add"
      expression = @expression
      patron = @patron
      resource = @resource
      reservable = @reservable
      carrier_type = params[:carrier_type]
      library = params[:library]
      language = params[:language]
      subject = params[:subject]
      subject_by_term = Subject.first(:conditions => {:term => params[:subject]})
      @subject_by_term = subject_by_term

      search.build do
        with(:publisher_ids).equal_to patron.id if patron
        with(:original_resource_ids).equal_to resource.id if resource
        with(:reservable).equal_to reservable unless reservable.nil?
        unless carrier_type.blank?
          with(:carrier_type).equal_to carrier_type
          with(:carrier_type).equal_to carrier_type
        end
        unless library.blank?
          library_list = library.split.uniq
          library_list.each do |library|
            with(:library).equal_to library
          end
          #search.query.keywords = "#{search.query.to_params[:q]} library_s: (#{library_list})"
        end
        unless language.blank?
          language_list = language.split.uniq
          language_list.each do |language|
            with(:language).equal_to language
          end
        end
        unless subject.blank?
          with(:subject).equal_to subject_by_term.term
        end
      end
    end
    return search
  end

  def solr_commit
    Sunspot.commit
  end

  def get_version
    @version = params[:version_id].to_i if params[:version_id]
    @version = nil if @version == 0
  end

  def clear_search_sessions
    session[:query] = nil
    session[:params] = nil
    session[:search_params] = nil
    session[:resource_ids] = nil
  end

  def api_request?
    true unless params[:format].nil? or params[:format] == 'html'
  end

end

class InvalidLocale < StandardError
end
