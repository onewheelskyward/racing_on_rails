class RenameIndexes < ActiveRecord::Migration

  # SELECT CONCAT('alter table ',TABLE_NAME,' DROP INDEX ',constraint_name,';')  FROM statistics.key_column_usage WHERE table_schema = 'racing_on_rails_development';
  # SELECT column_name, column_key FROM information_schema.COLUMNS WHERE table_schema = 'racing_on_rails_development' and column_key ="MUL";
  # SELECT CONCAT('alter table ',TABLE_NAME,' DROP INDEX ',index_name,';')  FROM statistics WHERE table_schema = 'racing_on_rails_development' and INDEX_NAME != 'PRIMARY';
  def self.up
    drop_table :duplicates_racers
    drop_table :events_people
    drop_table :events_promoters
    drop_table :historical_names
    drop_table :racers
    drop_table :standings
    
    change_column_default :results, :competition_result, true
    change_column_default :results, :team_competition_result, true
    
    execute("alter table aliases DROP FOREIGN KEY aliases_person_id")
    execute("alter table aliases DROP FOREIGN KEY aliases_team_id_fk")
    execute("alter table aliases DROP INDEX idx_id")
    execute("alter table aliases DROP INDEX idx_racer_id")
    execute("alter table aliases DROP INDEX idx_team_id")
    execute("alter table categories DROP FOREIGN KEY categories_categories_id_fk")
    execute("alter table categories DROP INDEX index_categories_on_friendly_param")
    execute("alter table categories DROP INDEX parent_id")
    execute("alter table competition_event_memberships DROP FOREIGN KEY competition_event_memberships_competitions_id_fk")
    execute("alter table competition_event_memberships DROP FOREIGN KEY competition_event_memberships_events_id_fk")
    execute("alter table competition_event_memberships DROP INDEX index_competition_event_memberships_on_competition_id")
    execute("alter table competition_event_memberships DROP INDEX index_competition_event_memberships_on_event_id")
    execute("alter table discipline_aliases DROP FOREIGN KEY discipline_aliases_disciplines_id_fk")
    execute("alter table discipline_aliases DROP INDEX idx_alias")
    execute("alter table discipline_aliases DROP INDEX idx_discipline_id")
    execute("alter table discipline_bar_categories DROP FOREIGN KEY discipline_bar_categories_categories_id_fk")
    execute("alter table discipline_bar_categories DROP FOREIGN KEY discipline_bar_categories_disciplines_id_fk")
    execute("alter table discipline_bar_categories DROP INDEX idx_category_id")
    execute("alter table discipline_bar_categories DROP INDEX idx_discipline_id")
    execute("alter table discount_codes DROP FOREIGN KEY discount_codes_ibfk_1")
    execute("alter table discount_codes DROP INDEX event_id")
    execute("alter table duplicates_people DROP FOREIGN KEY duplicates_people_person_id")
    execute("alter table duplicates_people DROP FOREIGN KEY duplicates_racers_duplicates_id_fk")
    execute("alter table duplicates_people DROP INDEX index_duplicates_racers_on_duplicate_id")
    execute("alter table duplicates_people DROP INDEX index_duplicates_racers_on_racer_id")
    execute("alter table editor_requests DROP FOREIGN KEY editor_requests_ibfk_1")
    execute("alter table editor_requests DROP FOREIGN KEY editor_requests_ibfk_2")
    execute("alter table editor_requests DROP INDEX index_editor_requests_on_editor_id")
    execute("alter table editor_requests DROP INDEX index_editor_requests_on_expires_at")
    execute("alter table editor_requests DROP INDEX index_editor_requests_on_person_id")
    execute("alter table editor_requests DROP INDEX index_editor_requests_on_token")
    execute("alter table editor_requests DROP INDEX index_editor_requests_on_editor_id_and_person_id")
    execute("alter table events DROP FOREIGN KEY events_events_id_fk")
    execute("alter table events DROP FOREIGN KEY events_number_issuers_id_fk")
    execute("alter table events DROP FOREIGN KEY events_promoter_id")
    execute("alter table events DROP FOREIGN KEY events_velodrome_id_fk")
    execute("alter table events DROP INDEX events_number_issuer_id_index")
    execute("alter table events DROP INDEX idx_date")
    execute("alter table events DROP INDEX idx_disciplined")
    execute("alter table events DROP INDEX idx_type")
    execute("alter table events DROP INDEX index_events_on_bar_points")
    execute("alter table events DROP INDEX index_events_on_promoter_id")
    execute("alter table events DROP INDEX index_events_on_sanctioned_by")
    execute("alter table events DROP INDEX index_events_on_type")
    execute("alter table events DROP INDEX parent_id")
    execute("alter table events DROP INDEX velodrome_id")
    execute("alter table line_items DROP INDEX index_line_items_on_discount_code_id")
    execute("alter table line_items DROP INDEX index_line_items_on_event_id")
    execute("alter table line_items DROP INDEX index_line_items_on_line_item_id")
    execute("alter table line_items DROP INDEX index_line_items_on_order_id")
    execute("alter table line_items DROP INDEX index_line_items_on_person_id")
    execute("alter table line_items DROP INDEX index_line_items_on_race_id")
    execute("alter table mailing_lists DROP INDEX idx_name")
    execute("alter table names DROP INDEX index_names_on_name")
    execute("alter table names DROP INDEX index_names_on_nameable_type")
    execute("alter table names DROP INDEX index_names_on_year")
    execute("alter table names DROP INDEX team_id")
    execute("alter table news_items DROP INDEX news_items_date_index")
    execute("alter table news_items DROP INDEX news_items_text_index")
    execute("alter table orders DROP INDEX index_orders_on_purchase_time")
    execute("alter table orders DROP INDEX index_orders_on_status")
    execute("alter table orders DROP INDEX index_orders_on_updated_at")
    execute("alter table order_people DROP FOREIGN KEY order_people_ibfk_1")
    execute("alter table order_people DROP FOREIGN KEY order_people_ibfk_2")
    execute("alter table order_people DROP INDEX index_order_people_on_order_id")
    execute("alter table order_people DROP INDEX index_order_people_on_person_id")
    execute("alter table order_transactions DROP INDEX index_order_transactions_on_created_at")
    execute("alter table order_transactions DROP INDEX index_order_transactions_on_order_id")
    execute("alter table pages DROP FOREIGN KEY pages_parent_id_fk")
    execute("alter table pages DROP INDEX index_pages_on_created_by_id")
    execute("alter table pages DROP INDEX index_pages_on_slug")
    execute("alter table pages DROP INDEX parent_id")
    execute("alter table pages DROP INDEX index_pages_on_path")
    execute("alter table people DROP FOREIGN KEY people_team_id_fk")
    execute("alter table people DROP INDEX idx_first_name")
    execute("alter table people DROP INDEX idx_last_name")
    execute("alter table people DROP INDEX idx_team_id")
    execute("alter table people DROP INDEX index_people_on_created_by_id")
    execute("alter table people DROP INDEX index_people_on_crypted_password")
    execute("alter table people DROP INDEX index_people_on_email")
    execute("alter table people DROP INDEX index_people_on_license")
    execute("alter table people DROP INDEX index_people_on_login")
    execute("alter table people DROP INDEX index_people_on_perishable_token")
    execute("alter table people DROP INDEX index_people_on_persistence_token")
    execute("alter table people DROP INDEX index_people_on_print_card")
    execute("alter table people DROP INDEX index_people_on_single_access_token")
    execute("alter table people DROP INDEX index_racers_on_member_from")
    execute("alter table people DROP INDEX index_racers_on_member_to")
    execute("alter table people_people DROP FOREIGN KEY people_people_ibfk_1")
    execute("alter table people_people DROP FOREIGN KEY people_people_ibfk_2")
    execute("alter table people_people DROP INDEX index_people_people_on_editor_id")
    execute("alter table people_people DROP INDEX index_people_people_on_person_id")
    execute("alter table people_people DROP INDEX index_people_people_on_editor_id_and_person_id")
    execute("alter table people_roles DROP FOREIGN KEY people_roles_person_id")
    execute("alter table people_roles DROP FOREIGN KEY roles_users_role_id_fk")
    execute("alter table people_roles DROP INDEX index_people_roles_on_person_id")
    execute("alter table people_roles DROP INDEX role_id")
    execute("alter table posts DROP FOREIGN KEY posts_mailing_list_id_fk")
    execute("alter table posts DROP INDEX idx_date")
    execute("alter table posts DROP INDEX idx_date_list")
    execute("alter table posts DROP INDEX idx_mailing_list_id")
    execute("alter table posts DROP INDEX idx_sender")
    execute("alter table posts DROP INDEX idx_subject")
    execute("alter table promoters DROP INDEX idx_name")
    execute("alter table races DROP FOREIGN KEY races_category_id_fk")
    execute("alter table races DROP FOREIGN KEY races_event_id_fk")
    execute("alter table races DROP INDEX idx_category_id")
    execute("alter table races DROP INDEX index_races_on_bar_points")
    execute("alter table races DROP INDEX index_races_on_event_id")
    execute("alter table race_numbers DROP FOREIGN KEY race_numbers_discipline_id_fk")
    execute("alter table race_numbers DROP FOREIGN KEY race_numbers_number_issuer_id_fk")
    execute("alter table race_numbers DROP FOREIGN KEY race_numbers_person_id")
    execute("alter table race_numbers DROP INDEX discipline_id")
    execute("alter table race_numbers DROP INDEX index_race_numbers_on_year")
    execute("alter table race_numbers DROP INDEX number_issuer_id")
    execute("alter table race_numbers DROP INDEX racer_id")
    execute("alter table race_numbers DROP INDEX race_numbers_value_index")
    execute("alter table refunds DROP INDEX index_refunds_on_order_id")
    execute("alter table results DROP FOREIGN KEY results_category_id_fk")
    execute("alter table results DROP FOREIGN KEY results_person_id")
    execute("alter table results DROP FOREIGN KEY results_race_id_fk")
    execute("alter table results DROP FOREIGN KEY results_team_id_fk")
    execute("alter table results DROP INDEX idx_category_id")
    execute("alter table results DROP INDEX idx_racer_id")
    execute("alter table results DROP INDEX idx_race_id")
    execute("alter table results DROP INDEX idx_team_id")
    execute("alter table results DROP INDEX index_results_on_event_id")
    execute("alter table results DROP INDEX index_results_on_members_only_place")
    execute("alter table results DROP INDEX index_results_on_place")
    execute("alter table results DROP INDEX index_results_on_year")
    execute("alter table scores DROP FOREIGN KEY scores_competition_result_id_fk")
    execute("alter table scores DROP FOREIGN KEY scores_source_result_id_fk")
    execute("alter table scores DROP INDEX scores_competition_result_id_index")
    execute("alter table scores DROP INDEX scores_source_result_id_index")
    execute("alter table teams DROP INDEX index_teams_on_created_by_id")
    execute("alter table teams DROP INDEX idx_name")
    execute("alter table update_requests DROP FOREIGN KEY update_requests_ibfk_1")
    execute("alter table update_requests DROP INDEX index_update_requests_on_expires_at")
    execute("alter table update_requests DROP INDEX index_update_requests_on_token")
    execute("alter table velodromes DROP INDEX index_velodromes_on_name")
    execute("alter table versions DROP INDEX index_versions_on_created_at")
    execute("alter table versions DROP INDEX index_versions_on_number")
    execute("alter table versions DROP INDEX index_versions_on_tag")
    execute("alter table versions DROP INDEX index_versions_on_user_id_and_user_type")
    execute("alter table versions DROP INDEX index_versions_on_user_name")
    execute("alter table versions DROP INDEX index_versions_on_versioned_id_and_versioned_type")
    
    add_index :aliases, :name
    add_index :aliases, :alias
    add_index :aliases, :person_id
    add_index :aliases, :team_id
    
    add_index :categories, :name, :unique => true
    add_index :categories, :parent_id
    add_index :categories, :friendly_param
    
    add_index :competition_event_memberships, :competition_id
    add_index :competition_event_memberships, :event_id
    add_index :competition_event_memberships, [ :competition_id, :event_id ], :unique => true, :name =>"comp_id_event_id"

    add_index :discipline_aliases, :alias
    add_index :discipline_aliases, :discipline_id
    add_index :discipline_aliases, [ :alias, :discipline_id ], :unique => true
    
    add_index :discipline_bar_categories, :category_id
    add_index :discipline_bar_categories, :discipline_id
    add_index :discipline_bar_categories, [ :category_id, :discipline_id ], :unique => true
    
    add_index :discount_codes, :event_id
    
    add_index :duplicates_people, :duplicate_id
    add_index :duplicates_people, :person_id
    add_index :duplicates_people, [ :duplicate_id, :person_id ], :unique => true
    
    add_index :editor_requests, :editor_id
    add_index :editor_requests, :person_id
    add_index :editor_requests, [ :editor_id, :person_id ], :unique => true
    add_index :editor_requests, :token
    
    add_index :events, :number_issuer_id
    add_index :events, :date
    add_index :events, :discipline
    add_index :events, :type
    add_index :events, :bar_points
    add_index :events, :promoter_id
    add_index :events, :sanctioned_by
    add_index :events, :parent_id
    add_index :events, :velodrome_id
    
    add_index :mailing_lists, :name, :unique => true
    
    add_index :names, :name
    add_index :names, :nameable_type
    add_index :names, :year
    add_index :names, :first_name
    add_index :names, :last_name

    add_index :pages, :created_by_id
    add_index :pages, :parent_id
    add_index :pages, :path, :unique => true
    add_index :pages, :slug
    
    add_index :people, :first_name
    add_index :people, :last_name
    add_index :people, :team_id
    add_index :people, :created_by_id
    add_index :people, :crypted_password
    add_index :people, :email
    add_index :people, :license
    add_index :people, :login
    add_index :people, :perishable_token
    add_index :people, :persistence_token
    add_index :people, :print_card
    add_index :people, :single_access_token
    add_index :people, :member_from
    add_index :people, :member_to

    add_index :people_people, :editor_id
    add_index :people_people, :person_id
    add_index :people_people, [ :editor_id, :person_id ], :unique => true
    
    add_index :people_roles, :person_id
    add_index :people_roles, :role_id
    add_index :people_roles, [ :person_id, :role_id ], :unique => true
    
    add_index :posts, :date
    add_index :posts, :sender
    add_index :posts, :topica_message_id, :unique => true
    add_index :posts, :subject
    add_index :posts, :mailing_list_id
    add_index :posts, [ :date, :mailing_list_id ]
    
    add_index :races, :category_id
    add_index :races, :event_id
    add_index :races, :bar_points
    
    add_index :race_numbers, :discipline_id
    add_index :race_numbers, :year
    add_index :race_numbers, :number_issuer_id
    add_index :race_numbers, :person_id
    add_index :race_numbers, :value
    
    add_index :results, :category_id
    add_index :results, :person_id
    add_index :results, :race_id
    add_index :results, :team_id
    add_index :results, :event_id
    add_index :results, :members_only_place
    add_index :results, :year
    
    add_index :scores, :competition_result_id
    add_index :scores, :source_result_id
    add_index :scores, [ :competition_result_id, :source_result_id ], :unique => true

    add_index :teams, :name, :unique => true

    add_index :velodromes, :name
    
    add_index :versions, :created_at
    add_index :versions, :number
    add_index :versions, :tag
    add_index :versions, [ :user_id, :user_type ]
    add_index :versions, [ :versioned_id, :versioned_type ]
    add_index :versions, :user_name
  end
end