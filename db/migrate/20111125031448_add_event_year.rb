class AddEventYear < ActiveRecord::Migration
  def self.up
    add_column :events, :year, :integer
    execute("update events set year = extract(year from date)")
  end

  def self.down
    remove_column :events, :year
  end
end