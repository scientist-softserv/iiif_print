# will infer, create a NewspaperIssue object
FactoryBot.define do
  factory :newspaper_issue do
    title { ['Here and There'] }
    depositor { User.batch_user.user_key }
  end
end
