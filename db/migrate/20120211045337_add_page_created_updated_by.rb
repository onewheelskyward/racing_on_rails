class AddPageCreatedUpdatedBy < ActiveRecord::Migration
  class Person < ActiveRecord::Base
    versioned
    belongs_to :old_created_by, :polymorphic => true
  end

  def self.up
    rename_column :race_numbers, :updated_by, :old_updated_by
    RaceNumber.all.each do |race_number|
      if race_number.old_updated_by.blank?
        # Nothing to do
      elsif race_number.old_updated_by["xls"]
        file = ImportFile.find_of_create_by_name(race_number.old_updated_by)
        race_number.versions.create!(:user => file)
      elsif (person = Person.find_by_name(race_number.old_updated_by)).present?
        race_number.versions.create!(:user => person)
      elsif (event = Event.where("name = ? and YEAR(date) = ?", race_number.old_updated_by, race_number.year).first).present?
        race_number.versions.create!(:user => event)
      end
    end

    Person.all.each do |person|
      if person.last_updated_by.blank?
        # Nothing to do
      elsif person.last_updated_by["xls"]
        file = ImportFile.find_of_create_by_name(person.last_updated_by)
        person.versions.create!(:user => file)
      elsif (updated_by_person = Person.find_by_name(person.last_updated_by)).present?
        person.versions.create!(:user => updated_by_person)
      end
    end

    rename_column :people, :created_by_id, :old_created_by_id
    rename_column :people, :created_by_type, :old_created_by_type
    Person.where("old_created_by_id is not null").each do |person|
      person.versions.create!(:user => person.old_created_by)      
    end

    Team.where("created_by_id is not null").each do |team|
      team.versions.create!(:user => Person.find(team.created_by_id))
    end

    remove_column :pages, :created_by_id

    remove_column :people, :last_updated_by
    remove_column :people, :old_created_by_type
    remove_column :people, :old_created_by_id

    remove_column :race_numbers, :old_updated_by

    remove_column :teams, :created_by_type
    remove_column :teams, :created_by_id

    # # Make sure merge handles created and updated by
    
    # # Add FK constraints
    # # Just delete the reference?

    # # Naming

    # # Comments

    # # Move versioned call to Audit module?
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