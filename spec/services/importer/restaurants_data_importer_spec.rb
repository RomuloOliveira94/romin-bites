require 'rails_helper'

RSpec.describe Importer::RestaurantsDataImporter do
  let(:json_data) do
    {
      "restaurants" => [
        {
          "name" => "Test Restaurant",
          "menus" => [
            {
              "name" => "Main Menu",
              "menu_items" => [
                { "name" => "Burger", "price" => "15.99", "description" => "Delicious burger" }
              ]
            }
          ]
        }
      ]
    }
  end

  let(:file) { StringIO.new(json_data.to_json) }
  let(:importer) { described_class.new(file) }

  describe '#import!' do
    context 'with valid data' do
      it 'creates restaurant, menu and menu item' do
        expect { importer.import! }.to change(Restaurant, :count).by(1)
          .and change(Menu, :count).by(1)
          .and change(MenuItem, :count).by(1)
      end

      it 'returns success result' do
        result = importer.import!

        expect(result[:success]).to be true
        expect(result[:stats][:restaurants_created]).to eq 1
        expect(result[:stats][:menus_created]).to eq 1
        expect(result[:stats][:menu_items_created]).to eq 1
        expect(result[:logs]).to have_key(:restaurants)
        expect(result[:logs]).to have_key(:menus)
        expect(result[:logs]).to have_key(:menu_items)
        expect(result[:logs]).to have_key(:associations)
      end

      it 'categorizes logs correctly' do
        result = importer.import!

        expect(result[:logs][:restaurants][:success]).not_to be_empty
        expect(result[:logs][:menus][:success]).not_to be_empty
        expect(result[:logs][:menu_items][:success]).not_to be_empty
        expect(result[:logs][:associations][:success]).not_to be_empty

        expect(result[:logs][:restaurants][:success].first).to include("Test Restaurant")
        expect(result[:logs][:menus][:success].first).to include("Main Menu")
        expect(result[:logs][:menu_items][:success].first).to include("Burger")
        expect(result[:logs][:associations][:success].first).to include("Associated")
      end

      it 'associates menu item with menu' do
        importer.import!

        restaurant = Restaurant.find_by(name: "Test Restaurant")
        menu = restaurant.menus.first
        menu_item = MenuItem.find_by(name: "Burger")

        expect(menu.menu_items).to include(menu_item)
      end
    end

    context 'with existing records' do
      before do
        Restaurant.create!(name: "Test Restaurant")
      end

      it 'finds existing restaurant' do
        expect { importer.import! }.not_to change(Restaurant, :count)

        result = importer.import!
        expect(result[:stats][:restaurants_found]).to eq 1
      end
    end

    context 'with invalid JSON' do
      let(:file) { StringIO.new("invalid json") }

      it 'returns error result' do
        result = importer.import!

        expect(result[:success]).to be false
        expect(result[:message]).to include("Invalid JSON format")
      end
    end

    context 'with alternative field names' do
      let(:json_data_with_dishes) do
        {
          "restaurants" => [
            {
              "name" => "Casa del Poppo",
              "menus" => [
                {
                  "name" => "lunch",
                  "dishes" => [
                    { "name" => "Chicken Wings", "price" => "9.00" }
                  ]
                }
              ]
            }
          ]
        }
      end

      let(:file_with_dishes) { StringIO.new(json_data_with_dishes.to_json) }
      let(:importer_with_dishes) { described_class.new(file_with_dishes) }

      it 'detects alternative key and processes data' do
        result = importer_with_dishes.import!

        expect(result[:success]).to be true
        expect(MenuItem.find_by(name: "Chicken Wings")).to be_present
      end
    end

    context 'with invalid data' do
      context 'restaurant without name' do
        let(:invalid_restaurant_data) do
          {
            "restaurants" => [
              {
                "description" => "Restaurant without name",
                "menus" => []
              }
            ]
          }
        end

        let(:invalid_file) { StringIO.new(invalid_restaurant_data.to_json) }
        let(:invalid_importer) { described_class.new(invalid_file) }

        it 'handles missing restaurant name gracefully' do
          result = invalid_importer.import!

          expect(result[:success]).to be false
          expect(result[:logs][:restaurants][:error]).not_to be_empty
          expect(result[:logs][:restaurants][:error].first).to include("Name can't be blank")
          expect(result[:stats][:restaurants_created]).to eq 0
        end
      end

      context 'menu without name' do
        let(:invalid_menu_data) do
          {
            "restaurants" => [
              {
                "name" => "Valid Restaurant",
                "menus" => [
                  {
                    "description" => "Menu without name",
                    "menu_items" => []
                  }
                ]
              }
            ]
          }
        end

        let(:invalid_menu_file) { StringIO.new(invalid_menu_data.to_json) }
        let(:invalid_menu_importer) { described_class.new(invalid_menu_file) }

        it 'creates restaurant but fails on invalid menu' do
          result = invalid_menu_importer.import!

          expect(result[:success]).to be false
          expect(result[:stats][:restaurants_created]).to eq 1
          expect(result[:stats][:menus_created]).to eq 0
          expect(result[:logs][:menus][:error]).not_to be_empty
          expect(result[:logs][:menus][:error].first).to include("Name can't be blank")
        end
      end

      context 'menu item without name' do
        let(:invalid_menu_item_data) do
          {
            "restaurants" => [
              {
                "name" => "Valid Restaurant",
                "menus" => [
                  {
                    "name" => "Valid Menu",
                    "menu_items" => [
                      {
                        "price" => "10.99",
                        "description" => "Item without name"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        end

        let(:invalid_item_file) { StringIO.new(invalid_menu_item_data.to_json) }
        let(:invalid_item_importer) { described_class.new(invalid_item_file) }

        it 'creates restaurant and menu but fails on invalid menu item' do
          result = invalid_item_importer.import!

          expect(result[:success]).to be false
          expect(result[:stats][:restaurants_created]).to eq 1
          expect(result[:stats][:menus_created]).to eq 1
          expect(result[:stats][:menu_items_created]).to eq 0
          expect(result[:logs][:menu_items][:error]).not_to be_empty
          expect(result[:logs][:menu_items][:error].first).to include("Name can't be blank")
        end
      end

      context 'menu item with negative price' do
        let(:negative_price_data) do
          {
            "restaurants" => [
              {
                "name" => "Valid Restaurant",
                "menus" => [
                  {
                    "name" => "Valid Menu",
                    "menu_items" => [
                      {
                        "name" => "Invalid Item",
                        "price" => "-5.99",
                        "description" => "Item with negative price"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        end

        let(:negative_price_file) { StringIO.new(negative_price_data.to_json) }
        let(:negative_price_importer) { described_class.new(negative_price_file) }

        it 'creates restaurant and menu but fails on invalid price' do
          result = negative_price_importer.import!

          expect(result[:success]).to be false
          expect(result[:stats][:restaurants_created]).to eq 1
          expect(result[:stats][:menus_created]).to eq 1
          expect(result[:stats][:menu_items_created]).to eq 0
          expect(result[:logs][:menu_items][:error]).not_to be_empty
          expect(result[:logs][:menu_items][:error].first).to include("must be greater than or equal to 0")
        end
      end

      context 'duplicate menu item names' do
        before do
          MenuItem.create!(name: "Existing Item", price: 10.99)
        end

        let(:duplicate_item_data) do
          {
            "restaurants" => [
              {
                "name" => "Valid Restaurant",
                "menus" => [
                  {
                    "name" => "Valid Menu",
                    "menu_items" => [
                      {
                        "name" => "Existing Item",
                        "price" => "15.99",
                        "description" => "Trying to create duplicate"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        end

        let(:duplicate_file) { StringIO.new(duplicate_item_data.to_json) }
        let(:duplicate_importer) { described_class.new(duplicate_file) }

        it 'finds existing menu item instead of creating duplicate' do
          result = duplicate_importer.import!

          expect(result[:success]).to be true
          expect(result[:stats][:restaurants_created]).to eq 1
          expect(result[:stats][:menus_created]).to eq 1
          expect(result[:stats][:menu_items_created]).to eq 0
          expect(result[:stats][:menu_items_found]).to eq 1
          expect(result[:logs][:menu_items][:success].first).to include("already exists")
        end
      end

      context 'mixed valid and invalid data' do
        let(:mixed_data) do
          {
            "restaurants" => [
              {
                "name" => "Valid Restaurant",
                "menus" => [
                  {
                    "name" => "Valid Menu",
                    "menu_items" => [
                      {
                        "name" => "Valid Item",
                        "price" => "10.99",
                        "description" => "This is valid"
                      },
                      {
                        "price" => "15.99",
                        "description" => "Missing name"
                      }
                    ]
                  }
                ]
              },
              {
                "description" => "Restaurant without name",
                "menus" => []
              }
            ]
          }
        end

        let(:mixed_file) { StringIO.new(mixed_data.to_json) }
        let(:mixed_importer) { described_class.new(mixed_file) }

        it 'processes valid data and logs errors for invalid data' do
          result = mixed_importer.import!

          expect(result[:success]).to be false
          expect(result[:stats][:restaurants_created]).to eq 1
          expect(result[:stats][:menus_created]).to eq 1
          expect(result[:stats][:menu_items_created]).to eq 1

          expect(result[:logs][:restaurants][:success]).not_to be_empty
          expect(result[:logs][:restaurants][:error]).not_to be_empty
          expect(result[:logs][:menu_items][:success]).not_to be_empty
          expect(result[:logs][:menu_items][:error]).not_to be_empty
        end
      end
    end
  end
end
