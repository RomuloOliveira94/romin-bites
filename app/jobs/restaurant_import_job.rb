class RestaurantImportJob < ApplicationJob
  queue_as :default

  def perform(file_content, job_id = nil)
    job_id ||= self.job_id || SecureRandom.uuid

    temp_file = nil
    begin
      temp_file = save_temp_file(file_content)
      file = File.open(temp_file.path)
      result = Importer::RestaurantsDataImporter.new(file).import!

      Rails.cache.write("import_result_#{job_id}", result, expires_in: 1.hour)
    rescue StandardError => e
      error_result = {
        success: false,
        message: I18n.t("importers.restaurants.jobs.import_failed", error: e.message),
        errors: [ e.message ],
        logs: [],
        stats: {}
      }

      Rails.cache.write("import_result_#{job_id}", error_result, expires_in: 1.hour)
    ensure
      if temp_file
        temp_file.close
        temp_file.unlink
      end
    end
  end

  private

  def save_temp_file(content)
    temp_file = Tempfile.new([ "import", ".json" ], Rails.root.join("tmp"))
    temp_file.binmode
    temp_file.write(content)
    temp_file.rewind
    temp_file
  end
end
