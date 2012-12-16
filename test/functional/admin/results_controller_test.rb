require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class Admin::ResultsControllerTest < ActionController::TestCase
  def setup
    super
    create_administrator_session
    use_ssl
  end
  
  def test_update_no_team
    result = FactoryGirl.create(:result, :team => nil)
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "team_name",
        :value => ""
    assert_response(:success)

    result.reload
    assert_nil(result.team(true), 'team')
  end
  
  def test_update_no_team_to_existing
    result = FactoryGirl.create(:result, :team => nil)
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "team_name",
        :value => "Vanilla"

    assert_response(:success)

    result.reload
    assert_equal("Vanilla", result.team(true).name, 'team')
  end
  
  def test_update_no_team_to_new
    result = FactoryGirl.create(:result, :team => nil)

    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "team_name",
        :value => "Team Vanilla"
    assert_response(:success)

    result.reload
    assert_equal("Team Vanilla", result.team(true).name, "team name")
  end
  
  def test_update_no_team_to_alias
    result = FactoryGirl.create(:result, :team => nil)
    gentle_lovers = FactoryGirl.create(:team, :name => "Gentle Lovers")
    gentle_lovers.aliases.create!(:name => "Gentile Lovers")
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "team_name",
        :value => "Gentile Lovers"
    assert_response(:success)

    result.reload
    assert_equal(gentle_lovers, result.team(true), 'team')
  end
  
  def test_update_to_no_team
    result = FactoryGirl.create(:result)
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "team_name",
        :value => ""
    assert_response(:success)

    result.reload
    assert_nil(result.team(true), 'team')
  end
  
  def test_update_to_existing_team
    result = FactoryGirl.create(:result, :team => nil)
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "team_name",
        :value => "Vanilla"
    assert_response(:success)

    result.reload
    assert_equal(vanilla, result.team(true), 'team')
  end
  
  def test_update_to_new_team
    result = FactoryGirl.create(:result, :team => nil)
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "team_name",
        :value => "Astana"
    assert_response(:success)

    result.reload
    assert_equal("Astana", result.team(true).name, 'team name')
  end
  
  def test_update_to_team_alias
    result = FactoryGirl.create(:result)
    gentle_lovers = FactoryGirl.create(:team, :name => "Gentle Lovers")
    gentle_lovers.aliases.create!(:name => "Gentile Lovers")
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "team_name",
        :value => "Gentile Lovers"
    assert_response(:success)

    result.reload
    assert_equal(gentle_lovers, result.team(true), 'team')
  end
  
  def test_set_result_points
    result = FactoryGirl.create(:result)

    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "points",
        :value => "12"
    assert_response(:success)

    result.reload
    assert_equal(12, result.points, 'points')
  end
  
  def test_update_no_person
    result = FactoryGirl.create(:result, :person => nil)
    original_team_name = result.team_name
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "team_name",
        :value => original_team_name
    assert_response(:success)

    result.reload
    assert_equal(nil, result.first_name, 'first_name')
    assert_equal(nil, result.last_name, 'last_name')
    assert_equal(original_team_name, result.team_name, 'team_name')
    assert_nil(result.person(true), 'person')
  end
  
  def test_update_no_person_to_existing
    result = FactoryGirl.create(:result, :person => nil)
    tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
    tonkin.aliases.create!(:name => "Eric Tonkin")
    original_team_name = result.team_name
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "name",
        :value => "Erik Tonkin"
    assert_response(:success)
    
    result.reload
    assert_equal("Erik Tonkin", result.name, 'name')
    assert_equal(original_team_name, result.team_name, 'team_name')
    assert_equal(tonkin, result.person(true), 'person')
    assert_equal(1, tonkin.aliases.size)
  end
  
  def test_update_no_person_to_alias
    result = FactoryGirl.create(:result, :person => nil)
    tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
    tonkin.aliases.create!(:name => "Eric Tonkin")

    original_team_name = result.team_name
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "name",
        :value => "Eric Tonkin"
    assert_response(:success)

    result.reload
    assert_equal('Erik Tonkin', result.name, 'name')
    assert_equal(original_team_name, result.team_name, 'team_name')
    assert_equal(tonkin, result.person(true), 'person')
    assert_equal(1, tonkin.aliases.size)
  end
  
  def test_update_to_no_person
    result = FactoryGirl.create(:result)

    original_team_name = result.team_name
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "name",
        :value => ""
    assert_response(:success)

    result.reload
    assert_equal(nil, result.first_name, 'first_name')
    assert_equal(nil, result.last_name, 'last_name')
    assert_equal(original_team_name, result.team_name, 'team_name')
    assert_nil(result.person(true), 'person')
  end
  
  def test_update_to_different_person
    result = FactoryGirl.create(:result, :person => nil)
    tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
    tonkin.aliases.create!(:name => "Eric Tonkin")

    original_team_name = result.team_name
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "name",
        :value => "Erik Tonkin"
    assert_response(:success)

    result.reload
    assert_equal("Erik", result.first_name, 'first_name')
    assert_equal("Tonkin", result.last_name, 'last_name')
    assert_equal(original_team_name, result.team_name, 'team_name')
    assert_equal(tonkin, result.person(true), 'person')
    assert_equal(1, tonkin.aliases.size)
  end
  
  def test_update_to_alias
    result = FactoryGirl.create(:result, :person => nil)
    tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
    tonkin.aliases.create!(:name => "Eric Tonkin")
    original_team_name = result.team_name
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "name",
        :value => "Eric Tonkin"
    assert_response(:success)
    
    result.reload
    assert_equal(tonkin, result.person, "Result person")
    assert_equal('Erik', result.first_name, 'first_name')
    assert_equal("Tonkin", result.last_name, 'last_name')
    assert_equal(original_team_name, result.team_name, 'team_name')
    assert_equal(tonkin, result.person(true), 'person')
    assert_equal(1, tonkin.aliases.size)
  end
  
  def test_update_to_new_person
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline)
    
    weaver = FactoryGirl.create(:person, :first_name => "Ryan", :last_name => "Weaver")
    FactoryGirl.create_list(:result, 3, :person => weaver)
    result = FactoryGirl.create(:result, :person => weaver)
    
    xhr :put,
        :update_attribute,
        :id => result.to_param,
        :name => "name",
        :value => "Stella Carey"

    assert_response :success

    result = Result.find(result.id)
    assert_equal "Stella", result.first_name, "first_name"
    assert_equal "Carey", result.last_name, "last_name"
    assert weaver != result.person, "Result should be associated with a different person"
    assert_equal 0, result.person.aliases.size, "Result person aliases"
    assert_equal 1, result.person.results.size, "Result person results"
    weaver = Person.find(weaver.id)
    assert_equal 0, weaver.aliases.size, "Weaver aliases"
    assert_equal "Ryan", weaver.first_name, "first_name"
    assert_equal "Weaver", weaver.last_name, "last_name"
    assert_equal 3, weaver.results.size, "results"
  end
  
  def test_person
    weaver = FactoryGirl.create(:result).person

    get(:index, :person_id => weaver.to_param.to_s)
    
    assert_not_nil(assigns["results"], "Should assign results")
    assert_equal(weaver, assigns["person"], "Should assign person")
    assert_response(:success)
  end
  
  def test_find_person
    FactoryGirl.create(:person, :first_name => "Ryan", :last_name => "Weaver")
    tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")
    post(:find_person, :name => 'e', :ignore_id => tonkin.id)    
    assert_response(:success)
    assert_template('admin/results/_people')
  end
  
  def test_find_person_one_result
    weaver = FactoryGirl.create(:person)
    tonkin = FactoryGirl.create(:person, :first_name => "Erik", :last_name => "Tonkin")

    post(:find_person, :name => weaver.name, :ignore_id => tonkin.id)
    
    assert_response(:success)
    assert_template('admin/results/_person')
  end
  
  def test_find_person_no_results
    tonkin = FactoryGirl.create(:person)
    post(:find_person, :name => 'not a person in the database', :ignore_id => tonkin.id)    
    assert_response(:success)
    assert_template('admin/results/_people')
  end
  
  def test_results
    weaver = FactoryGirl.create(:result).person

    post(:results, :person_id => weaver.id)
    
    assert_response(:success)
    assert_template('admin/results/_person')
  end
  
  def test_scores
    result = FactoryGirl.create(:result)
    post(:scores, :id => result.id, :format => "js")
    assert_response(:success)
  end
  
  def test_move
    weaver = FactoryGirl.create(:result).person
    tonkin = FactoryGirl.create(:person)
    result = FactoryGirl.create(:result, :person => tonkin)

    assert tonkin.results.include?(result)
    assert !weaver.results.include?(result)
    
    post :move, :person_id => weaver.id, :result_id => result.id, :format => "js"
    
    assert !tonkin.results(true).include?(result)
    assert weaver.results(true).include?(result)
    assert_response :success
  end
end
