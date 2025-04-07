class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true
  
  def to_token_payload
    { sub: id, username: username }
  end
end
