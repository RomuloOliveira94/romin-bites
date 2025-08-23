require 'rails_helper'

RSpec.describe 'Api::V1::Restaurants', type: :request do
  describe 'GET /api/v1/restaurants' do
    let!(:restaurants) { create_list(:restaurant, 3) }

    it 'returns all restaurants' do
      get '/api/v1/restaurants'

      expect_json_response
      expect_collection_size(3)
      expect_resource_attributes('name', 'description')
    end

    context 'with include parameter' do
      let!(:restaurant) { create(:restaurant, :with_menus) }

      it 'includes menus when requested' do
        get '/api/v1/restaurants?include=menus'

        expect_json_response
        expect_relationship('menus')
        expect_included_resources('menu', 2)
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
    end

    context 'with include parameter' do
      let!(:restaurant) { create(:restaurant, :with_menus) }

      it 'includes menus when requested' do
        get "/api/v1/restaurants/#{restaurant.id}?include=menus"

        expect_json_response
        expect_resource_type('restaurant')
        expect_relationship('menus')
        expect_included_resources('menu', 2)
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
    end
  end
end
