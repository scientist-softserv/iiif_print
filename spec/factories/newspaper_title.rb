# will infer, create a NewspaperTitle object
FactoryBot.define do
  factory :newspaper_title do
    title { ['ACME Press'] }
    depositor { User.batch_user.user_key }
  end
end
