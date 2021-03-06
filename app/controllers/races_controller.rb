class RacesController < ApplicationController

  # Show Races for a Category
  # === Params
  # * id: Category ID
  # === Assigns
  # * races
  # * category
  def index
    if params[:event_id]
      @event = Event.includes(:races).find(params[:event_id])
      unless mobile_request?
        redirect_to event_results_path(@event)
      end
    else
      if mobile_request?
        return redirect_to_full_site
      end
      @category = Category.find(params[:category_id])
    end
  end
  
  def show
    @race = Race.find(params[:id])
    unless mobile_request?
      redirect_to event_results_path(@race.event)
    end
  end
end
