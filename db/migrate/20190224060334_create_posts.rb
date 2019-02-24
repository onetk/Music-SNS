class CreatePosts < ActiveRecord::Migration[5.2]
  def change
      create_table :posts do |t|
        t.string :artist
        t.string :album
        t.string :track
        t.string :sample_image
        t.string :image_url
        t.string :sample_url
        t.string :comment
        t.string :user_name
        t.string :user_id
        t.timestamps null: false
      end
  end
end
