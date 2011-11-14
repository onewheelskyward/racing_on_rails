require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class PagesTest < AcceptanceTest
  def test_pages
    # Check public page render OK with default static templates
    visit "/schedule"
    assert_page_has_content(/Schedule|Calendar/)
    
    assert_page_has_no_content "This year is cancelled"
    assert_title(/Schedule|Calendar/)

    # Now change the page
    login_as FactoryGirl.create(:administrator)

    visit "/admin/pages"

    click :xpath => "//a[@href='/admin/pages/new']"

    type "Schedule", "page_title"
    type "This year is cancelled", "page_body"

    click "save"

    visit "/schedule"
    # Firefox honors the expires time, so the old page is still shown
    assert_page_has_no_content "This year is cancelled"

    refresh
    assert_page_has_content "This year is cancelled"

    visit "/admin/pages"

    assert_table("pages_table", 2, 0, /^Schedule/)

    # Create new page
    # 404 first
    visit "/officials", true
    assert_page_has_content "ActiveRecord::RecordNotFound"

    visit "/admin/pages"

    click :xpath => "//a[@href='/admin/pages/new']"

    type "Officials Home Phone Numbers", "page_title"
    type "officials", "page_slug"
    type "411 911", "page_body"

    click "save"

    visit "/officials"
    assert_page_has_content "411 911"
  end
end