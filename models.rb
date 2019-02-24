require 'bundler/setup'
Bundler.require

if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class User < ActiveRecord::Base
  has_secure_password
  validates :name,
    presence: true,
    format: {with: /\A\w+\z/}
  validates :password,
    length: {in: 5..10}
  has_many :posts
end

class Post < ActiveRecord::Base
  scope :had_by, -> (user){ where(user_id: user.id) }
  belongs_to :user
end
