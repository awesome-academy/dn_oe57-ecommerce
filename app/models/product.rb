class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image
  has_many :feedbacks, dependent: :destroy

  delegate :name, to: :category, prefix: true

  validates :name, presence: true,
                  length: {maximum: Settings.products.length_30}
  validates :price, presence: true, numericality: {
    less_than_or_equal_to: Settings.products.limit_price
  }
  validates :quantity, presence: true, numericality: {
    less_than_or_equal_to: Settings.products.limit_quantity
  }
  validates :description, presence: true,
                  length: {maximum: Settings.products.length_30}
  validates :category_id, presence: true

  scope :sort_by_name, ->{order :name}
  scope :search_by_name, lambda {|name|
                           where("name LIKE ?", "%#{name}%")
                         }
  scope :filter_by_category_id, lambda {|category_id|
                                  where(category_id:)
                                }
  scope :find_id, lambda {|id|
                    where(id:)
                  }
  def self.ransackable_attributes _auth_object = nil
    %w(name description)
  end
  scope :newest, ->{order created_at: :desc}
end
