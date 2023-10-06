FactoryBot.define do
  factory :order_detail do
    order_id {nil}
    product_id {nil}
    quantity_product {5}
    price_product {500000}
  end
end
