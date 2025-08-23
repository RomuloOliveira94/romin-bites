require 'rails_helper'

RSpec.describe 'Api::V1::Restaurants', type: :request do
  describe 'GET /api/v1/restaurants' do
    let!(:restaurants) { create_list(:restaurant, 3) }

    it 'returns all restaurants' do
      get '/api/v1/restaurants'

      expect_json_response
      expect_collection_size(3)
      expect_resource_attributes('name', 'description')

      restaurants.each do |restaurant|
        restaurant_data = json_data.find { |r| r['id'] == restaurant.id.to_s }
        expect(restaurant_data['attributes']['name']).to eq(restaurant.name)
        expect(restaurant_data['attributes']['description']).to eq(restaurant.description)
      end
    end

    context 'with include parameter' do
      let!(:restaurant) { create(:restaurant, :with_menus) }

      it 'includes menus when requested' do
        get '/api/v1/restaurants?include=menus'

        expect_json_response
        expect_relationship('menus')
        expect_included_resources('menu', 2)
      end

      it 'does not include menus without include parameter' do
        get '/api/v1/restaurants'

        expect_json_response
        expect(json_included).to be_nil
      end

      it 'includes nested menu_items when requested' do
        get '/api/v1/restaurants?include=menus.menu_items'

        expect_json_response
        expect_relationship('menus')

        menu_resources = json_included.select { |r| r['type'] == 'menu' }
        expect(menu_resources.size).to eq(2)

        menu_item_resources = json_included.select { |r| r['type'] == 'menu_item' }
        expect(menu_item_resources.size).to be > 0
      end
    end
  end

  describe 'GET /api/v1/restaurants/:id' do
    let!(:restaurant) { create(:restaurant) }

    it 'returns a specific restaurant' do
      get "/api/v1/restaurants/#{restaurant.id}"

      expect_json_response
      expect_resource_type('restaurant')
      expect_resource_id(restaurant.id)
      expect(json_data['attributes']['name']).to eq(restaurant.name)
      expect(json_data['attributes']['description']).to eq(restaurant.description)
      expect(json_data['attributes']['created_at']).to be_present
      expect(json_data['attributes']['updated_at']).to be_present
    end

    context 'with include parameter' do
      let!(:restaurant) { create(:restaurant, :with_menus) }

      it 'includes menus when requested' do
        get "/api/v1/restaurants/#{restaurant.id}?include=menus"

        expect_json_response
        expect_resource_type('restaurant')
        expect_relationship('menus')
        expect_included_resources('menu', 2)

        included_menus = json_included.select { |i| i['type'] == 'menu' }
        restaurant.menus.each do |menu|
          included_menu = included_menus.find { |i| i['id'] == menu.id.to_s }
          expect(included_menu['attributes']['name']).to eq(menu.name)
          expect(included_menu['attributes']['description']).to eq(menu.description)
        end
      end

      it 'includes nested menu_items when requested' do
        get "/api/v1/restaurants/#{restaurant.id}?include=menus.menu_items"

        expect_json_response
        expect_resource_type('restaurant')
        expect_relationship('menus')

        menu_resources = json_included.select { |r| r['type'] == 'menu' }
        expect(menu_resources.size).to eq(2)

        menu_item_resources = json_included.select { |r| r['type'] == 'menu_item' }
        expect(menu_item_resources.size).to be > 0
      end

      it 'does not include menus when not requested' do
        get "/api/v1/restaurants/#{restaurant.id}"

        expect_json_response
        expect(json_included).to be_nil
      end
    end

    it 'returns 404 when restaurant not found' do
      get '/api/v1/restaurants/999999'

      expect_json_response(status: :not_found)
      expect(json_error).to eq(I18n.t('errors.not_found.restaurant'))
    end
  end
end
