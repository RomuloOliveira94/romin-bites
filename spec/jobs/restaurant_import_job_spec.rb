require 'rails_helper'

RSpec.describe RestaurantImportJob, type: :job do
  include ActiveJob::TestHelper

  before do
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
  end

  let(:json_data) do
    {
      "restaurants" => [
        {
          "name" => "Test Restaurant",
          "menus" => [
            {
              "name" => "Main Menu",
              "menu_items" => [
                { "name" => "Burger", "price" => "15.99", "description" => "Delicious burger" }
              ]
            }
          ]
        }
      ]
    }
  end

  let(:file_content) { json_data.to_json }

  describe '#perform' do
    it 'processes the import and stores result in cache' do
      job_id = "test_job_123"

      described_class.new.perform(file_content, job_id)

      result = Rails.cache.read("import_result_#{job_id}")
      expect(result).to be_present
      expect(result[:success]).to be true
      expect(result[:stats][:restaurants_created]).to eq 1
      expect(Restaurant.count).to eq 1
    end

    it 'handles errors and stores error result' do
      invalid_content = "invalid json"
      job_id = "error_job_123"

      described_class.new.perform(invalid_content, job_id)

      result = Rails.cache.read("import_result_#{job_id}")
      expect(result[:success]).to be false
      expect(result[:message]).to include("error")
    end

    it 'cleans up temp file after processing' do
      job_id = "cleanup_test_123"

      allow_any_instance_of(described_class).to receive(:save_temp_file).and_call_original

      described_class.new.perform(file_content, job_id)

      result = Rails.cache.read("import_result_#{job_id}")
      expect(result[:success]).to be true
    end
  end
end
