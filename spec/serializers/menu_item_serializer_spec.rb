require 'rails_helper'

RSpec.describe MenuItemSerializer do
  let(:menu_item) { create(:menu_item, :with_menu) }
  let(:serializer) { MenuItemSerializer.new(menu_item) }
  let(:serialized_data) { serializer.serializable_hash }

  describe 'attributes' do
    it 'includes the expected attributes' do
      attributes = serialized_data[:data][:attributes]

      expect(attributes).to include(
        :name,
        :description,
        :price,
        :created_at,
        :updated_at
      )
    end

    it 'returns correct values' do
      attributes = serialized_data[:data][:attributes]

      expect(attributes[:name]).to eq(menu_item.name)
      expect(attributes[:description]).to eq(menu_item.description)
      expect(attributes[:price]).to eq(menu_item.price)
    end
  end

  describe 'relationships' do
    it 'includes menus relationship' do
      relationships = serialized_data[:data][:relationships]

      expect(relationships).to have_key(:menus)
      expect(relationships[:menus][:data]).to be_an(Array)
      expect(relationships[:menus][:data].first[:id]).to eq(menu_item.menus.first.id.to_s)
      expect(relationships[:menus][:data].first[:type]).to eq(:menu)
    end
  end

  describe 'type and id' do
    it 'has correct type and id' do
      data = serialized_data[:data]

      expect(data[:type]).to eq(:menu_item)
      expect(data[:id]).to eq(menu_item.id.to_s)
    end
  end

  describe 'with includes' do
    let(:serializer_with_includes) { MenuItemSerializer.new(menu_item, include: [ :menus ]) }
    let(:serialized_with_includes) { serializer_with_includes.serializable_hash }

    it 'includes menus data in included section' do
      expect(serialized_with_includes).to have_key(:included)
      expect(serialized_with_includes[:included]).to be_an(Array)
      expect(serialized_with_includes[:included].size).to eq(menu_item.menus.count)

      serialized_with_includes[:included].each do |included_item|
        expect(included_item[:type]).to eq(:menu)
        expect(included_item[:attributes]).to include(:name, :description)
      end
    end

    it 'maintains relationship references' do
      relationships = serialized_with_includes[:data][:relationships]
      included_ids = serialized_with_includes[:included].map { |item| item[:id] }

      relationships[:menus][:data].each do |rel|
        expect(included_ids).to include(rel[:id])
      end
    end
  end
end
