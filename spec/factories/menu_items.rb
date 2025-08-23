FactoryBot.define do
  factory :menu_item do
    sequence(:name) { |n| "#{FFaker::Food.ingredient} #{n}" }
    description { FFaker::Lorem.paragraph }
    price { rand(1.0..100.0).round(2) }

    trait :with_menu do
      after(:create) do |menu_item|
        menu_item.menus << create(:menu)
      end
    end

    trait :with_menus do
      transient do
        menus_count { 2 }
      end

      after(:create) do |menu_item, evaluator|
        create_list(:menu, evaluator.menus_count).each do |menu|
          menu_item.menus << menu
        end
      end
    end
  end
end
