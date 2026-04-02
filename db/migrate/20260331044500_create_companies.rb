class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :company_name, null: false
      t.string :email,        null: false
      t.string :phone,        null: false
      t.boolean :active,      null: false, default: true
      t.timestamps
    end
  end
end
