require 'rails_helper'

RSpec.describe 'Api::V1::Menus', type: :request do
  describe 'GET /api/v1/menus' do
    let!(:menus) { create_list(:menu, 3) }

    it 'returns all menus' do
      get '/api/v1/menus'

      expect_json_response
      expect_collection_size(3)
      expect_resource_attributes('name', 'description')
      expect_resource_type('menu')
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
    end

    it 'returns 404 when menu not found' do
      get '/api/v1/menus/999999'

      expect_json_response(status: :not_found)
    end
  end
end
