require 'rails_helper'

RSpec.describe RestaurantSerializer do
  let(:restaurant) { create(:restaurant, :with_menus) }
  let(:serializer) { RestaurantSerializer.new(restaurant) }
  let(:serialized_data) { serializer.serializable_hash }

  describe 'attributes' do
    it 'includes the expected attributes' do
      attributes = serialized_data[:data][:attributes]

      expect(attributes).to include(
        :name,
        :description,
        :created_at,
        :updated_at
      )
    end

    it 'returns correct values' do
      attributes = serialized_data[:data][:attributes]

      expect(attributes[:name]).to eq(restaurant.name)
      expect(attributes[:description]).to eq(restaurant.description)
    end
  end

  describe 'relationships' do
    it 'includes menus relationship' do
      relationships = serialized_data[:data][:relationships]

      expect(relationships).to have_key(:menus)
      expect(relationships[:menus][:data]).to be_an(Array)
      expect(relationships[:menus][:data].size).to eq(restaurant.menus.count)

      restaurant.menus.each do |menu|
        expect(relationships[:menus][:data]).to include(
          { id: menu.id.to_s, type: :menu }
        )
      end
    end
  end

  describe 'type and id' do
    it 'has correct type and id' do
      data = serialized_data[:data]

      expect(data[:type]).to eq(:restaurant)
      expect(data[:id]).to eq(restaurant.id.to_s)
    end
  end

  describe 'with includes' do
    let(:serializer_with_includes) { RestaurantSerializer.new(restaurant, include: [ :menus ]) }
    let(:serialized_with_includes) { serializer_with_includes.serializable_hash }

    it 'includes menus data in included section' do
      expect(serialized_with_includes).to have_key(:included)
      expect(serialized_with_includes[:included]).to be_an(Array)
      expect(serialized_with_includes[:included].size).to eq(restaurant.menus.count)

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
