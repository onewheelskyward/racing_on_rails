module Concerns
  module Event
    module Dates
      extend ActiveSupport::Concern
      
      module ClassMethods
        # Return list of every year that has at least one event
        def find_all_years
          years = [ RacingAssociation.current.effective_year ] +
          connection.select_values(
            "select distinct year from events"
          ).map(&:to_i)
          years = years.uniq.sort

          if years.size == 1
            years
          else
            ((years.first)..(years.last)).to_a.reverse
          end
        end
      end
      
      module InstanceMethods
        def default_date
          if parent.present?
            parent.date
          else
            Time.zone.today
          end
        end

        def date=(value)
          case value
          when String
            self.year = Date.parse(value).year
          when nil
            self.year = nil
          else
            self.year = value.year
          end
          self[:date] = value
        end

        # Format for schedule page primarily
        def short_date
          return '' unless date
          prefix = ' ' if date.month < 10
          suffix = ' ' if date.day < 10
          "#{prefix}#{date.month}/#{date.day}#{suffix}"
        end

        def date_range_s(format = :short)
          if format == :long
            date.strftime('%m/%d/%Y')
          else
            "#{date.month}/#{date.day}"
          end
        end

        def date_range_long_s
          date.to_s :long_with_week_day
        end

        # +date+
        def start_date
          date
        end

        def start_date=(date)
          self.date = date
        end

        def end_date
          if children.any?
            children.sort.last.date
          else
            start_date
          end
        end

        def year
          self[:year] || date.try(:year)
        end

        def multiple_days?
          end_date > start_date
        end

        # Does nothing. Allows us to treat Events and MultiDayEvents the same.
        def update_date
        end

      end
    end
  end
end
