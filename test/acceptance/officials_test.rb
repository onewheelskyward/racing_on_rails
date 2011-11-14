require File.expand_path(File.dirname(__FILE__) + "/acceptance_test")

# :stopdoc:
class OfficialsTest < AcceptanceTest
  def test_view_assignments
    visit "/admin/first_aid_providers"

    visit "/people"
    assert page.has_no_selector? "export_link"
    
    login_as :administrator
    member = member
    visit "/admin/people/#{member.id}/edit"
    check "person_official"
    click "save"
    
    logout
    login_as :member
    visit "/admin/first_aid_providers"

    visit "/people"
    remove_download "scoring_sheet.xls"
    click "export_link"
    wait_for_not_current_url(/\/admin\/people.xls\?excel_layout=scoring_sheet&include=members_only/)
    wait_for_download "scoring_sheet.xls"
    assert_no_errors
  end
end
