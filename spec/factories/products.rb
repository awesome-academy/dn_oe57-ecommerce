FactoryBot.define do
  factory :product do
    name {"Product 1"}
    price {100000}
    description {"Mo ta san pham"}
    quantity {12}
    rating {0}
    category_id {nil}
  end
end
