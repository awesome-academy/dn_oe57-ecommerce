class Category < ApplicationRecord
  has_many :products, dependent: :destroy

  has_many :childrens,
           class_name: Category.name,
           foreign_key: :parent_id,
           dependent: :destroy
  belongs_to :parent, class_name: Category.name, optional: true

  scope :parent_items, ->{where parent_id: nil}
  scope :children_of, lambda {|parent_items|
                        where(parent_id: parent_items.pluck(:id))
                      }
  scope :find_id_or_parent, lambda {|id|
                              where("parent_id = :id OR id = :id", id:)
                            }
  scope :search_by_name, lambda {|name|
                           where("name LIKE ?", "%#{name}%")
                         }
  scope :find_id, lambda {|parent_id|
                    where(parent_id:)
                  }
end
