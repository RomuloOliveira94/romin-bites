FactoryBot.define do
  factory :menu do
    name { FFaker::Food.meat }
    description { FFaker::Lorem.paragraph }
  end
end
