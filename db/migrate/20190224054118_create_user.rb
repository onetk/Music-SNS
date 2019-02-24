class CreateUser < ActiveRecord::Migration[5.2]
  def change
      create_table :users do |t|
        t.string :name
        t.string :password_digest
        t.string :profile_image
        t.timestamps null: false
      end
  end
end
