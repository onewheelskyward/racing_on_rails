class AddPageCreatedUpdatedBy < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.integer :created_by_id, :default => nil
      t.integer :updated_by_id, :default => nil
      t.string :updated_by_type, :null => true
      t.string :created_by_type, :null => true
    end
    add_index :events, :created_by_id
    add_index :events, :updated_by_id

    change_table :pages do |t|
      t.integer :updated_by_id, :default => nil
      t.string :updated_by_type, :null => true
      t.string :created_by_type, :null => true
    end
    add_index :pages, :updated_by_id

    change_table :race_numbers do |t|
      t.integer :created_by_id, :default => nil
      t.integer :updated_by_id, :default => nil
      t.string :updated_by_type, :null => true
      t.string :created_by_type, :null => true
      t.rename :updated_by, :old_updated_by
    end
    add_index :race_numbers, :created_by_id
    add_index :race_numbers, :updated_by_id

    change_table :teams do |t|
      t.integer :updated_by_id, :default => nil
      t.string :updated_by_type, :null => true
    end
    add_index :teams, :updated_by_id

    # Migrate old info
    # Set updated_by if created_by exists
    execute "update pages set created_by_type='Person' where created_by_type is null and created_by_id is not null"
    Page.where("created_by_id is not null and updated_by_id is null").each do |page|
      execute "update pages set updated_by_type=?, updated_by_id=? where id=?", "Person", page.updated_by_id, page.id
    end

    Person.all.each do |person|
      if person.last_updated_by.blank?
        # Nothing to do
      elsif person.last_updated_by["xls"]
        file = ImportFile.find_of_create_by_name(person.last_updated_by)
        execute "update people set updated_by_id=?, updated_by_type=? where id=?", file.id, "ImportFile", person.id
      elsif (updated_by_person = Person.find_by_name(person.last_updated_by)).present?
        execute "update people set updated_by_id=?, updated_by_type=? where id=?", updated_by_person.id, "Person", person.id
      end
    end
    Person.where("created_by_id is not null and updated_by_id is null").each do |person|
      execute "update people set updated_by_type=?, updated_by_id=? where id=?", person.created_by_type, person.created_by_id, person.id
    end

    RaceNumber.all.each do |race_number|
      if race_number.old_updated_by.blank?
        # Nothing to do
      elsif race_number.old_updated_by["xls"]
        file = ImportFile.find_of_create_by_name(race_number.old_updated_by)
        execute "update race_number set created_by_id=?, created_by_type=?, updated_by_id=?, updated_by_type=? where id=?", file.id, "ImportFile", file.id, "ImportFile", race_number.id
      elsif (person = Person.find_by_name(race_number.old_updated_by)).present?
        execute "update race_number set created_by_id=?, created_by_type=?, updated_by_id=?, updated_by_type=? where id=?", person.id, "Person", person.id, "Person", race_number.id
      elsif (event = Event.find_by_name_and_year(race_number.old_updated_by, race_number.year)).present?
        execute "update race_number set created_by_id=?, created_by_type=?, updated_by_id=?, updated_by_type=? where id=?", event.id, "Event", event.id, "Event", race_number.id
      end
    end

    Team.where("created_by_id is not null and updated_by_id is null").each do |team|
      execute "update teams set updated_by_type=?, updated_by_id=? where id=?", team.created_by_type, team.created_by_id, page.id
    end

    drop_column :people, :last_updated_by
    drop_column :race_numbers, :old_updated_by

    # Switch our updated_by param with user
    # Add FK constraints
    # Just delete the reference?

    # Make sure merge handles created and updated by

    # Naming

    # Comments

    # Move versioned call to Audit module?
  end

  def self.down
    remove_index :events, :created_by_id
    remove_index :events, :updated_by_id
    change_table :events do |t|
      t.remove :updated_by_id
      t.remove :updated_by_type
      t.remove :created_by_id
      t.remove :created_by_type
    end

    remove_index :pages, :updated_by_id
    change_table :pages do |t|
      t.remove :updated_by_id
      t.remove :updated_by_type
      t.remove :created_by_type
    end

    remove_index :people, :created_by_id
    remove_index :people, :updated_by_id
    change_table :people do |t|
      t.remove :updated_by_id
      t.remove :updated_by_type
      t.remove :created_by_id
      t.remove :created_by_type
    end

    remove_index :race_numbers, :created_by_id
    remove_index :race_numbers, :updated_by_id
    change_table :race_numbers do |t|
      t.remove :updated_by_id
      t.remove :updated_by_type
      t.remove :created_by_id
      t.remove :created_by_type
      t.rename :old_updated_by, :updated_by
    end

    remove_index :teams, :created_by_id
    remove_index :teams, :updated_by_id
    change_table :teams do |t|
      t.remove :updated_by_id
      t.remove :updated_by_type
      t.remove :created_by_id
      t.remove :created_by_type
    end
  end
end