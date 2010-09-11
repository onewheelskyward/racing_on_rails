# BAR = Best All-around Rider
# FIXME Add test for overall and make logic cleaner
class BarController < ApplicationController
  def index
    @overall_bar = OverallBar.find_for_year
    expires_in 10.minutes, :public => true
  end

  # Default to Overall BAR with links to disciplines
  def show
    year = params['year'].to_i

    discipline = Discipline[params['discipline']]
    if discipline.nil?
      flash.now[:warn] = "Could not find discipline \'#{params['discipline']}\'"
      return render(:show)
    end
    
    if year < 2007 && discipline == Discipline[:age_graded]
      return redirect_to("http://#{RacingAssociation.current.static_host}/bar/#{year}/overall_by_age.html")
    elsif year < 2006 && year >= 2001
      return redirect_to("http://#{RacingAssociation.current.static_host}/bar/#{year}")
    end
    
    @overall_bar = OverallBar.find_for_year(year)
    unless @overall_bar
      flash.now[:warn] = "Could not find Overall BAR for #{year}"
      return render(:show)
    end

    category = @overall_bar.equivalent_category_for(params[:category], discipline)
    unless category
      flash.now[:warn] = "Could not find BAR category \'#{params['category']}\'"
      return render(:show)
    end
    return redirect_to(:category => category.friendly_param) if category.friendly_param != params["category"]
    
    @race = @overall_bar.find_race(discipline, category)
    unless @race
      flash.now[:warn] = "Could not find results"
      return render(:show)
    end
    
    # Optimization
    @results = Result.find(:all, 
                           :include => [ :person, :team ],
                           :conditions => [ 'race_id = ?', @race.id ]
    ) if @race
    expires_in 10.minutes, :public => true
  end
  
  # BAR category mappings
  def categories
    @year = params['year'] || Date.today.year.to_s
    date = Date.new(@year.to_i, 1, 1)
    @bar = Bar.find(:first, :conditions => ['date = ?', date])
    @excluded_categories = Category.find(:all, :conditions => ['parent_id is null'])
    expires_in 10.minutes, :public => true
  end
end
