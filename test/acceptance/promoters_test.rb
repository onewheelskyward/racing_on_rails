require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class PromotersTest < AcceptanceTest
  def test_browse
    FactoryGirl.create(:discipline, :name => "Cyclocross")
    FactoryGirl.create(:discipline, :name => "Downhill")
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Singlespeed")
    FactoryGirl.create(:discipline, :name => "Track")
    FactoryGirl.create(:number_issuer, :name => RacingAssociation.current.short_name)

    year = RacingAssociation.current.effective_year
    promoter = FactoryGirl.create(:promoter)
    series = Series.create!(:name => "Cross Crusade", :promoter => promoter, :date => Date.new(year, 10))
    event = SingleDayEvent.create!(:name => "Cross Crusade: Alpenrose", :promoter => promoter, :date => Date.new(year, 10))
    series.children << event
    login_as promoter
    
    if page.has_content?("Montana")
      visit "/admin/events/#{series.id}/edit"
    else
      click_link "events_tab"
      first("a[href='/admin/events/#{series.id}/edit']").click
    end
    click_button "Save"
    
    click_link "create_race"
    within "form.editor_field" do
      fill_in "value", :with => "Senior Women"
      press_enter "value"
    end
    assert_page_has_no_content "form.editor_field input"
    assert_page_has_content "Senior Women"
    race = series.races(true).first
    assert_equal "Senior Women", race.category_name, "Should update category name"

    click_link "edit_race_#{race.id}"
    click_button "Save"

    click_link "events_tab"
    click_link "Cross Crusade: Alpenrose"
    
    click_link "create_race"
    within "form.editor_field" do
      fill_in "value", :with => "Masters Women 40+"
      press_enter "value"
    end
    assert_page_has_no_content "form.editor_field input"
    assert_page_has_content "Masters Women 40+"
    race = event.races(true).first
    assert_equal "Masters Women 40+", race.category_name, "Should update category name"

    click_link "edit_race_#{race.id}"
    click_button "Save"

    click_link "people_tab"
    remove_download "scoring_sheet.xls"
    click_link "export_link"
    wait_for_download "scoring_sheet.xls"

    visit "/admin/events/#{series.id}/edit"
    click_ok_on_alert_dialog
    click_link "propagate_races"
  end
end
