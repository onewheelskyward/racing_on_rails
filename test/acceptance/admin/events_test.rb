require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class EventsTest < AcceptanceTest
  def test_events
    login_as FactoryGirl.create(:administrator)

    click_link "New Event"

    type "Sausalito Criterium", "event_name"
    click "save"
    wait_for_page_source "Created Sausalito Criterium"
    
    if Date.today.month == 12
      visit "/admin/events?year=#{Date.today.year}"
    else
      visit "/admin/events"
    end
    assert_page_has_content "Sausalito Criterium"
    click_link "Sausalito Criterium"

    assert_value "", "event_promoter_id"
    assert_value "", "promoter_auto_complete"
    type "Tom Brown", "promoter_auto_complete"

    click "save"
    assert_value(/\d+/, "event_promoter_id")
    assert_value "Tom Brown", "promoter_auto_complete"

    visit "/admin/events?year=#{Date.today.year}"
    assert_page_has_content "Sausalito Criterium"
    click_link "Sausalito Criterium"
    assert_value(/\d+/, "event_promoter_id")
    assert_value "Tom Brown", "promoter_auto_complete"

    click "edit_promoter_link"
    assert_title(/Tom Brown$/)

    type "Tim", "person_first_name"
    click "save"

    click "back_to_event"

    assert_title(/Sausalito Criterium/)
    assert_value(/\d+/, "event_promoter_id")
    assert_value "Tim Brown", "promoter_auto_complete"

    candi = Person.find_by_name('Candi Murray')
    type "candi m", "promoter_auto_complete"
    wait_for_element "person_#{candi.id}"
    
    click :css => "li#person_#{candi.id} a"
    wait_for_value candi.id, "event_promoter_id"
    assert_value "Candi Murray", "promoter_auto_complete"

    click "save"

    assert_value candi.id, "event_promoter_id"
    assert_value "Candi Murray", "promoter_auto_complete"

    click "promoter_auto_complete"
    type "", "promoter_auto_complete"
    assert_value "", "promoter_auto_complete"
    click "save"

    assert_value "", "event_promoter_id"
    assert_value "", "promoter_auto_complete"

    assert_value "", "event_team_id"
    assert_value "", "team_auto_complete"

    assert_value "", "event_phone"
    assert_value "", "event_email"

    type "(541) 212-9000", "event_phone"
    type "event@google.com", "event_email"
    click "save"

    assert_value "(541) 212-9000", "event_phone"
    assert_value "event@google.com", "event_email"

    visit "/admin/people/#{candi.id}/edit"
    assert_value "(503) 555-1212", "person_home_phone"
    assert_value "admin@example.com", "person_email"

    visit "/admin/events?year=#{Date.today.year}"
    click_link "Sausalito Criterium"

    type "Gentle Lovers", "team_auto_complete"
    gl = Team.find_by_name('Gentle Lovers')
    wait_for_element "team_#{gl.id}"
    wait_for_displayed "team_#{gl.id}"
    click :css => "li#team_#{gl.id} a"
    wait_for_value gl.id, "event_team_id"
    assert_value "Gentle Lovers", "team_auto_complete"

    click "save"

    assert_value gl.id, "event_team_id"
    assert_value "Gentle Lovers", "team_auto_complete"

    assert_value gl.id, "event_team_id"
    click "team_auto_complete"
    type "", "team_auto_complete"
    click "save"

    assert_value "", "event_team_id"
    assert_value "", "team_auto_complete"

    click_link "Delete"

    assert_page_has_content "Deleted Sausalito Criterium"

    visit "/admin/events?year=2004"
    assert_page_has_no_content "Sausalito Criterium"

    visit "/admin/events?year=2003"

    wait_for_page_source "Import Schedule"
    click_link "Kings Valley Road Race"
    wait_for_page_source "Senior Men Pro 1/2"
    assert_page_has_content "Senior Men 3"

    kings_valley = Event.find_by_name_and_date('Kings Valley Road Race', '2003-12-31')
    click "destroy_race_#{kings_valley.races.first.id}"

    visit "/admin/events?year=2003"
    click_link "Kings Valley Road Race"

    click_ok_on_confirm_dialog
    click "destroy_races"

    visit "/admin/events?year=2003"

    click_link "Kings Valley Road Race"
    wait_for_current_url %r{/admin/events/\d+/edit}
    assert_page_has_no_content "Senior Men Pro 1/2"
    assert_page_has_no_content "Senior Men 3"

    click "new_event"
    wait_for_current_url(/\/events\/new/)
    assert_page_has_content "Kings Valley Road Race"
    assert_value kings_valley.id, "event_parent_id"

    type "Fancy New Child Event", "event_name"
    click "save"
    assert_value kings_valley.id, "event_parent_id"

    visit "/admin/events/#{kings_valley.id}/edit"
    assert_page_has_content "Fancy New Child Event"
  end
  
  def test_lost_children
    login_as FactoryGirl.create(:administrator)
    FactoryGirl.create(:event, :name => "PIR")
    event = FactoryGirl.create(:event, :name => "PIR")
    
    visit "/admin/events/#{event.id}/edit"
    assert_page_has_content 'has no parent'
    click "set_parent"
    assert_page_has_no_content 'error'
    assert_page_has_no_content 'Unknown action'
    assert_page_has_no_content 'has no parent'
  end
end
