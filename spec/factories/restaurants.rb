FactoryBot.define do
  factory :restaurant do
    sequence(:name) { |n| "#{FFaker::Company.name} #{n}" }
    description { FFaker::Lorem.paragraph }

    trait :with_menus do
      after(:create) do |restaurant|
        create_list(:menu, 2, :with_menu_items, restaurant: restaurant)
      end
    end
  end
end
