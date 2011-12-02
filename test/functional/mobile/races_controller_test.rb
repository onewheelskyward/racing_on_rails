require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class RacesControllerTest < ActionController::TestCase
  def test_event
    @request.host = "m.cbra.org"
    race = FactoryGirl.create(:race)
    get(:index, :event_id => "#{race.event.to_param}")
    assert_response(:success)
    assert_template("races/event")
    assert_not_nil(assigns["evemt"], "Should assign @event")
  end
end