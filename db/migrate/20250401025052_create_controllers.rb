class CreateControllers < ActiveRecord::Migration[7.1]
  def change
    create_table :controllers do |t|
      t.string :Profile
      t.references :user, null: false, foreign_key: true
      t.text :bio
      t.string :avatar_url

      t.timestamps
    end
  end
end
