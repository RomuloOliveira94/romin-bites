FactoryBot.define do
  factory :menu_item do
    name { FFaker::Food.ingredient }
    description { FFaker::Lorem.paragraph }
    price { rand(1.0..100.0).round(2) }
  end
end
