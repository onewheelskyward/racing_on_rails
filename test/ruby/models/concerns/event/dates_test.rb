require File.expand_path("../../../../test_case", __FILE__)
require File.expand_path("../../../../../../app/models/concerns/event/dates", __FILE__)

# :stopdoc:
class Concerns::Event::DatesTest < Ruby::TestCase
  def test_short_date
    event = Event.new

    event.date = Date.new(2006, 9, 9)
    assert_equal(' 9/9 ', event.short_date, 'Short date')    

    event.date = Date.new(2006, 9, 10)
    assert_equal(' 9/10', event.short_date, 'Short date')    

    event.date = Date.new(2006, 10, 9)
    assert_equal('10/9 ', event.short_date, 'Short date')    

    event.date = Date.new(2006, 10, 10)
    assert_equal('10/10', event.short_date, 'Short date')    
  end

  def test_date_range_s_long
    mt_hood = events(:mt_hood)
    assert_equal("07/11/2005-07/12/2005", mt_hood.date_range_s(:long), "date_range_s(long)")
    last_day = mt_hood.children.last
    last_day.date = Date.new(2005, 8, 1)
    last_day.save!
    mt_hood = Event.find(mt_hood.id)
    assert_equal("07/11/2005-08/01/2005", mt_hood.date_range_s(:long), "date_range_s(long)")

    kings_valley = events(:kings_valley)
    assert_equal("12/31/2003", kings_valley.date_range_s(:long), "date_range_s(long)")
  end

end