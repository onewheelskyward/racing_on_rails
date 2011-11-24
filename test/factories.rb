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
    name "Road"
    numbers true

    factory :cyclocross_discipline do
      name "Cyclocross"
      after_create { |d| 
        d.discipline_aliases.create!(:alias => "ccx")
        d.discipline_aliases.create!(:alias => "cx")
      }
    end

    factory :mtb_discipline do
      name "Mountain Bike"
      after_create { |d| d.discipline_aliases.create!(:alias => "mtb") }
    end
  end
  
  factory :discipline_alias do
    sequence(:alias) { |n| "#{n}" }
    discipline
  end
  
  factory :event, :class => "SingleDayEvent" do
    promoter :factory => :person
    factory :multi_day_event, :class => "MultiDayEvent"
    factory :series, :class => "Series"
    factory :weekly_series, :class => "WeeklySeries"
    
    factory :series_event do
      parent :factory => :series
    end

    factory :stage_race, :class => "MultiDayEvent" do |parent|
      date Time.zone.local(2005, 7, 11)
      children { |e| [ 
        e.association(:event, :date => Time.zone.local(2005, 7, 11), :parent_id => e.id),  
        e.association(:event, :date => Time.zone.local(2005, 7, 12), :parent_id => e.id), 
        e.association(:event, :date => Time.zone.local(2005, 7, 13), :parent_id => e.id) 
      ] }
    end
    
    factory :weekly_series_event do
      parent :factory => :weekly_series
    end
    
    factory :time_trial_event do
      discipline "Time Trial"
    end
  end
  
  factory :mailing_list do
    sequence(:name) { |n| "obra_#{n}" }    
    sequence(:friendly_name) { |n| "OBRA Chat #{n}" }
    sequence(:subject_line_prefix) { |n| "OBRA Chat #{n}" }
  end
  
  factory :number_issuer do
    name "CBRA"
  end
  
  factory :page do
    body "<p>This is a plain page</p>"
    path "plain"
    slug "plain"
    title "Plain"
    updated_at Time.zone.local(2007)
    created_at Time.zone.local(2007)
  end
  
  factory :person do
    first_name "Ryan"
    sequence(:last_name) { |n| "Weaver#{n}" }
    name { "#{first_name} #{last_name}".strip }
    member_from Time.zone.local(2000).beginning_of_year.to_date
    member_to   Time.zone.now.end_of_year.to_date
    
    factory :person_with_login do
      sequence(:login) { |n| "person#{n}@example.com" }
      sequence(:email) { |n| "person#{n}@example.com" }
      password_salt "c6be084e3033ba4024345e96154a876e2d5d3942fb8db02bd9c53b7a2f64f47ff8bef33e765d30cc35a7c98e045c27f2752091391d3e85b44aaa7f75926906ad"
      crypted_password "1843a3711b16a7f2c1afb93d605bd58d2cdc44fea50e156b83a33fb806e4091803bdfb5afad6e9a48c6c55722ca4e92635e44fb6a346d7cc756d84787b11f344"
      persistence_token { Authlogic::Random.hex_token }
      single_access_token { Authlogic::Random.friendly_token }
      perishable_token { Authlogic::Random.friendly_token }
      
      factory :administrator do
        first_name "Candi"
        last_name "Murray"
        roles { |r| [ r.association(:role) ] }
        login "admin@example.com"
        email "admin@example.com"
        home_phone "(503) 555-1212"
      end

      factory :promoter do
        events { |p| [ p.association(:event, :promoter_id => p.id) ] }
      end
    end
  end

  factory :race do
    category
    event
    
    factory :time_trial_race do
      association :event, :factory => :time_trial_event
    end
    
    factory :weekly_series_race do
      association :event, :factory => :weekly_series_event
    end
  end
  
  factory :race_number do
    discipline
    number_issuer
    person
    sequence :value, 51
  end

  factory :role do
    name "Administrator"
  end
  
  factory :result do
    sequence :place
    race
    person
    team
    
    factory :time_trial_result do
      time 1800
      association :race, :factory => :time_trial_race
    end
    
    factory :weekly_series_event_result do
      association :race, :factory => :weekly_series_race
    end
  end  
  
  factory :team do
    member true
    show_on_public_page true
    sequence(:name) { |n| "Team #{n}" }
  end
  
  factory :velodrome do
    sequence(:name) { |n| "Velodrome #{n}" }    
  end
end
