class CompetitionsController < ApplicationController
  caches_page :show, :if => Proc.new { |c| !mobile_request? }
  
  def show
    @year = params['year'] || Time.zone.today.year.to_s
    date = Date.new(@year.to_i, 1, 1)

    # Very explicit because we don't want to call something like 'eval' on a request parameter!
    if params[:type] == "rider_rankings"
      competition_class = RiderRankings
    elsif params[:type] == "cat4_womens_race_series"
      competition_class = Cat4WomensRaceSeries
    elsif params[:type] == "wsba_barr"
      competition_class = WsbaBarr
    elsif params[:type] == "wsba_masters_barr"
      competition_class = WsbaMastersBarr
    elsif params[:type] == "mbra_bar"
      competition_class = MbraBar
    else
      raise ActiveRecord::RecordNotFound.new("No competition of type: #{params[:type]}")
    end
    @event = competition_class.first(:conditions => ['date = ?', date])
    
    if @event
      @event.races.reject! do |race|
        race.results.empty?
      end
    else
      @event = competition_class.new(:date => date)
    end
  end
end
