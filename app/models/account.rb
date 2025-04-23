class Account < ApplicationRecord
  has_secure_token :public_token
  has_secure_password :token

  def authenticate_token(token)
    key = Digest::MD5.hexdigest("#{token}#{public_token}")
    Rails.cache.fetch([self.updated_at, key]) do
      super(token)
    end
  end
end
