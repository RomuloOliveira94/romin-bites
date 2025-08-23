FactoryBot.define do
  factory :restaurant do
    name { FFaker::Company.name }
    description { FFaker::Lorem.paragraph }
  end
end
