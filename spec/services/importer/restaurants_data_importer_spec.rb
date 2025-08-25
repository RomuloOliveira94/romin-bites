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
  end
end
