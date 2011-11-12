require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
# Check we can call these methods with errors.
# Actual values are going to differ between sites.
class RacingAssociationTest < ActiveSupport::TestCase
  def test_now
    assert Time.now + 10 >= RacingAssociation.current.now, "Default RacingAssociation.current.now should be close to Time.now"

    RacingAssociation.current.now = Time.local(2020, 4, 5, 23, 50, 55)
    assert_equal Time.local(2020, 4, 5, 23, 50, 55), RacingAssociation.current.now, "Can override RacingAssociation.current.now"

    RacingAssociation.current.now = nil
    assert Time.now + 10 >= RacingAssociation.current.now, "Default RacingAssociation.current.now should be close to Time.now after set to nil"
  end
  
  def test_today
    assert_equal_dates Date.today, RacingAssociation.current.today, "Default RacingAssociation.current.today"

    RacingAssociation.current.now = Time.local(2020, 4, 5, 23, 50, 55)
    assert_equal_dates Date.new(2020, 4, 5), RacingAssociation.current.today, "Override RacingAssociation.current.now to change RacingAssociation.current.today"

    RacingAssociation.current.now = nil
    assert_equal_dates Date.today, RacingAssociation.current.today, "Default RacingAssociation.current.today should be Date.today after RacingAssociation.current.now is set to nil"
  end
  
  def test_effective_year
    RacingAssociation.current.now = Time.local(2020, 1, 1)
    assert_equal 2020, RacingAssociation.current.effective_year, "effective year for January 2020"

    RacingAssociation.current.now = Time.local(2020, 11, 30)
    assert_equal 2020, RacingAssociation.current.effective_year, "effective year for November 2020"

    RacingAssociation.current.now = Time.local(2020, 12, 1)
    assert_equal 2021, RacingAssociation.current.effective_year, "effective year for December 2020"

    RacingAssociation.current.now = Time.local(2020, 12, 31)
    assert_equal 2021, RacingAssociation.current.effective_year, "effective year for December 2020"
  end
  
  def test_next_year
    RacingAssociation.current.now = Time.local(2020, 1, 1)
    assert_equal 2021, RacingAssociation.current.next_year, "next_year for January 2020"

    RacingAssociation.current.now = Time.local(2020, 11, 30)
    assert_equal 2021, RacingAssociation.current.next_year, "next_year for November 2020"

    RacingAssociation.current.now = Time.local(2020, 12, 1)
    assert_equal 2021, RacingAssociation.current.next_year, "next_year for December 2020"

    RacingAssociation.current.now = Time.local(2020, 12, 31)
    assert_equal 2021, RacingAssociation.current.next_year, "next_year for December 2020"
  end
end
