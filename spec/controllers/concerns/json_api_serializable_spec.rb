require 'rails_helper'

RSpec.describe JsonApiSerializable, type: :controller do
  controller(ActionController::Base) do
    include JsonApiSerializable
    include IncludeBuilder

    allow_include 'relation', :relation
    allow_include 'nested', { parent: :children }

    def index
      render json: { options: build_serializer_options }
    end

    private

    def params
      @params ||= ActionController::Parameters.new(@test_params || {})
    end

    def set_test_params(test_params)
      @test_params = test_params
    end
  end

  describe '#build_serializer_options' do
    it 'returns empty hash when no includes' do
      controller.send(:set_test_params, {})
      expect(controller.send(:build_serializer_options)).to eq({})
    end

    it 'returns options with valid includes' do
      controller.send(:set_test_params, { include: 'relation' })
      expect(controller.send(:build_serializer_options)).to eq({ include: [ :relation ] })
    end

    it 'returns options with multiple includes' do
      controller.send(:set_test_params, { include: 'relation,nested' })
      result = controller.send(:build_serializer_options)
      expect(result[:include]).to contain_exactly(:relation, :nested)
    end

    it 'filters invalid includes' do
      controller.send(:set_test_params, { include: 'relation,invalid' })
      expect(controller.send(:build_serializer_options)).to eq({ include: [ :relation ] })
    end
  end

  describe '#extract_valid_include_params' do
    it 'returns empty array when no includes' do
      controller.send(:set_test_params, {})
      expect(controller.send(:extract_valid_include_params)).to eq([])
    end

    it 'returns valid includes as symbols' do
      controller.send(:set_test_params, { include: 'relation' })
      expect(controller.send(:extract_valid_include_params)).to eq([ :relation ])
    end

    it 'filters out invalid includes' do
      controller.send(:set_test_params, { include: 'relation,invalid,nested' })
      expect(controller.send(:extract_valid_include_params)).to contain_exactly(:relation, :nested)
    end

    it 'handles spaces in include params' do
      controller.send(:set_test_params, { include: ' relation , nested ' })
      expect(controller.send(:extract_valid_include_params)).to contain_exactly(:relation, :nested)
    end
  end

  describe 'fallback behavior' do
    controller(ActionController::Base) do
      include JsonApiSerializable

      def index
        render json: { options: build_serializer_options }
      end

      private

      def params
        @params ||= ActionController::Parameters.new(@test_params || {})
      end

      def set_test_params(test_params)
        @test_params = test_params
      end
    end

    it 'uses fallback when IncludeBuilder not available' do
      controller.send(:set_test_params, { include: 'relation,nested' })
      expect(controller.send(:build_serializer_options)).to eq({ include: [ :relation, :nested ] })
    end
  end
end
