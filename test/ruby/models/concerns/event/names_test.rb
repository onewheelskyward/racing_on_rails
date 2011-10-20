require File.expand_path("../../../../test_case", __FILE__)
require File.expand_path("../../../../../../app/models/concerns/event/comparison", __FILE__)

# :stopdoc:
class Concerns::Event::NamesTest < Ruby::TestCase

  def test_full_name
    event = SingleDayEvent.create!(:name => 'Reheers', :discipline => 'Mountain Bike')
    assert_equal('Reheers', event.full_name, 'full_name')
    
    series = Series.create!(:name => 'Bend TT Series')
    series_event = series.children.create!(:name => 'Bend TT Series', :date => Date.new(2009, 4, 19))
    assert_equal('Bend TT Series', series_event.full_name, 'full_name when series name is same as event')

    stage_race = events(:mt_hood)
    stage = stage_race.children.create!(:name => stage_race.name)
    assert_equal('Mt. Hood Classic', stage.full_name, 'stage race stage full_name')

    stage_race = events(:mt_hood)
    stage = stage_race.children.create!(:name => stage_race.name)
    event = stage.children.create!(:name => 'Cooper Spur Road Race')
    assert_equal('Mt. Hood Classic: Cooper Spur Road Race', event.full_name, 'stage race event full_name')

    stage_race = MultiDayEvent.create!(:name => 'Cascade Classic')
    stage = stage_race.children.create!(:name => 'Cascade Classic')
    event = stage.children.create!(:name => 'Cascade Classic - Cascade Lakes Road Race')
    assert_equal('Cascade Classic - Cascade Lakes Road Race', event.full_name, 'stage race results full_name')

    stage_race = MultiDayEvent.create!(:name => 'Frozen Flatlands Omnium')
    event = stage_race.children.create!(:name => 'Frozen Flatlands Time Trial')
    assert_equal('Frozen Flatlands Omnium: Frozen Flatlands Time Trial', event.full_name, 'stage race results full_name')
  end
  
  def test_full_name_with_date
    event = SingleDayEvent.create!(:name => 'Reheers', :discipline => 'Mountain Bike', :date => Date.new(2010, 1, 2))
    assert_equal('Reheers (1/2)', event.full_name_with_date, 'full_name')
    
    series = Series.create!(:name => 'Bend TT Series', :date => Date.new(2009, 4, 19))
    series_event = series.children.create!(:name => 'Bend TT Series', :date => Date.new(2009, 4, 19))
    assert_equal('Bend TT Series (4/19)', series_event.full_name_with_date, 'full_name when series name is same as event')

    stage_race = events(:mt_hood)
    stage = stage_race.children.create!(:name => stage_race.name, :date => Date.new(2009, 4, 19))
    assert_equal('Mt. Hood Classic (4/19)', stage.full_name_with_date, 'stage race stage full_name')

    stage_race = events(:mt_hood)
    stage = stage_race.children.create!(:name => stage_race.name, :date => Date.new(2009, 4, 19))
    event = stage.children.create!(:name => 'Cooper Spur Road Race')
    assert_equal('Mt. Hood Classic: Cooper Spur Road Race (4/19)', event.full_name_with_date, 'stage race event full_name')
  end
  
  def test_team_name
    assert_equal(nil, Event.new.team_name, "team_name")
    assert_equal("", Event.new(:team => Team.new(:name => "")).team_name, "team_name")
    assert_equal("Vanilla", Event.new(:team => Team.new(:name => "Vanilla")).team_name, "team_name")
  end
end