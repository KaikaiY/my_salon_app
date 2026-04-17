class CreateTherapistProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :therapist_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.text :bio, null: false
      t.string :specialty, null: false
      t.text :career, null: false
      t.boolean :published, null: false, default: false

      t.timestamps
    end
  end
end
