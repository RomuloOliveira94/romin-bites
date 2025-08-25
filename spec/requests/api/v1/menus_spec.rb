require 'rails_helper'

RSpec.describe 'Api::V1::Menus', type: :request do
  describe 'GET /api/v1/menus' do
    let!(:menus) { create_list(:menu, 3) }

    it 'returns all menus' do
      get '/api/v1/menus'

      expect_json_response
      expect_collection_size(3)
      expect_resource_attributes('name', 'description')

      menus.each do |menu|
        menu_data = json_data.find { |m| m['id'] == menu.id.to_s }
        expect(menu_data['attributes']['name']).to eq(menu.name)
        expect(menu_data['attributes']['description']).to eq(menu.description)
      end
    end

    context 'with include parameter' do
      let!(:menu) { create(:menu, :with_menu_items, menu_items_count: 2) }

      it 'includes menu_items when requested' do
        get '/api/v1/menus?include=menu_items'

        expect_json_response
        expect_relationship('menu_items')
        expect_included_resources('menu_item', 2)
      end

      it 'does not include menu_items without include parameter' do
        get '/api/v1/menus'

        expect_json_response
        expect(json_included).to be_nil
      end
    end
  end

  describe 'GET /api/v1/restaurants/:restaurant_id/menus' do
    let!(:restaurant) { create(:restaurant) }
    let!(:restaurant_menus) { create_list(:menu, 2, restaurant: restaurant) }
    let!(:other_menus) { create_list(:menu, 3) }

    it 'returns only menus for the specified restaurant' do
      get "/api/v1/restaurants/#{restaurant.id}/menus"

      expect_json_response
      expect_collection_size(2)
      expect_resource_attributes('name', 'description')

      restaurant_menus.each do |menu|
        menu_data = json_data.find { |m| m['id'] == menu.id.to_s }
        expect(menu_data['attributes']['name']).to eq(menu.name)
        expect(menu_data['attributes']['description']).to eq(menu.description)
      end

      other_menus.each do |menu|
        menu_data = json_data.find { |m| m['id'] == menu.id.to_s }
        expect(menu_data).to be_nil
      end
    end

    it 'returns 404 when restaurant not found' do
      get '/api/v1/restaurants/999999/menus'

      expect_json_response(status: :not_found)
      expect(json_error).to eq(I18n.t('errors.not_found.restaurant'))
    end

    context 'with include parameter' do
      let!(:menu_with_items) { create(:menu, :with_menu_items, restaurant: restaurant) }

      it 'includes menu_items when requested' do
        get "/api/v1/restaurants/#{restaurant.id}/menus?include=menu_items"

        expect_json_response
        expect_relationship('menu_items')
        expect_included_resources('menu_item', 3)
      end
    end
  end

  describe 'GET /api/v1/menus/:id' do
    let!(:menu) { create(:menu) }

    it 'returns a specific menu' do
      get "/api/v1/menus/#{menu.id}"

      expect_json_response
      expect_resource_type('menu')
      expect_resource_id(menu.id)
      expect(json_data['attributes']['name']).to eq(menu.name)
      expect(json_data['attributes']['description']).to eq(menu.description)
      expect(json_data['attributes']['created_at']).to be_present
      expect(json_data['attributes']['updated_at']).to be_present
    end

    context 'with include parameter' do
      let!(:menu) { create(:menu, :with_menu_items) }

      it 'includes menu_items when requested' do
        get "/api/v1/menus/#{menu.id}?include=menu_items"

        expect_json_response
        expect_resource_type('menu')
        expect_relationship('menu_items')
        expect_included_resources('menu_item', 3)

        included_items = json_included.select { |i| i['type'] == 'menu_item' }
        menu.menu_items.each do |item|
          included_item = included_items.find { |i| i['id'] == item.id.to_s }
          expect(included_item['attributes']['name']).to eq(item.name)
          expect(included_item['attributes']['price']).to eq(item.price.to_s)
        end
      end

      it 'does not include menu_items when not requested' do
        get "/api/v1/menus/#{menu.id}"

        expect_json_response
        expect(json_included).to be_nil
      end
    end

    it 'returns 404 when menu not found' do
      get '/api/v1/menus/999999'

      expect_json_response(status: :not_found)
      expect(json_error).to eq(I18n.t('errors.not_found.menu'))
    end
  end
end
