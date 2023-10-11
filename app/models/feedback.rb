class Feedback < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :content, presence: true,
    length: {maximum: Settings.orders.length_30}

  validates :rating, presence: true

  delegate :name, to: :user, prefix: true

  scope :filter_by_product_id, lambda {|product_id|
    where(product_id:)
  }

  scope :newest, ->{order created_at: :desc}
end
