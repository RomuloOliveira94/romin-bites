require 'rails_helper'

RSpec.describe MenuSerializer do
  let(:menu) { create(:menu, :with_menu_items, menu_items_count: 2) }
  let(:serializer) { MenuSerializer.new(menu) }
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

      expect(attributes[:name]).to eq(menu.name)
      expect(attributes[:description]).to eq(menu.description)
    end
  end

  describe 'relationships' do
    it 'includes menu_items relationship' do
      relationships = serialized_data[:data][:relationships]

      expect(relationships).to have_key(:menu_items)
      expect(relationships[:menu_items][:data]).to be_an(Array)
      expect(relationships[:menu_items][:data].size).to eq(2)

      menu.menu_items.each do |menu_item|
        expect(relationships[:menu_items][:data]).to include(
          { id: menu_item.id.to_s, type: :menu_item }
        )
      end
    end
  end

  describe 'type and id' do
    it 'has correct type and id' do
      data = serialized_data[:data]

      expect(data[:type]).to eq(:menu)
      expect(data[:id]).to eq(menu.id.to_s)
    end
  end

  describe 'with includes' do
    let(:serializer_with_includes) { MenuSerializer.new(menu, include: [ :menu_items ]) }
    let(:serialized_with_includes) { serializer_with_includes.serializable_hash }

    it 'includes menu_items data in included section' do
      expect(serialized_with_includes).to have_key(:included)
      expect(serialized_with_includes[:included]).to be_an(Array)
      expect(serialized_with_includes[:included].size).to eq(2)

      serialized_with_includes[:included].each do |included_item|
        expect(included_item[:type]).to eq(:menu_item)
        expect(included_item[:attributes]).to include(:name, :price)
      end
    end

    it 'maintains relationship references' do
      relationships = serialized_with_includes[:data][:relationships]
      included_ids = serialized_with_includes[:included].map { |item| item[:id] }

      relationships[:menu_items][:data].each do |rel|
        expect(included_ids).to include(rel[:id])
      end
    end
  end
end
