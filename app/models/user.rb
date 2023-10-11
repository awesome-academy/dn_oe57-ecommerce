class User < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_secure_password

  private

  def down_case
    email.downcase!
  end
end
