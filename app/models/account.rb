class Account < ApplicationRecord
  has_secure_token :public_token
  has_secure_password :token
end
