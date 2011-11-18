require File.expand_path(File.dirname(__FILE__) + "/../acceptance_test")

# :stopdoc:
class PeopleTest < AcceptanceTest
  def test_edit
    login_as FactoryGirl.create(:administrator)
    
    visit '/admin/people'
    assert_page_has_content "Enter part of a person's name"
    fill_in "name", :with => "a"
    submit "search_form"
    
    assert_text "", "warn"
    assert_text "", "notice"
    
    assert_table("people_table", 1, 1, /^Molly Cameron/)
    assert_table("people_table", 2, 1, /^Mark Matson/)
    assert_table("people_table", 3, 1, /^Candi Murray/)
    assert_table("people_table", 4, 1, /^Alice Pennington/)
    assert_table("people_table", 5, 1, /^Brad Ross/)
    assert_table("people_table", 6, 1, /^Ryan Weaver/)
    
    assert_table("people_table", 1, 2, /^Vanilla/)
    assert_table("people_table", 2, 2, /^Kona/)
    assert_table("people_table", 4, 2, /^Gentle Lovers/)
    assert_table("people_table", 6, 2, /^Gentle Lovers/)
                
    assert_table("people_table", 1, 3, /^Mollie Cameron/)
    assert_table "people_table", 2, 3, ""
    assert_table "people_table", 3, 3, ""
    assert_table "people_table", 4, 3, ""
    assert_table "people_table", 5, 3, ""
    assert_table "people_table", 6, 3, ""
    
    if Date.today.month < 12
      assert_table "people_table", 1, 4, "202"
      assert_table "people_table", 2, 4, "340"
      assert_table "people_table", 3, 4, ""
      assert_table "people_table", 4, 4, "230"
      assert_table "people_table", 5, 4, ""
      assert_table "people_table", 6, 4, "341"
    end
    
    assert_table "people_table", 1, 5, ""
    assert_table "people_table", 2, 5, ""
    assert_table "people_table", 3, 5, ""
    assert_table "people_table", 4, 5, ""
    assert_table "people_table", 5, 5, ""
    if Date.today.month < 12
      assert_table "people_table", 6, 5, "437"
    end
    
    @molly_id = Person.find_by_name("Molly Cameron").id
    @weaver_id = Person.find_by_name("Ryan Weaver").id
    @matson_id = Person.find_by_name("Mark Matson").id
    @matson = Person.find_by_name("Mark Matson")
    @alice_id = Person.find_by_name("Alice Pennington").id
    assert_checked "person_member_#{@molly_id}"
    assert_checked "person_member_#{@weaver_id}"
    assert_checked "person_member_#{@matson_id}"
    assert_checked "person_member_#{@alice_id}"
    
    click "person_#{@alice_id}_name"
    wait_for_element :css => "form.editor_field input"
    
    type "A Penn", :css => "form.editor_field input"
    type :return, { :css => "form.editor_field input" }, false
    wait_for_no_element :css => "form.editor_field input"
    
    refresh
    wait_for_element "people_table"
    assert_table("people_table", 4, 1, /^A Penn/)
    
    click "person_#{@weaver_id}_team_name"
    wait_for_element :css => "form.editor_field input"
    
    type "River City Bicycles", :css => "form.editor_field input"
    type :return, { :css => "form.editor_field input" }, false
    wait_for_no_element :css => "form.editor_field input"
    
    refresh
    wait_for_element "people_table"
    assert_table("people_table", 6, 2, /^River City Bicycles/)
    
    click "#{@molly_id}_results"
    wait_for_element "person_#{@molly_id}_table"
    assert_title(/Admin: Results: Molly Cameron$/)
    
    visit "/admin/people"
    click "#{@weaver_id}_results"
    assert_title(/Admin: Results: Ryan Weaver$/)
    
    visit "/admin/people"
    click "edit_#{@matson_id}"
    assert_title(/Admin: People: Mark Matson$/)
    fill_in "person_home_phone", :with => "411 911 1212"
    click "save"
    
    click :css => "a[href='/people/#{@matson_id}/versions']"
    
    visit '/admin/people'
    click "new_person"
    assert_title(/Admin: People: New Person/)
    
    visit "/admin/people/#{@matson.id}/edit"
    assert_page_has_content "Mark Matson"
    if Date.today.month < 12
      click "destroy_number_#{@matson.race_numbers.first.id}"
      wait_for_no_element :css => "input.number[value='340']"
      
      click "save"
    
      assert_page_has_no_content "error"
      assert_page_has_no_content "Unknown action"
      assert_page_has_no_content "Couldn't find RaceNumber"
    end
    
    visit "/admin/people/#{Person.find_by_name("Non Results").id}/edit"
    assert_page_has_content 'Non Results'
    click "delete"
    assert_page_has_no_content 'error'
    assert_page_has_no_content 'Unknown action'
    assert_page_has_no_content 'has no parent'
    
    fill_in "name", :with => "no results"
    submit "search_form"
    assert_page_has_no_content "Non Results"

    visit "/admin/people"
    fill_in "name", :with => "a"
    submit "search_form"
    
    drag_and_drop_on "person_#{@alice_id}", "person_#{@molly_id}"
    wait_for_page_source "Merged A Penn into Molly Cameron"
    assert !Person.exists?(@alice_id), "Alice should be merged"
    assert Person.exists?(@molly_id), "Molly still exist after merge"
  end

  def test_merge_confirm
    login_as FactoryGirl.create(:administrator)

    visit "/admin/people"
    fill_in "name", :with => "a"
    submit "search_form"
    
    assert_table("people_table", 1, 1, /^Molly Cameron/)
    assert_table("people_table", 2, 1, /^Mark Matson/)
    
    molly = Person.find_by_name("Molly Cameron")
    matson = Person.find_by_name("Mark Matson")

    click "person_#{matson.id}_name"
    wait_for_element :css => "form.editor_field input"

    type "Molly Cameron", :css => "form.editor_field input"
    type :return, { :css => "form.editor_field input" }, false
    wait_for_displayed :css => "div.ui-dialog"
    click :css => ".ui-dialog-buttonset button:last-child"
    wait_for_not_displayed :css => "div.ui-dialog"
    
    assert Person.exists?(molly.id), "Should not have merged Molly"
    assert Person.exists?(matson.id), "Should not have merged Matson"
    assert !molly.aliases(true).map(&:name).include?("Mark Matson"), "Should not add Matson alias"

    visit "/admin/people"
    submit "search_form"
    assert_table("people_table", 1, 1, /^Molly Cameron/)
    assert_table("people_table", 2, 1, /^Mark Matson/)

    click "person_#{matson.id}_name"
    type "Molly Cameron", :css => "form.editor_field input"
    type :return, { :css => "form.editor_field input" }, false
    wait_for_displayed :css => "div.ui-dialog"
    click :css => ".ui-dialog-buttonset button:first-child"
    wait_for_not_displayed :css => "div.ui-dialog"
    
    wait_for_page_source "Merged Mark Matson into Molly Cameron"
    assert Person.exists?(molly.id), "Should not have merged Molly"
    assert !Person.exists?(matson.id), "Should have merged Matson"
    assert molly.aliases(true).map(&:name).include?("Mark Matson"), "Should add Matson alias"
  end

  def test_export
    login_as FactoryGirl.create(:administrator)

    visit '/admin/people'
    assert page.has_selector? 'export_button'
    assert page.has_selector? 'include'
    assert_value 'members_only', 'include'
    assert page.has_selector? 'format'
    assert_value 'xls', 'format'

    remove_download "people_2011_1_1.xls"
    click 'export_button'
    wait_for_not_current_url(/\/admin\/people.xls\?excel_layout=xls&include=members_only/)
    wait_for_download "people_2011_1_1.xls"
    assert_no_errors

    visit '/admin/teams'

    visit '/admin/people'

    fill_in "name", :with => "tonkin"
    type :return, { :name => "name" }, false
    sleep 1
    assert_page_has_no_content 'error'
    assert_page_has_content 'Erik Tonkin'
    assert_page_has_content 'Kona'
    if Date.today.month < 12
      assert_page_has_content '102'
    end
    assert_value 'tonkin', "name"

    select_option "all", "include"
    select_option "ppl", "format"
    remove_download "lynx.ppl"
    click 'export_button'
    wait_for_not_current_url(/\/admin\/people.ppl\?excel_layout=ppl&include=all/)
    wait_for_download "lynx.ppl"
    assert_no_errors

    select_option "members_only", "include"
    select_option "scoring_sheet", "format"
    remove_download "scoring_sheet.xls"
    click 'export_button'
    wait_for_not_current_url(/\/admin\/people.xls\?excel_layout=scoring_sheet&include=members_only/)
    wait_for_download "scoring_sheet.xls"
    assert_no_errors

    fill_in 'name', :with => 'tonkin'
    type :return, { :name => "name" }, false
    wait_for_element "people_table"
    assert_page_has_content 'Erik Tonkin'
    assert_page_has_content 'Kona'
    if Date.today.month < 12
      assert_page_has_content '102'
    end
    assert_value 'tonkin', "name"
  end
  
  def test_import
    login_as FactoryGirl.create(:administrator)
    visit '/admin/people'
    assert page.has_selector? 'people_file'
  end
end
