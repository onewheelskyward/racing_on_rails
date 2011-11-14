require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class FirstAidProvidersTest < AcceptanceTest
  def test_first_aid_providers
    # FIXME Punt!
    if Date.today.month < 12
      login_as FactoryGirl.create(:administrator)
      promoter = FactoryGirl.create(:person, :name => "Brad Ross")
      event_1 = FactoryGirl.create(:event, :promoter => promoter, :date => 2.days.from_now, :first_aid_provider => "Megan Weaver")
      event_2 = FactoryGirl.create(:event, :date => 4.days.from_now)
      event_3 = FactoryGirl.create(:event, :date => 3.days.ago)

      visit "/admin/first_aid_providers"

      assert_table "events_table", 1, 3, /^#{events_1.name}/
      assert_table "events_table", 1, 4, /^Brad Ross/
      assert_table "events_table", 2, 3, /^#{events_2.name}/

      assert page.has_xpath?("//table[@id='events_table']//tr[2]//td[@class='name']//div[@class='record']//div[@class='editable']")
      find(:xpath => "//table[@id='events_table']//tr[2]//td[@class='name']//div[@class='record']//div[@class='editable']").click
      wait_for_element :css => "form.editor_field input"
      type "Megan Weaver", :css => "form.editor_field input"
      type :return, { :css => "form.editor_field input" }, false
      wait_for_no_element :css => "form.editor_field input"

      refresh
      wait_for_element "events_table"
      assert_table "events_table", 1, 0, /^Megan Weaver/

      if Date.today.month > 1
        click "past_events"
        assert_table "events_table", 1, 3, /^#{events_3.name}/

        click "past_events"
        assert_page_has_no_content events_3.name
      end

      assert_table "events_table", 1, 3, /^#{events_2.name}/
      assert_table "events_table", 2, 3, /^#{events_1.name}/

      # Table already sorted by date ascending, so click doesn't change order
      click :xpath => "//th[@class='date']//a"
      assert_table "events_table", 1, 3, /^#{events_2.name}/
      assert_table "events_table", 2, 3, /^#{events_1.name}/

      click :xpath => "//th[@class='date']//a"
      assert_table "events_table", 1, 3, /^#{events_1.name}/
      assert_table "events_table", 2, 3, /^#{events_2.name}/

      click :xpath => "//th[@class='date']//a"
      assert_table "events_table", 1, 3, /^#{events_2.name}/
      assert_table "events_table", 2, 3, /^#{events_1.name}/    
    end  
  end
end
