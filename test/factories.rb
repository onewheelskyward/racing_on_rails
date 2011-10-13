FactoryGirl.define do
  factory :person_alias, :class => Alias do
    sequence(:name) { |n| "Person Alias #{n}" }
    person
  end

  factory :team_alias, :class => Alias do
    sequence(:name) { |n| "Team Alias #{n}" }
    team
  end
  
  factory :article
  
  factory :article_category

  factory :category do
    sequence(:name) { |n| "Category #{n}" }
  end
  
  factory :discipline do
    bar true
    sequence(:name) { |n| "Discipline #{n}" }
  end
  
  factory :discipline_alias do
    sequence(:alias) { |n| "#{n}" }
    discipline
  end
  
  factory :event, :class => "SingleDayEvent" do
    factory :series, :class => "Series"
    
    factory :series_event do
      parent :factory => :series
    end
    
    factory :time_trial_event do
      discipline "Time Trial"
    end
  end
  
  factory :person do
    first_name "Ryan"
    sequence(:last_name) { |n| "Weaver#{n}" }
    member_from Date.new(2000).beginning_of_year
    member_to   Time.zone.now.end_of_year
  end

  factory :race do
    category
    event
    
    factory :time_trial_race do
      association :event, :factory => :time_trial_event
    end
  end
  
  factory :result do
    sequence :place
    race
    person
    
    factory :time_trial_result do
      time 1800
      association :race, :factory => :time_trial_race
    end
  end  
  
  factory :team do
    member true
    sequence(:name) { |n| "Team #{n}" }
  end
end
