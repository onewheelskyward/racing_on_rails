require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class OverallTest < ActiveSupport::TestCase
  class TestOverall < Overall
  end
  
  test "calculate with no series" do
    assert_no_difference "Competition.count" do
      TestOverall.calculate!
      TestOverall.calculate! 2007
    end
  end

  def test_preliminary_results_after_event_minimum
    series = Series.create!(:name => "Cascade Cross Series")
    series.children.create!(:date => Date.new(2007, 10, 7))

    series.children.create!(:date => Date.new(2007, 10, 14))
    series.children.create!(:date => Date.new(2007, 10, 21))
    series.children.create!(:date => Date.new(2007, 10, 28))
    series.children.create!(:date => Date.new(2007, 11, 5))

    men_a = Category.find_or_create_by_name("Men A")
    men_a_race = series.children[0].races.create!(:category => men_a)
    men_a_race.results.create!(:place => 1, :person => people(:weaver))
    men_a_race.results.create!(:place => 2, :person => people(:tonkin))
    
    men_a_race = series.children[1].races.create!(:category => men_a)
    men_a_race.results.create!(:place => 43, :person => people(:weaver))

    men_a_race = series.children[2].races.create!(:category => men_a)
    men_a_race.results.create!(:place => 1, :person => people(:weaver))

    men_a_race = series.children[3].races.create!(:category => men_a)
    men_a_race.results.create!(:place => 8, :person => people(:tonkin))

    CascadeCrossOverall.calculate!(2007)
    
    men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
    assert_not_nil(men_a_overall_race, "Should have Men A overall race")
    men_a_overall_race.results(true).sort!
    result = men_a_overall_race.results.first
    assert_equal(false, result.preliminary?, "Weaver did three races. His result should not be preliminary")
    
    result = men_a_overall_race.results.last
    assert_equal(false, result.preliminary?, "Tonkin did two races. His result should not be preliminary")
  end
  
  def test_raced_minimum_events_boundaries
    series = Series.create!(:name => "Cascade Cross Series")
    men_a = Category.find_or_create_by_name("Men A")
    molly = people(:molly)
    event = series.children.create!(:date => Date.new(2007, 10, 7))
    
    # Molly does three races in different categories
    men_a_race = event.races.create!(:category => men_a)
    men_a_race.results.create!(:place => 6, :person => molly)
    single_speed_race = event.races.create!(:category => categories(:single_speed))
    single_speed_race.results.create!(:place => 8, :person => molly)
    masters_men_race = event.races.create!(:category => Category.find_or_create_by_name("Masters Men A 40+"))
    masters_men_race.results.create!(:place => 10, :person => molly)
    
    men_a_race.results.create!(:place => 17, :person => people(:alice))

    CascadeCrossOverall.calculate!(2007)
    men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
    assert(!series.overall.raced_minimum_events?(molly, men_a_overall_race), "One event. No people have raced minimum")
    assert(!series.overall.raced_minimum_events?(people(:alice), men_a_overall_race), "One event. No people have raced minimum")
    
    event = series.children.create!(:date => Date.new(2007, 10, 14))
    men_a_race = event.races.create!(:category => men_a)
    men_a_race.results.create!(:place => 14, :person => molly)
    men_a_race.results.create!(:place => 6, :person => people(:alice))

    CascadeCrossOverall.calculate!(2007)
    men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
    assert(series.overall.raced_minimum_events?(molly, men_a_overall_race), "Two events. Molly has raced minimum")
    assert(series.overall.raced_minimum_events?(people(:alice), men_a_overall_race), "Two events. Alice hasraced minimum")

    event = series.children.create!(:date => Date.new(2007, 10, 21))
    men_a_race = event.races.create!(:category => men_a)
    men_a_race.results.create!(:place => "DNF", :person => molly)
    single_speed_race = event.races.create!(:category => categories(:single_speed))
    single_speed_race.results.create!(:place => 8, :person => people(:alice))
    
    CascadeCrossOverall.calculate!(2007)
    men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
    assert(series.overall.raced_minimum_events?(molly, men_a_overall_race), "Three events. Molly has raced minimum")
    assert(series.overall.raced_minimum_events?(people(:alice), men_a_overall_race), "Three events. Alice has raced minimum")

    event = series.children.create!(:date => Date.new(2007, 10, 28))
    men_a_race = event.races.create!(:category => men_a)
    
    CascadeCrossOverall.calculate!(2007)
    men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
    assert(series.overall.raced_minimum_events?(molly, men_a_overall_race), "Four events. Molly has raced minimum")
    assert(series.overall.raced_minimum_events?(people(:alice), men_a_overall_race), "Four events. Alice has raced minimum")
  end
  
  def test_minimum_events_should_handle_results_without_person
    series = Series.create!(:name => "Cascade Cross Series")
    men_a = Category.find_or_create_by_name("Men A")
    event = series.children.create!(:date => Date.new(2007, 10, 7))

    men_a_race = event.races.create!(:category => men_a)
    men_a_race.results.create!(:place => 17)

    CascadeCrossOverall.calculate!(2007)
    men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
    assert(!series.overall.raced_minimum_events?(nil, men_a_overall_race), "Nil person should never have mnimum events")
  end
  
  def test_count_six_best_results
    series = Series.create!(:name => "Cascade Cross Series")
    men_a = Category.find_or_create_by_name("Men A")
    person = Person.create!(:name => "Kevin Hulick")

    date = Date.new(2008, 10, 19)
    [8, 3, 10, 7, 8, 7, 8].each do |place|
      series.children.create!(:date => date).races.create!(:category => men_a).results.create!(:place => place, :person => person)
      date = date + 7
    end
    
    # Simulate 7 of 8 events. Last, double-point event still in future
    series.children.create!(:date => date).races.create!(:category => men_a)
    
    CascadeCrossOverall.calculate!(2008)
    
    men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
    assert_not_nil(men_a_overall_race, "Should have Men A overall race")
    men_a_overall_race.results(true).sort!
    result = men_a_overall_race.results.first
    assert_equal(6, result.scores.size, "Scores")
    assert_equal(16 + 12 + 12 + 11 + 11 + 11, result.points, "points")
  end
  
  def test_choose_best_results_by_place
    series = Series.create!(:name => "Cascade Cross Series")
    men_a = Category.find_or_create_by_name("Men A")
    person = Person.create!(:name => "Kevin Hulick")

    date = Date.new(2008, 10, 19)
    [8, 8, 8, 7, 6, 8, 7, 9].each do |place|
      series.children.create!(:date => date).races.create!(:category => men_a).results.create!(:place => place, :person => person)
      date = date + 7
    end

    CascadeCrossOverall.calculate!(2008)
    
    men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
    assert_not_nil(men_a_overall_race, "Should have Men A overall race")
    men_a_overall_race.results(true).sort!
    result = men_a_overall_race.results.first
    assert_equal(6, result.scores.size, "Scores")
    assert_equal(11 + 12 + 13 + 11 + 12 + 11, result.points, "points")
  end
  
  def test_ensure_dnf_sorted_correctly
    series = Series.create!(:name => "Cascade Cross Series")
    men_a = Category.find_or_create_by_name("Men A")
    person = Person.create!(:name => "Kevin Hulick")

    date = Date.new(2008, 10, 19)
    [8, 3, 10, "DNF", 8, 7, 8].each do |place|
      series.children.create!(:date => date).races.create!(:category => men_a).results.create!(:place => place, :person => person)
      date = date + 7
    end
    
    # Simulate 7 of 8 events. Last, double-point, event, still in future
    series.children.create!(:date => date).races.create!(:category => men_a)
    
    CascadeCrossOverall.calculate!(2008)
    
    men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
    assert_not_nil(men_a_overall_race, "Should have Men A overall race")
    men_a_overall_race.results(true).sort!
    result = men_a_overall_race.results.first
    assert_equal(6, result.scores.size, "Scores")
    assert_equal(16 + 12 + 11 + 11 + 11 + 9, result.points, "points")
  end

  def test_ignore_age_graded_bar
    series = Series.create!(:name => "Cascade Cross Series")
    men_a = Category.find_or_create_by_name("Men A")
    series.children.create!(:date => Date.new(2007, 10, 7))
    event = series.children.create!(:date => Date.new(2007, 10, 14))

    men_a_race = event.races.create!(:category => men_a)
    men_a_race.results.create!(:place => 17, :person => people(:alice))

    age_graded_race = AgeGradedBar.create!(:name => "Age Graded Results for BAR/Championships").races.create!(:category => men_a)
    age_graded_race.results.create!(:place => 1, :person => people(:alice))

    CascadeCrossOverall.calculate!(2007)
    
    men_a_overall_race = series.overall(true).races.detect { |race| race.category == men_a }
    assert_equal(1, men_a_overall_race.results.size, "Cat A results")
    assert_equal(1, men_a_overall_race.results.first.scores.size, "Should ignore age-graded BAR")
  end

  def test_should_not_count_for_bar_nor_ironman
    series = Series.create!(:name => "Cascade Cross Series")
    men_a = Category.find_or_create_by_name("Men A")
    series.children.create!(:date => Date.new(2008)).races.create!(:category => men_a).results.create!(:place => "4", :person => people(:tonkin))

    CascadeCrossOverall.calculate!(2008)
    series.reload
    
    overall_results = series.overall(true)
    assert_equal(false, overall_results.ironman, "Ironman")
    assert_equal(0, overall_results.bar_points, "BAR points")

    men_a_overall_race = overall_results.races.detect { |race| race.category == men_a }
    assert_equal(0, men_a_overall_race.bar_points, "Race BAR points")
  end
  
  test "date should be calculated from children" do
    fail
  end
  
  test "date validation" do
  end
end


