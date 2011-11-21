require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class Admin::Events::EditControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end

  def test_upload
    mt_hood_1 = mt_hood_1
    assert(mt_hood_1.races.empty?, 'Should have no races before import')

    post :upload, :id => mt_hood_1.to_param, 
                  :results_file => fixture_file_upload("../files/results/pir_2006_format.xls", "application/vnd.ms-excel", :binary)

    assert(!flash.has_key?(:warn), "flash[:warn] should be empty,  but was: #{flash[:warn]}")
    assert_redirected_to edit_admin_event_path(mt_hood_1)
    assert(flash.has_key?(:notice))
    assert(!mt_hood_1.races(true).empty?, 'Should have races after upload attempt')
  end

  def test_upload_usac
    RacingAssociation.current.usac_results_format = true
    mt_hood_1 = mt_hood_1
    assert(mt_hood_1.races.empty?, 'Should have no races before import')

    post :upload, :id => mt_hood_1.to_param, 
                  :results_file => fixture_file_upload("../files/results/tt_usac.xls", "application/vnd.ms-excel", :binary)

    assert(!flash.has_key?(:warn), "flash[:warn] should be empty,  but was: #{flash[:warn]}")
    assert_redirected_to edit_admin_event_path(mt_hood_1)
    assert(flash.has_key?(:notice))
    assert(!mt_hood_1.races(true).empty?, 'Should have races after upload attempt')
  end

  def test_upload_lif
    mt_hood_1 = mt_hood_1
    assert(mt_hood_1.races.empty?, 'Should have no races before import')

    post :upload, :id => mt_hood_1.to_param, 
                  :results_file => fixture_file_upload("../files/results/OutputFile.lif", nil, :binary)

    assert(!flash.has_key?(:warn), "flash[:warn] should be empty,  but was: #{flash[:warn]}")
    assert_redirected_to edit_admin_event_path(mt_hood_1)
    assert(flash.has_key?(:notice))
    assert(!mt_hood_1.races(true).empty?, 'Should have races after upload attempt')
  end

  def test_upload_custom_columns
    mt_hood_1 = mt_hood_1
    assert(mt_hood_1.races.empty?, 'Should have no races before import')
  
    post :upload, :id => mt_hood_1.to_param, 
                  :results_file => fixture_file_upload("../files/results/custom_columns.xls", "application/vnd.ms-excel", :binary)
    assert_redirected_to edit_admin_event_path(mt_hood_1)

    assert_response :redirect
    assert(flash.has_key?(:notice))
    assert(!flash.has_key?(:warn))
    assert(!mt_hood_1.races(true).empty?, 'Should have races after upload attempt')
  end

  def test_upload_dupe_people
    # Two people with different name, same numbers
    # Excel file has Greg Rodgers with no number
    Person.create(:name => 'Greg Rodgers', :road_number => '404')
    Person.create(:name => 'Greg Rodgers', :road_number => '500')
    
    mt_hood_1 = mt_hood_1
    assert(mt_hood_1.races(true).empty?, 'Should have no races before import')
    
    file = fixture_file_upload("../files/results/dupe_people.xls", "application/vnd.ms-excel", :binary)
    post :upload, :id => mt_hood_1.to_param, :results_file => file
    
    assert_response :redirect
    
    # Dupe people used to be allowed, and this would have been an error
    assert(!mt_hood_1.races(true).empty?, 'Should have races after importing dupe people')
    assert(!flash.has_key?(:warn))
  end

  def test_upload_schedule
    @request.session[:person_id] = administrator.id
  
    before_import_after_schedule_start_date = Event.count(:conditions => "date > '2005-01-01'")
    assert_equal(11, before_import_after_schedule_start_date, "2005 events count before import")
    before_import_all = Event.count
    assert_equal(19, before_import_all, "All events count before import")
  
    post(:upload_schedule, :schedule_file => fixture_file_upload("../files/schedule/excel.xls", "application/vnd.ms-excel", :binary))
  
    assert(!flash.has_key?(:warn), "flash[:warn] should be empty,  but was: #{flash[:warn]}")
    assert_response :redirect
    assert_redirected_to(admin_events_path)
    assert(flash.has_key?(:notice))
  
    after_import_after_schedule_start_date = Event.count(:conditions => "date > '2005-01-01'")
    assert_equal(84, after_import_after_schedule_start_date, "2005 events count after import")
    after_import_all = Event.count
    assert_equal(92, after_import_all, "All events count after import")
  end
end
