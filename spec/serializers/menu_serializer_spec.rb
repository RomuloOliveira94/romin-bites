require 'rails_helper'

RSpec.describe MenuSerializer do
  let(:menu) { create(:menu) }
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

  describe 'type and id' do
    it 'has correct type and id' do
      data = serialized_data[:data]

      expect(data[:type]).to eq(:menu)
      expect(data[:id]).to eq(menu.id.to_s)
    end
  end
end
