FactoryBot.define do
  factory :order do
    reciver_name {"Reciver name"}
    reciver_address {"Reciver address"}
    reciver_phone {"0889152558"}
    total_price {100000}
    status {1}
    user_id {nil}
  end
end
