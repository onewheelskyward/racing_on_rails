# This migration comes from registration_engine_engine (originally 20121108210600)
class CreateRegistrationTables < ActiveRecord::Migration
  def change
    create_table :adjustments, :force => true do |t|
      t.belongs_to :order
      t.belongs_to :person
      t.datetime :date
      t.decimal :amount, :precision => 10, :scale => 2
      t.string :description
      t.integer :lock_version, :null => false
      t.timestamps
    end
    
    add_index :adjustments, :order_id
    add_index :adjustments, :person_id
    
    create_table :bank_statements, :force => true do |t|
      t.decimal :american_express_fees, :precision => 10, :scale => 2
      t.decimal :american_express_gross, :precision => 10, :scale => 2
      t.decimal :credit_card_gross, :precision => 10, :scale => 2
      t.decimal :credit_card_percentage_fees, :precision => 10, :scale => 2
      t.decimal :credit_card_transaction_fees, :precision => 10, :scale => 2
      t.integer :items
      t.integer :refunds
      t.decimal :refunds_gross, :precision => 10, :scale => 2
      t.decimal :gross, :precision => 10, :scale => 2
      t.decimal :other_fees, :precision => 10, :scale => 2
      t.date :date
      t.timestamps
    end
    
    add_index :bank_statements, :date
    
    create_table :discount_codes, :force => true do |t|
      t.belongs_to :created_by, :polymorphic => true
      t.belongs_to :event
      t.string :person_name
      t.string :code
      t.string :status, :null => "false", :default => "new"
      t.decimal :amount, :precision => 10, :scale => 2
      t.timestamps
    end
    
    change_table :events do |t|
      t.decimal :price, :precision => 10, :scale => 2
      t.boolean :registration
      t.boolean :promoter_pays_registration_fee
      t.datetime :registration_ends_at
      t.boolean :override_registration_ends_at
      t.decimal :all_events_discount, :precision => 10, :scale => 2
      t.decimal :additional_race_price, :precision => 10, :scale => 2
      t.string :custom_suggestion
      t.integer :field_limit
      t.string :refund_policy
      t.boolean :membership_required
    end
    
    create_table :line_items, :force => true do |t|
      t.belongs_to :order
      t.belongs_to :discount_code
      t.belongs_to :event
      t.belongs_to :line_item
      t.belongs_to :person
      t.belongs_to :product
      t.belongs_to :product_variant
      t.belongs_to :additional_product_variant
      t.belongs_to :race
      t.decimal :amount, :precision => 10, :scale => 2
      t.string :string_value
      t.boolean :boolean_value
      t.string :type, :null => false, :default => "LineItem"
      t.boolean :promoter_pays_registration_fee, :null => false, :default => 0
      t.decimal :purchase_price, :precision => 10, :scale => 2
      t.integer :year
      t.string :status, :null => false, :default => "new"
      t.datetime :effective_purchased_at
      t.timestamps
    end
    
    add_index :line_items, :order_id
    add_index :line_items, :person_id
    add_index :line_items, :event_id
    add_index :line_items, :race_id
    add_index :line_items, :discount_code_id
    add_index :line_items, :line_item_id
    add_index :line_items, :product_id
    add_index :line_items, :product_variant_id
    add_index :line_items, :additional_product_variant_id
    
    create_table :order_people, :force => true do |t|
      t.belongs_to :person
      t.belongs_to :order
      t.boolean :owner
      t.boolean :membership_card
      t.string :first_name
      t.string :last_name
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :country_code, :default => "US"
      t.boolean :membership_address_is_billing_address, :default => true
      t.string :billing_first_name
      t.string :billing_last_name
      t.string :billing_street
      t.string :billing_city
      t.string :billing_state
      t.string :billing_zip
      t.string :billing_country_code, :default => "US"
      t.date :card_expires_on
      t.string :card_brand
      t.string :road_category
      t.string :ccx_category
      t.string :dh_category
      t.string :mtb_category
      t.string :track_category
      t.string :email
      t.string :home_phone
      t.string :work_phone
      t.string :cell_fax
      t.string :email
      t.string :gender
      t.date :date_of_birth
      t.string :occupation
      t.boolean :official_interest, :null => false, :default => false
      t.boolean :race_promotion_interest, :null => false, :default => false
      t.boolean :team_interest, :null => false, :default => false
      t.boolean :volunteer_interest, :null => false, :default => false
      t.boolean :wants_email, :null => false, :default => false
      t.boolean :wants_mail, :null => false, :default => false
      t.string :team_name
      t.string :emergency_contact
      t.string :emergency_contact_phone
      t.integer :lock_version, :default => 0, :null => false
      t.timestamps
    end
    
    add_index :order_people, :person_id
    add_index :order_people, :order_id
    
    create_table :orders, :force => true do |t|
      t.decimal :purchase_price, :precision => 10, :scale => 2
      t.string :notes, :size => 2000
      t.string :status, :null => false, :default => "new"
      t.datetime :purchase_time
      t.string :ip_address
      t.boolean :waiver_accepted
      t.string :error_message
      t.string :previous_status
      t.boolean :suggest, :null => false, :default => 1
      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, :purchase_time
    add_index :orders, :updated_at

    create_table :payment_gateway_transactions, :force => true do |t|
      t.belongs_to :order
      t.belongs_to :line_item
      t.string :action
      t.decimal :amount, :precision => 10, :scale => 2
      t.boolean :success
      t.string :authorization
      t.string :message
      t.text :params
      t.integer :lock_version, :null => false, :default => 0
      t.timestamps
    end

    add_index :payment_gateway_transactions, :created_at
    add_index :payment_gateway_transactions, :order_id
    add_index :payment_gateway_transactions, :line_item_id

    change_table :people do |t|
      t.string :billing_first_name
      t.string :billing_last_name
      t.string :billing_street
      t.string :billing_city
      t.string :billing_state
      t.string :billing_zip
      t.string :billing_country_code, :default => "US"
      t.date :card_expires_on
      t.string :card_brand
      t.boolean :membership_address_is_billing_address, :default => true
    end

    create_table :product_variants, :force => true do |t|
      t.belongs_to :product
      t.string :name
      t.decimal :price, :precision => 10, :scale => 2
      t.integer :position, :null => false, :default => true
      t.integer :inventory, :null => true, :default => nil
      t.boolean :default, :null => false, :default => false
      t.boolean :additional, :null => false, :default => false
      t.timestamps
    end

    add_index :product_variants, :product_id

    create_table :products, :force => true do |t|
      t.belongs_to :event
      t.string :name
      t.string :description
      t.decimal :price, :precision => 10, :scale => 2
      t.boolean :notify_racing_association, :null => false, :default => false
      t.integer :inventory, :null => true, :default => nil
      t.boolean :seller_pays_fee, :null => false, :default => false
      t.string :type
      t.boolean :suggest, :null => false, :default => false
      t.string :image_url
      t.boolean :dependent, :null => false, :default => false
      t.integer :seller_id
      t.boolean :has_amount, :null => false, :default => false
      t.boolean :donation, :null => false, :default => false
      t.boolean :unique, :null => false, :default => false
      t.string :email
      t.integer :lock_version, :null => false, :default => 0
      t.timestamps
    end

    add_index :products, :event_id
    add_index :products, :type
    add_index :products, :seller_id

    change_table :racing_associations do |t|
      t.belongs_to :person
    end
    
    change_table :races do |t|
      t.decimal :custom_price, :precision => 10, :scale => 2
      t.boolean :full
      t.integer :field_limit
    end

    create_table :refunds, :force => true do |t|
      t.belongs_to :line_item
      t.decimal :amount, :precision => 10, :scale => 2
      t.timestamps
    end

    add_index :refunds, :line_item_id

    create_table :update_requests do |t|
      t.belongs_to :order_person
      t.integer :lock_version, :default => 0, :null => false
      t.datetime :expires_at
      t.string :token, :null => false
      t.timestamps
    end

    add_index :update_requests, :order_person_id
  end
end
