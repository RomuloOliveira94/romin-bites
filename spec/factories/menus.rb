FactoryBot.define do
  factory :menu do
    sequence(:name) { FFaker::Food.meat }
    description { FFaker::Lorem.paragraph }
    restaurant

    trait :with_menu_item do
      after(:create) do |menu|
        menu_item = create(:menu_item)
        menu.menu_items << menu_item
      end
    end

    trait :with_menu_items do
      transient do
        menu_items_count { 3 }
      end

      after(:create) do |menu, evaluator|
        create_list(:menu_item, evaluator.menu_items_count).each do |menu_item|
          menu.menu_items << menu_item
        end
      end
    end
  end
end
