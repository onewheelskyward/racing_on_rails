# Who has done the most events? Just counts starts/appearences in results. Not pefect -- some events
# are probably over-counted.
# TODO Don't replace existing results
# FIXME Write tests for new code
class Ironman < Competition
  def self.years
    years = []
    results = connection.select_all(
      "select distinct extract(year from date) as year from events where type = 'Ironman'"
    )
    results.each do |year|
      years << year.values.first.to_i
    end
    years.sort.reverse
  end
  
  # Update results based on source event results.
  # (Calculate clashes with internal Rails method)
  def self.calculate!(year = Time.zone.today.year)
    benchmark(name, :level => :info) {
      transaction do
        year = year.to_i if year.is_a?(String)
        competition = self.find_or_create_for_year(year)
        competition.set_date
        raise(ActiveRecord::ActiveRecordError, competition.errors.full_messages) unless competition.errors.empty?
        competition.create_races
        competition.calculate!
      end
    }
    # Don't return the entire populated instance!
    true
  end

  def friendly_name
    'Ironman'
  end

  def points_for(source_result)
    1
  end
  
  def break_ties?
    false
  end
  
  # Rebuild results
  # Override superclass for now. Superclass method duplicates calculations aldready done by Calculator.
  def calculate!
    races.each do |race|
      results = source_results_with_benchmark(race)
      calculated_results = Competitions::Calculator.calculate(results, dnf: true)
      
      # TODO Apply same logic for scores
      new_results, existing_results, old_results = partition_results(calculated_results, race)
      create_competition_results_for new_results, race
      update_competition_results_for existing_results, race
      delete_competition_results_for old_results, race
    end
    
    after_calculate
    save!
  end

  # Results as array of hashes. Select fewest fields needed to calculate results.
  # Some competition rules applied here in the query and results excluded. It's a judgement call to apply them here
  # rather than in #calculate.
  def source_results(race)
    query = Result.
      select(["results.id as id", "person_id", "people.member_from", "people.member_to", "place", "results.event_id", "race_id", "events.date"]).
      joins(:race, :event, :person).
      where("place != 'DNS'").
      where("races.category_id is not null").
      where("events.type = 'SingleDayEvent' or events.type = 'Event' or events.type is null").
      where("events.ironman = true").
      where("results.year = ?", year)

    Result.connection.select_all query
  end
  
  def partition_results(calculated_results, race)
    person_ids            = race.results.map { |r| r.person_id }
    calculated_person_ids = calculated_results.map { |r| r.person_id }

    new_person_ids      = calculated_person_ids - person_ids
    existing_person_ids = calculated_person_ids & person_ids
    old_person_ids      = person_ids - calculated_person_ids
    
    [
      calculated_results.select { |r| r.person_id.in? new_person_ids },
      calculated_results.select { |r| r.person_id.in? existing_person_ids },
      race.results.select       { |r| r.person_id.in? old_person_ids }
    ]
  end
  
  # Similar to superclass's method, except this method only saves results to the database. Superclass applies rules 
  # and scoring, but . It also decorates the results with any display data (often denormalized)
  # like people's names, teams, and points.
  def create_competition_results_for(results, race)
    team_ids = team_ids_by_person_id_hash(results)
    
    results.each do |result|
      competition_result = Result.create!(
        :place              => result.place,
        :person_id          => result.person_id, 
        :team_id            => team_ids[result.person_id],
        :event              => self,
        :race               => race,
        :competition_result => true,
        :points             => result.points
      )
       
      result.scores.each do |score|
        create_score competition_result, score.source_result_id, score.points
      end
    end

    true
  end

  # Can move to superclass or to Result (competition results could know they need to lookup their team)
  def team_ids_by_person_id_hash(results)
    hash = Hash.new
    Person.select("id, team_id").where("id in (?)", results.map(&:person_id).uniq).map do |person|
      hash[person.id] = person.team_id
    end
    hash
  end

  # This is always the 'best' result
  def create_score(competition_result, source_result_id, points)
    Score.create!(
      :source_result_id => source_result_id, 
      :competition_result_id => competition_result.id, 
      :points => points
    )
  end
  
  def update_competition_results_for(results, race)
    team_ids = team_ids_by_person_id_hash(results)

    existing_results = race.results.where("person_id in (?)", results.map(&:person_id)).includes(:scores)
    results.each do |result|
      existing_result = existing_results.detect { |r| r.person_id == result.person_id }
      
      # to_s important. Otherwise, a change from 3 to "3" triggers a DB update.
      existing_result.place   = result.place.to_s
      existing_result.team_id = team_ids[result.person_id]
      existing_result.points  = result.points

      # TODO Why do we need explicit dirty check?
      if existing_result.place_changed? || existing_result.team_id_changed? || existing_result.points_changed?
        existing_result.save!
      end

      existing_scores = existing_result.scores.map { |s| [ s.source_result_id, s.points.to_f ] }
      new_scores = result.scores.map { |s| [ s.source_result_id, s.points.to_f ] }
      
      scores_to_create = new_scores - existing_scores
      scores_to_delete = existing_scores - new_scores
      
      scores_to_create.each do |score|
        create_score existing_result, score.first, score.last
      end

      if scores_to_delete.present?
        Score.delete_all("competition_result_id = #{existing_result.id} and source_result_id in (#{scores_to_delete.map(&:first).join(",")})")
      end
    end
  end

  def delete_competition_results_for(results, race)
    if results.present?
      Score.delete_all("competition_result_id in (#{results.map(&:id).join(",")})")
      Result.delete_all("id in (#{results.map(&:id).join(",")})")
    end
  end
end

