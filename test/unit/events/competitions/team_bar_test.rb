require File.expand_path("../../../../test_helper", __FILE__)

# :stopdoc:
class TeamBarTest < ActiveSupport::TestCase
  def test_extract_teams_from
    bar = TeamBar.new

    source_result = Result.new
    assert_equal [], bar.extract_teams_from(source_result), "no teams"

    source_result = FactoryGirl.create(:result)
    assert_equal [ source_result.team ], bar.extract_teams_from(source_result), "team"

    team_1 = FactoryGirl.create(:team, :name => "Gentle Lovers")
    team_2 = FactoryGirl.create(:team, :name => "Vanilla")
    team = FactoryGirl.create(:team, :name => "Gentle Lovers/Vanilla")
    category = FactoryGirl.create(:category, :name => "Tandem")
    race = FactoryGirl.create(:race, :category => category)
    source_result = FactoryGirl.create(:result, :team => team, :race => race)
    assert_equal [ team_1, team_2 ], bar.extract_teams_from(source_result).sort_by(&:name), "teams"
  end
  
  def test_calculate
    association_category = FactoryGirl.create(:category, :name => "CBRA")
    team                 = FactoryGirl.create(:category, :name => "Team", :parent => association_category)
    senior_men           = FactoryGirl.create(:category, :name => "Senior Men", :parent => association_category)
    men_a                = FactoryGirl.create(:category, :name => "Men A", :parent => senior_men)
    sr_p_1_2             = FactoryGirl.create(:category, :name => "Senior Men Pro 1/2", :parent => senior_men)
    senior_women         = FactoryGirl.create(:category, :name => "Senior Women", :parent => association_category)
    
    discipline = FactoryGirl.create(:discipline, :name => "Road")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women
    discipline.bar_categories << team
    
    discipline = FactoryGirl.create(:discipline, :name => "Time Trial")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women
    discipline.bar_categories << team

    discipline = FactoryGirl.create(:discipline, :name => "Cyclocross")
    discipline.bar_categories << men_a
    discipline.bar_categories << team

    discipline = FactoryGirl.create(:discipline, :name => "Track")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women
    discipline.bar_categories << team

    discipline = FactoryGirl.create(:discipline, :name => "Criterium")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women
    discipline.bar_categories << team
    
    discipline = FactoryGirl.create(:discipline, :name => "Team")
    discipline.bar_categories << senior_men
    discipline.bar_categories << senior_women
    discipline.bar_categories << team

    kona = FactoryGirl.create(:team, :name => "Kona")
    gentle_lovers = FactoryGirl.create(:team, :name => "Gentle Lovers")
    vanilla = FactoryGirl.create(:team, :name => "Vanilla")
    
    tonkin = FactoryGirl.create(:person, :name => "Tonkin", :team => kona)
    weaver = FactoryGirl.create(:person, :name => "Weaver", :team => gentle_lovers)
    molly = FactoryGirl.create(:person, :name => "Molly", :team => vanilla)
    alice = FactoryGirl.create(:person, :name => "Alice", :team => gentle_lovers)
    matson = FactoryGirl.create(:person, :name => "Matson", :team => kona)

    cross_crusade = Series.create!(:name => "Cross Crusade")
    barton = SingleDayEvent.create!(
      :name => "Cross Crusade: Barton Park",
      :discipline => "Cyclocross",
      :date => Date.new(2004, 11, 7),
      :parent => cross_crusade
    )
    barton_a = barton.races.create(:category => men_a, :field_size => 5)
    barton_a.results.create(
      :place => 3,
      :person => tonkin
    )
    barton_a.results.create(
      :place => 15,
      :person => weaver
    )
    
    swan_island = SingleDayEvent.create!(
      :name => "Swan Island",
      :discipline => "Criterium",
      :date => Date.new(2004, 5, 17),
    )
    swan_island_senior_men = swan_island.races.create(:category => senior_men, :field_size => 4)
    swan_island_senior_men.results.create(
      :place => 12,
      :person => tonkin
    )
    swan_island_senior_men.results.create(
      :place => 2,
      :person => molly
    )
    # No BAR points
    senior_women_swan_island = swan_island.races.create(:category => senior_women, :field_size => 3, :bar_points => 0)
    senior_women_swan_island.results.create(
      :place => 1,
      :person => molly
    )
    
    thursday_track_series = Series.create!(:name => "Thursday Track")
    thursday_track = SingleDayEvent.create!(
      :name => "Thursday Track",
      :discipline => "Track",
      :date => Date.new(2004, 5, 12),
      :parent => thursday_track_series
    )
    thursday_track_senior_men = thursday_track.races.create(:category => senior_men, :field_size => 6)
    r = thursday_track_senior_men.results.create(
      :place => 5,
      :person => weaver
    )
    thursday_track_senior_men.results.create(
      :place => 14,
      :person => tonkin,
      :team => kona
    )
    
    team_track = SingleDayEvent.create!(
      :name => "Team Track State Championships",
      :discipline => "Track",
      :date => Date.new(2004, 9, 1),
      :bar_points => 2
    )
    team_track_senior_men = team_track.races.create(:category => senior_men, :field_size => 6)
    team_track_senior_men.results.create(
      :place => 1,
      :person => weaver,
      :team => kona
    )
    team_track_senior_men.results.create(
      :place => 1,
      :person => tonkin,
      :team => kona
    )
    team_track_senior_men.results.create(
      :place => 1,
      :person => molly
    )
    team_track_senior_men.results.create(
      :place => 5,
      :person => alice
    )
    team_track_senior_men.results.create(
      :place => 5,
      :person => matson
    )
    # Weaver and Erik's second ride should not count
    team_track_senior_men.results.create(
      :place => 15,
      :person => weaver,
      :team => kona
    )
    team_track_senior_men.results.create(
      :place => 15,
      :person => tonkin,
      :team => kona
    )
    
    larch_mt_hillclimb = SingleDayEvent.create!(
      :name => "Larch Mountain Hillclimb",
      :discipline => "Time Trial",
      :date => Date.new(2004, 2, 1)
    )
    larch_mt_hillclimb_senior_men = larch_mt_hillclimb.races.create(:category => senior_men, :field_size => 6)
    larch_mt_hillclimb_senior_men.results.create(
      :place => 13,
      :person => tonkin,
      :team => kona
    )
  
    event = FactoryGirl.create(:event, :date => Date.new(2004), :name => "Banana Belt")
    race = event.races.create!(:category => sr_p_1_2)
    race.results.create!(:place => "1", :person => tonkin, :team => kona)
    race.results.create!(:place => "3", :person => matson, :team => kona)

    event = FactoryGirl.create(:event, :date => Date.new(2004), :name => "Kings Valley")
    race = event.races.create!(:category => senior_women)
    race.results.create!(:place => "2", :person => alice, :team => gentle_lovers)
    race.results.create!(:place => "15", :person => molly, :team => vanilla)

    assert_equal(0, TeamBar.count, "TeamBar before calculate!")
    Bar.calculate!(2004)
    TeamBar.any_instance.expects(:expire_cache).at_least_once
    assert_difference "Result.count", 3 do
      TeamBar.calculate!(2004)
    end
    assert_equal(1, TeamBar.count, "TeamBar events after calculate!")
    bar = TeamBar.first(:conditions => ['date = ?', Date.new(2004, 1, 1)])
    assert_not_nil(bar, "2004 TeamBar after calculate!")
    assert_equal(Date.new(2004, 1, 1), bar.date, "2004 TeamBar date")
    assert_equal("2004 Team BAR", bar.name, "2004 Team Bar name")
    assert_equal_dates(Time.zone.today, bar.updated_at, "BAR last updated")
    
    assert_equal(1, bar.races.size, 'Should have only one Team BAR race')
    team_race = bar.races.first
    
    assert_equal(3, team_race.results.size, "Team BAR results")
    assert_equal_dates(Time.zone.today, team_race.updated_at, "BAR last updated")

    team_race.results.sort!
    assert_equal(kona, team_race.results[0].team, "Team BAR results team")
    assert_equal("1", team_race.results[0].place, "Team BAR results place")
    assert_in_delta(53, team_race.results[0].points, 0.0, "Team BAR results points")

    assert_equal(gentle_lovers, team_race.results[1].team, "Team BAR results team")
    assert_equal("2", team_race.results[1].place, "Team BAR results place")
    assert_equal(14, team_race.results[1].points, "Team BAR results points")

    assert_equal(vanilla, team_race.results[2].team, "Team BAR results team")
    assert_equal("3", team_race.results[2].place, "Team BAR results place")
    assert_equal(1, team_race.results[2].points, "Team BAR results points")

    # check placings for ties
    # remove one-day licensees
  end
end
