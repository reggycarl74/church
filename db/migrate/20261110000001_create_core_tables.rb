class CreateCoreTables < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.boolean :admin, null: false, default: false
      t.timestamps
    end
    add_index :users, :email_address, unique: true

    create_table :settings do |t|
      t.string :church_name, null: false, default: "Altona"
      t.string :currency, null: false, default: "EUR"
      t.integer :collection_wday, null: false, default: 0 # 0 = Sunday
      t.decimal :ldf_percent, precision: 5, scale: 2, null: false, default: 10
      t.boolean :deduct_ldf, null: false, default: false
      t.timestamps
    end

    create_table :sections do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :members do |t|
      t.references :section, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    create_table :offering_types do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.boolean :counts_for_ldf, null: false, default: true
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    create_table :contributions do |t|
      t.references :member, null: false, foreign_key: true
      t.references :offering_type, null: false, foreign_key: true
      t.date :given_on, null: false
      t.integer :amount_cents, null: false, default: 0
      t.references :updated_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :contributions, [ :member_id, :offering_type_id, :given_on ], unique: true, name: "index_contributions_unique"
    add_index :contributions, :given_on

    create_table :cash_entries do |t|
      t.date :entry_on, null: false
      t.string :kind, null: false # "income" or "expense"
      t.string :description, null: false
      t.string :category
      t.string :reference
      t.integer :amount_cents, null: false
      t.references :offering_type, foreign_key: true # income counted as tithe/offering (e.g. loose plate offering)
      t.references :created_by, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :cash_entries, :entry_on

    create_table :cash_months do |t|
      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :brought_forward_override_cents
      t.integer :petty_cash_cents
      t.integer :bank_balance_cents
      t.text :notes
      t.timestamps
    end
    add_index :cash_months, [ :year, :month ], unique: true
  end
end
