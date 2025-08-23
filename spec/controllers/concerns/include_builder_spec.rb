require 'rails_helper'

RSpec.describe IncludeBuilder, type: :controller do
  controller(ActionController::Base) do
    include IncludeBuilder

    allow_include 'relation', :relation
    allow_include 'nested', { parent: :children }

    def index
      render json: { includes: build_includes }
    end

    private

    def params
      @params ||= ActionController::Parameters.new(@test_params || {})
    end

    def set_test_params(test_params)
      @test_params = test_params
    end
  end

  describe '#build_includes' do
    it 'returns empty array when no includes' do
      controller.send(:set_test_params, {})
      expect(controller.send(:build_includes)).to eq([])
    end

    it 'returns valid single include' do
      controller.send(:set_test_params, { include: 'relation' })
      expect(controller.send(:build_includes)).to eq([ :relation ])
    end

    it 'returns valid nested include' do
      controller.send(:set_test_params, { include: 'nested' })
      expect(controller.send(:build_includes)).to eq([ { parent: :children } ])
    end

    it 'returns multiple valid includes' do
      controller.send(:set_test_params, { include: 'relation,nested' })
      expect(controller.send(:build_includes)).to contain_exactly(:relation, { parent: :children })
    end

    it 'ignores invalid includes' do
      controller.send(:set_test_params, { include: 'invalid,fake' })
      expect(controller.send(:build_includes)).to eq([])
    end

    it 'filters valid from invalid' do
      controller.send(:set_test_params, { include: 'relation,invalid,nested' })
      expect(controller.send(:build_includes)).to contain_exactly(:relation, { parent: :children })
    end

    it 'handles spaces' do
      controller.send(:set_test_params, { include: ' relation , nested ' })
      expect(controller.send(:build_includes)).to contain_exactly(:relation, { parent: :children })
    end
  end

  describe '.allow_include' do
    let(:test_class) { Class.new(ActionController::Base) { include IncludeBuilder } }

    it 'adds to allowed includes' do
      test_class.allow_include('test', :test)
      expect(test_class.allowed_includes).to include('test' => :test)
    end

    it 'supports nested associations' do
      test_class.allow_include('nested', { parent: :child })
      expect(test_class.allowed_includes).to include('nested' => { parent: :child })
    end
  end

  describe '.allowed_includes' do
    let(:test_class) { Class.new(ActionController::Base) { include IncludeBuilder } }

    it 'starts empty' do
      expect(test_class.allowed_includes).to eq({})
    end

    it 'isolates between classes' do
      class_a = Class.new(ActionController::Base) { include IncludeBuilder }
      class_b = Class.new(ActionController::Base) { include IncludeBuilder }

      class_a.allow_include('a', :a)
      class_b.allow_include('b', :b)

      expect(class_a.allowed_includes).to eq('a' => :a)
      expect(class_b.allowed_includes).to eq('b' => :b)
    end
  end
end
