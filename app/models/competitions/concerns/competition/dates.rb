module Concerns
  module Competition
    module Dates
      extend ActiveSupport::Concern

      included do
        validate :valid_dates
      end

      module InstanceMethods
        def default_date
          Time.zone.now.beginning_of_year
        end

        # Same as +date+. Should always be January 1st
        def start_date
          date
        end

        # Last day of year for +date+
        def end_date
          Time.zone.local(year).end_of_year
        end

        def date_range_long_s
          if multiple_days?
            "#{start_date.strftime('%a, %B %d')} to #{end_date.strftime('%a, %B %d, %Y')}"
          else
            start_date.strftime('%a, %B %d')
          end
        end

        def multiple_days?
          source_events.count > 1
        end

        # Assert start and end dates are first and last days of the year
        def valid_dates
          if source_events.empty?
            if !start_date || start_date.month != 1 || start_date.day != 1
              errors.add "start_date", "Start date must be January 1st"
            end
            if !end_date || end_date.month != 12 || end_date.day != 31
              errors.add "end_date", "End date must be December 31st"
            end
          end
        end
      end
    end
  end
end
