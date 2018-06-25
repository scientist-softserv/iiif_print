FactoryBot.define do
  factory :ability do
    user
    initialize_with { new(user) }
  end
end
