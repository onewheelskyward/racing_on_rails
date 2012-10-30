# Only here to support CombinedTimeTrialResults
class ResultObserver < ActiveRecord::Observer
  def after_destroy(result)
    return true if result.competition_result? || !result.event(true).notification_enabled?
    combined_results = CombinedTimeTrialResults.create_or_destroy_for!(result.event)
    result.event.combined_results.calculate! if result.event.combined_results
    true
  end

  def after_save(result)
    return true if result.competition_result? || !result.event(true).notification_enabled?
    combined_results = CombinedTimeTrialResults.create_or_destroy_for!(result.event)
    combined_results.calculate! unless combined_results.nil?
    true
  end
end
