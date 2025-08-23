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
end
