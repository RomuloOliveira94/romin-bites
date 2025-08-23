require 'rails_helper'

RSpec.describe MenuSerializer do
  let(:menu) { create(:menu) }
  let!(:menu_items) { create_list(:menu_item, 2, menu: menu) }
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

      menu_items.each do |menu_item|
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
end
