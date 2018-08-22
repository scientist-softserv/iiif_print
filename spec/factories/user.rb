FactoryBot.define do
  factory :user do
    id "skroob"
    email "spaceballs@example.com"
    password "password_is_12345"
    initialize_with do
      User.find_or_create_by(id: id) do |user|
        user.email = email
        user.password = password
      end
    end
  end
end
