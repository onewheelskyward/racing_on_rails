require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ResultsTest < ActionController::IntegrationTest
  def test_custom_columns
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:discipline, :name => "Downhill")
    FactoryGirl.create(:number_issuer)
    
    goto_login_page_and_login_as FactoryGirl.create(:administrator)

    event = FactoryGirl.create(:result).event
    get edit_admin_event_path(event)
    assert_response :success

    post upload_admin_event_path(event), :results_file => fixture_file_upload(File.expand_path("../../fixtures/files/results/dh.xls", __FILE__), "application/vnd.ms-excel", :binary)
    assert_response :redirect
    follow_redirect!
    assert_response :success
    
    https! false
    get event_path(event)
    assert_response :success
    
    assert @response.body["Run 1"]
    assert @response.body["Run 2"]
  end
end
