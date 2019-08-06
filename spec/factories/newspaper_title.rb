# will infer, create a NewspaperTitle object
FactoryBot.define do
  factory :newspaper_title do
    title { ['ACME Press'] }
    lccn { 'sn2036999999' }
    depositor { User.batch_user.user_key }
  end
end
