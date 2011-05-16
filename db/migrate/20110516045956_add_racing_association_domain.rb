class AddRacingAssociationDomain < ActiveRecord::Migration
  def self.up
    add_column :racing_associations, :domain, :string
  end

  def self.down
    remove_column :racing_associations, :domain
  end
end