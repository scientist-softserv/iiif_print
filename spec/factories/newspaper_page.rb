# will infer, create a NewspaperPage object
FactoryBot.define do
  factory :newspaper_page do
    title ['Here and There']
    depositor { User.batch_user.user_key }
  end
end
