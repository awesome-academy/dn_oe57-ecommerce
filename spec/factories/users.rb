FactoryBot.define do
  factory :user do
    name {"Defnd 1"}
    gender {true}
    date_of_birth {"2000-12-15"}
    phone_number {"0883152558"}
    address {"60 Le Thi Tinh"}
    is_admin {false}
    email {"user008@gmail.com"}
    password {"123456"}
  end
end
