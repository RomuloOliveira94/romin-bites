module Importer
  class JsonImporter
    def initialize(file)
      @file = file
    end

    def import!
      JSON.parse(@file.read)
    rescue JSON::ParserError => e
      raise "Invalid JSON format: #{e.message}"
    rescue StandardError => e
      raise "Error reading file: #{e.message}"
    end
  end
end
