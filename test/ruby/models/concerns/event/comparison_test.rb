require File.expand_path("../../../../test_case", __FILE__)
require File.expand_path("../../../../../../app/models/concerns/event/comparison", __FILE__)

# :stopdoc:
class Concerns::Event::ComparisonTest < Ruby::TestCase
  
  def test_sort
    jan_event = SingleDayEvent.new(:date => Date.new(1998, 1, 4))
    march_event = MultiDayEvent.new(:date => Date.new(1998, 3, 2))
    nov_event = Series.new(:date => Date.new(1998, 11, 20))
    events = [jan_event, march_event, nov_event]
    
    assert_equal_enumerables([jan_event, march_event, nov_event], events.sort, 'Unsaved events should be sorted by date')
    march_event.date = Date.new(1999)
    assert_equal_enumerables([jan_event, nov_event, march_event], events.sort, 'Unsaved events should be sorted by date')
    
    events.each {|e| e.save!}
    assert_equal_enumerables([jan_event, nov_event, march_event], events.sort, 'Saved events should be sorted by date')
    march_event.date = Date.new(1998, 3, 2)
    assert_equal_enumerables([jan_event, march_event, nov_event], events.sort, 'Saved events should be sorted by date')
  end
  
  def test_equality
    event_1 = SingleDayEvent.create!
    event_2 = SingleDayEvent.create!
    event_1_copy = SingleDayEvent.find(event_1.id)
    
    assert_equal event_1, event_1, "event_1 == event_1"
    assert_equal event_2, event_2, "event_2 == event_2"
    assert event_1 != event_2, "event_1 != event_2"
    assert event_2 != event_1, "event_2 != event_1"
    assert_equal event_1, event_1_copy, "event_1 == event_1_copy"
    assert event_1_copy != event_2, "event_1_copy != event_2"
    assert event_2 != event_1_copy, "event_2 != event_1_copy"
  end
  
  def test_set
    event_1 = SingleDayEvent.create!
    event_2 = SingleDayEvent.create!
    set = Set.new
    set << event_1
    set << event_2
    set << event_1
    set << event_2
    set << event_1
    set << event_2
    
    assert_same_elements [ event_1, event_2 ], set.to_a, "Set equality"
  end
end