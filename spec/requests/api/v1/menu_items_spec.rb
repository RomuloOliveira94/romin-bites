require 'rails_helper'

RSpec.describe 'Api::V1::MenuItems', type: :request do
  describe 'GET /api/v1/menu_items' do
    let!(:menu_items) { create_list(:menu_item, 3, :with_menu) }

    it 'returns all menu items' do
      get '/api/v1/menu_items'

      expect_json_response
      expect_collection_size(3)
      expect_resource_attributes('name', 'price', 'description')

      menu_items.each do |menu_item|
        item_data = json_data.find { |i| i['id'] == menu_item.id.to_s }
        expect(item_data['attributes']['name']).to eq(menu_item.name)
        expect(item_data['attributes']['price']).to eq(menu_item.price.to_s)
        expect(item_data['attributes']['description']).to eq(menu_item.description)
      end
    end

    context 'with include parameter' do
      it 'includes menus when requested' do
        get '/api/v1/menu_items?include=menus'

        expect_json_response
        expect_collection_size(3)
        expect_relationship('menus')
        expect_included_resources('menu', 3)
      end

      it 'does not include menus without include parameter' do
        get '/api/v1/menu_items'

        expect_json_response
        expect(json_included).to be_nil
      end
    end
  end

  describe 'GET /api/v1/menus/:menu_id/menu_items' do
    let!(:menu) { create(:menu) }
    let!(:menu_items) { create_list(:menu_item, 3) }
    let!(:other_menu_items) { create_list(:menu_item, 2) }

    before do
      menu_items.each { |item| menu.menu_items << item }
    end

    it 'returns only menu items for the specified menu' do
      get "/api/v1/menus/#{menu.id}/menu_items"

      expect_json_response
      expect_collection_size(3)
      expect_resource_attributes('name', 'price', 'description')

      menu_items.each do |menu_item|
        item_data = json_data.find { |i| i['id'] == menu_item.id.to_s }
        expect(item_data['attributes']['name']).to eq(menu_item.name)
        expect(item_data['attributes']['price']).to eq(menu_item.price.to_s)
        expect(item_data['attributes']['description']).to eq(menu_item.description)
      end

      other_menu_items.each do |item|
        item_data = json_data.find { |i| i['id'] == item.id.to_s }
        expect(item_data).to be_nil
      end
    end

    it 'returns 404 when menu not found' do
      get '/api/v1/menus/999999/menu_items'

      expect_json_response(status: :not_found)
      expect(json_error).to eq(I18n.t('errors.not_found.menu'))
    end

    context 'with include parameter' do
      it 'includes menus when requested' do
        get "/api/v1/menus/#{menu.id}/menu_items?include=menus"

        expect_json_response
        expect_relationship('menus')
        expect_included_resources('menu', 1)

        included_menu = json_included.find { |i| i['type'] == 'menu' }
        expect(included_menu['id']).to eq(menu.id.to_s)
        expect(included_menu['attributes']['name']).to eq(menu.name)
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
      expect(json_data['attributes']['price']).to eq(menu_item.price.to_s)
      expect(json_data['attributes']['description']).to eq(menu_item.description)
      expect(json_data['attributes']['created_at']).to be_present
      expect(json_data['attributes']['updated_at']).to be_present
    end

    context 'with include parameter' do
      it 'includes menus when requested' do
        get "/api/v1/menu_items/#{menu_item.id}?include=menus"

        expect_json_response
        expect_resource_type('menu_item')
        expect_relationship('menus')
        expect_included_resources('menu', 3)

        included_menus = json_included.select { |i| i['type'] == 'menu' }
        menu_item.menus.each do |menu|
          included_menu = included_menus.find { |i| i['id'] == menu.id.to_s }
          expect(included_menu['attributes']['name']).to eq(menu.name)
          expect(included_menu['attributes']['description']).to eq(menu.description)
        end
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
      expect(json_error).to eq(I18n.t('errors.not_found.menu_item'))
    end
  end
end
