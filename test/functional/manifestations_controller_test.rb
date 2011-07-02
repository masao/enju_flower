require 'test_helper'

class ManifestationsControllerTest < ActionController::TestCase
  fixtures :manifestations, :carrier_types, :work_has_subjects, :languages, :subjects, :subject_types,
    :form_of_works, :realizes,
    :content_types, :frequencies,
    :items, :library_groups, :libraries, :shelves, :languages,
    :patrons, :user_groups, :users,
    :bookmarks, :roles,
    :subscriptions, :subscribes, :search_histories


  def test_api_sru_template
    get :index, :format => 'sru', :query => 'title=ruby', :operation => 'searchRetrieve'
    assert_response :success
    assert_template('manifestations/index')
  end

  def test_api_sru_error
    get :index, :format => 'sru'
    assert_response :success
    assert_template('manifestations/explain')
  end

  def test_guest_should_get_index
    if configatron.write_search_log_to_file
      assert_no_difference('SearchHistory.count') do
        get :index
      end
    else
      assert_difference('SearchHistory.count') do
        get :index
      end
    end
    get :index
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_xml
    if configatron.write_search_log_to_file
      assert_no_difference('SearchHistory.count') do
        get :index, :format => 'xml'
      end
    else
      assert_difference('SearchHistory.count') do
        get :index, :format => 'xml'
      end
    end
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_csv
    if configatron.write_search_log_to_file
      assert_no_difference('SearchHistory.count') do
        get :index, :format => 'csv'
      end
    else
      assert_difference('SearchHistory.count') do
        get :index, :format => 'csv'
      end
    end
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_mods
    get :index, :format => 'mods'
    assert_response :success
    assert_template('manifestations/index')
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_rdf
    get :index, :format => 'rdf'
    assert_response :success
    assert_template('manifestations/index')
    assert assigns(:manifestations)
  end

  def test_user_should_not_create_search_history_if_log_is_written_to_file
    sign_in users(:user1)
    if configatron.write_search_log_to_file
      assert_no_difference('SearchHistory.count') do
        get :index, :query => 'test'
      end
    else
      assert_difference('SearchHistory.count') do
        get :index, :query => 'test'
      end
    end
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_manifestation_id
    get :index, :manifestation_id => 1
    assert_response :success
    assert assigns(:manifestation)
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_patron_id
    get :index, :patron_id => 1
    assert_response :success
    assert assigns(:patron)
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_expression
    get :index, :expression_id => 1
    assert_response :success
    assert assigns(:manifestations)
  end

  #def test_user_should_not_get_index_with_subscription
  #  sign_in users(:user1)
  #  get :index, :subscription_id => 1
  #  assert_response :forbidden
  #end

  #def test_librarian_should_get_index_with_subscription
  #  sign_in users(:librarian1)
  #  get :index, :subscription_id => 1
  #  assert_response :success
  #  assert assigns(:subscription)
  #  assert assigns(:manifestations)
  #end

  def test_guest_should_get_index_with_query
    get :index, :query => '2005'
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_get_index_with_page_number
    get :index, :query => '2005', :number_of_pages_at_least => 1, :number_of_pages_at_most => 100
    assert_response :success
    assert assigns(:manifestations)
    assert_equal '2005 number_of_pages_i: [1 TO 100]', assigns(:query)
  end

  def test_guest_should_get_index_all_facet
    get :index, :query => '2005', :view => 'all_facet'
    assert_response :success
    assert assigns(:carrier_type_facet)
    assert assigns(:language_facet)
    assert assigns(:library_facet)
    #assert assigns(:subject_facet)
  end

  def test_guest_should_get_index_carrier_type_facet
    get :index, :query => '2005', :view => 'carrier_type_facet'
    assert_response :success
    assert assigns(:carrier_type_facet)
  end

  def test_guest_should_get_index_language_facet
    get :index, :query => '2005', :view => 'language_facet'
    assert_response :success
    assert assigns(:language_facet)
  end

  def test_guest_should_get_index_library_facet
    get :index, :query => '2005', :view => 'library_facet'
    assert_response :success
    assert assigns(:library_facet)
  end

  #def test_guest_should_get_index_subject_facet
  #  get :index, :query => '2005', :view => 'subject_facet'
  #  assert_response :success
  #  assert assigns(:subject_facet)
  #end

  def test_guest_should_get_index_tag_cloud
    get :index, :query => '2005', :view => 'tag_cloud'
    assert_response :success
    assert_template :partial => '_tag_cloud'
  end

  #def test_user_should_save_search_history_when_allowed
  #  old_search_history_count = SearchHistory.count
  #  sign_in users(:admin)
  #  get :index, :query => '2005'
  #  assert_response :success
  #  assert assigns(:manifestations)
  #  assert_equal old_search_history_count + 1, SearchHistory.count
  #end

  def test_user_should_get_index
    sign_in users(:user1)
    get :index
    assert_response :success
    assert assigns(:manifestations)
  end

  #def test_user_should_not_save_search_history_when_not_allowed
  #  old_search_history_count = SearchHistory.count
  #  sign_in users(:user1)
  #  get :index
  #  assert_response :success
  #  assert assigns(:manifestations)
  #  assert_equal old_search_history_count, SearchHistory.count
  #end

  def test_librarian_should_get_index
    sign_in users(:librarian1)
    get :index
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_admin_should_get_index
    sign_in users(:admin)
    get :index
    assert_response :success
    assert assigns(:manifestations)
  end

  def test_guest_should_show_manifestation
    get :show, :id => 1
    assert_response :success
  end

  test 'guest shoud show manifestation screen shot' do
    get :show, :id => 22, :mode => 'screen_shot'
    assert_response :success
  end

  test 'guest shoud show manifestation mods template' do
    get :show, :id => 22, :format => 'mods'
    assert_response :success
    assert_template 'manifestations/show'
  end

  test 'guest shoud show manifestation rdf template' do
    get :show, :id => 22, :format => 'rdf'
    assert_response :success
    assert_template 'manifestations/show'
  end

  def test_guest_should_show_manifestation_with_holding
    get :show, :id => 1, :mode => 'holding'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_tag_edit
    get :show, :id => 1, :mode => 'tag_edit'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_tag_list
    get :show, :id => 1, :mode => 'tag_list'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_show_authors
    get :show, :id => 1, :mode => 'show_authors'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_show_all_authors
    get :show, :id => 1, :mode => 'show_all_authors'
    assert_response :success
  end

  def test_guest_should_show_manifestation_with_isbn
    get :show, :isbn => "4798002062"
    assert_response :redirect
    assert_redirected_to manifestation_url(assigns(:manifestation))
  end

  def test_guest_should_not_show_manifestation_with_invalid_isbn
    get :show, :isbn => "47980020620"
    assert_response :missing
  end

  def test_guest_should_not_send_manifestation_detail_email
    get :show, :id => 1, :mode => 'send_email'
    assert_redirected_to new_user_session_url
  end

  def test_guest_should_generate_fragment_cache
    get :show, :id => 1, :mode => 'generate_cache'
    assert_response :success
  end

  def test_user_should_show_manifestation
    sign_in users(:user1)
    get :show, :id => 1
    assert_response :success
  end

  def test_user_should_send_manifestation_detail_email
    sign_in users(:user1)
    get :show, :id => 1, :mode => 'send_email'
    assert_redirected_to manifestation_url(assigns(:manifestation))
  end

  def test_librarian_should_show_manifestation
    sign_in users(:librarian1)
    get :show, :id => 1
    assert_response :success
  end

  def test_librarian_should_show_manifestation_with_expression_not_embodied
    sign_in users(:librarian1)
    get :show, :id => 1, :expression_id => 3
    assert_response :success
  end

  def test_librarian_should_show_manifestation_with_patron_not_produced
    sign_in users(:librarian1)
    get :show, :id => 3, :patron_id => 1
    assert_response :success
  end

  def test_admin_should_show_manifestation
    sign_in users(:admin)
    get :show, :id => 1
    assert_response :success
  end

  def test_guest_should_not_get_edit
    get :edit, :id => 1
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_get_edit
    sign_in users(:user1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_user_should_not_get_edit_with_tag_edit
    sign_in users(:user1)
    get :edit, :id => 1, :mode => 'tag_edit'
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit
    sign_in users(:librarian1)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_librarian_should_not_get_edit_upload
    sign_in users(:librarian1)
    get :edit, :id => 1, :upload => true
    assert_response :forbidden
  end
  
  def test_admin_should_not_get_edit
    sign_in users(:admin)
    get :edit, :id => 1
    assert_response :forbidden
  end
  
  def test_guest_should_not_update_manifestation
    put :update, :id => 1, :manifestation => { }
    assert_redirected_to new_user_session_url
  end
  
  def test_user_should_not_update_manifestation
    sign_in users(:user1)
    put :update, :id => 1, :manifestation => { }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_manifestation_without_title
    sign_in users(:librarian1)
    put :update, :id => 1, :manifestation => { :original_title => nil }
    assert_response :forbidden
  end
  
  def test_librarian_should_not_update_manifestation
    sign_in users(:librarian1)
    put :update, :id => 1, :manifestation => { }
    assert_response :forbidden
  end
  
  def test_admin_should_not_update_manifestation
    sign_in users(:admin)
    put :update, :id => 1, :manifestation => { }
    assert_response :forbidden
  end
  
  def test_guest_should_not_destroy_manifestation
    assert_no_difference('Manifestation.count') do
      delete :destroy, :id => 1
    end
    
    assert_redirected_to new_user_session_url
  end

  def test_user_should_not_destroy_manifestation
    sign_in users(:user1)
    assert_no_difference('Manifestation.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_librarian_should_not_destroy_manifestation
    sign_in users(:librarian1)
    assert_no_difference('Manifestation.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end

  def test_admin_should_not_destroy_manifestation
    sign_in users(:admin)
    assert_no_difference('Manifestation.count') do
      delete :destroy, :id => 1
    end
    
    assert_response :forbidden
  end
end
