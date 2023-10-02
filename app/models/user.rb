class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :orders, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  validates :name, :gender, :date_of_birth, :phone_number, :address,
            presence: true

  private

  def down_case
    email.downcase!
  end
end
