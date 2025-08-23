require 'rails_helper'

RSpec.describe 'Api::V1::MenuItems', type: :request do
  describe 'GET /api/v1/menu_items' do
    let!(:menu_items) { create_list(:menu_item, 3, :with_menu) }

    it 'returns all menu items' do
      get '/api/v1/menu_items'

      expect_json_response
      expect_collection_size(3)
      expect_resource_attributes('name', 'price', 'description')
    end

    context 'with include parameter' do
      it 'includes menus when requested' do
        get '/api/v1/menu_items?include=menus'

        expect_json_response
        expect_collection_size(3)
        expect_relationship('menus')
        expect_included_resources('menu', 3)
      end
    end
  end

  describe 'GET /api/v1/menu_items/:id' do
    let!(:menu_item) { create(:menu_item, :with_menus, menus_count: 3) }

    it 'returns a specific menu item' do
      get "/api/v1/menu_items/#{menu_item.id}"

      expect_json_response
      expect_resource_type('menu_item')
      expect_resource_id(menu_item.id)
      expect(json_data['attributes']['name']).to eq(menu_item.name)
    end

    context 'with include parameter' do
      it 'includes menus when requested' do
        get "/api/v1/menu_items/#{menu_item.id}?include=menus"

        expect_json_response
        expect_resource_type('menu_item')
        expect_relationship('menus')
        expect_included_resources('menu', 3)
      end

      it 'does not include menus when not requested' do
        get "/api/v1/menu_items/#{menu_item.id}"

        expect_json_response
        expect(json_included).to be_nil
      end
    end

    it 'returns 404 when menu item not found' do
      get '/api/v1/menu_items/999999'

      expect_json_response(status: :not_found)
    end
  end
end
