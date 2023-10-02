require 'rails_helper'

RSpec.describe User, type: :model do

  it 'is valid with valid attributes' do
    user = User.create(name: "Name User",
      gender: true,
      date_of_birth: "2000-12-15",
      phone_number: "0883152558",
      address: "60 Le Thi Tinh",
      is_admin: true,
      email: "user008@gmail.com",
      password: "123456")

    expect(user).to be_valid
  end

  it 'is not valid without a name' do
    user = User.create(name: nil)
    expect(user).not_to be_valid
  end

  it 'is not valid without a gender' do
    user = User.create(gender: nil)
    expect(user).not_to be_valid
  end

  it 'is not valid without a date_of_birth' do
    user = User.create(date_of_birth: nil)
    expect(user).not_to be_valid
  end

  it 'is not valid without a phone_number' do
    user = User.create(phone_number: nil)
    expect(user).not_to be_valid
  end

  it 'is not valid without an address' do
    user = User.create(address: nil)
    expect(user).not_to be_valid
  end
end
