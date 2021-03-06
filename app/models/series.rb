# MultiDayEvent with events on several, non-contiguous days
#
# This class doesn't add any special behavior to MultiDayEvent, but it is 
# convential to separate events like stage races from series like the 
# Cross Crusade
class Series < MultiDayEvent

  def Series.find_all_by_year(year)
    logger.debug("Series.find_all_by_year(year)")
    start_of_year = Date.new(year, 1, 1)
    end_of_year = Date.new(year, 12, 31)
    return Series.all(
      :conditions => ["date >= ? and date <= ?", start_of_year, end_of_year],
      :order => "date"
    )
  end
end