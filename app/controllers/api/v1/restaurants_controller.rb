class Api::V1::RestaurantsController < ApplicationController
  include JsonApiSerializable
  include IncludeBuilder

  allow_include "menus", :menus
  allow_include "menus.menu_items", { menus: :menu_items }

  before_action :set_restaurant, only: [ :show ]

  def index
    restaurants = Restaurant.includes(build_includes)
    options = build_serializer_options
    render json: RestaurantSerializer.new(restaurants, options).serializable_hash, status: :ok
  end

  def show
    options = build_serializer_options
    render json: RestaurantSerializer.new(@restaurant, options).serializable_hash, status: :ok
  end

  def import
    unless params[:file].present?
      return render json: {
        success: false,
        message: I18n.t("importers.restaurants.jobs.no_file_provided")
      }, status: :unprocessable_content
    end

    begin
      file_content = params[:file].read
      job = RestaurantImportJob.perform_later(file_content)

      render json: {
        success: true,
        message: I18n.t("importers.restaurants.jobs.queued_for_processing"),
        job_id: job.job_id,
        status_url: import_status_api_v1_restaurants_url(job_id: job.job_id)
      }, status: :accepted
    rescue StandardError => e
      render json: {
        success: false,
        message: I18n.t("importers.restaurants.fatal_error", error: e.message)
      }, status: :internal_server_error
    end
  end

  def import_status
    job_id = params[:job_id]
    result = Rails.cache.read("import_result_#{job_id}")

    if result
      render json: result
    else
      render json: {
        success: false,
        message: I18n.t("importers.restaurants.jobs.still_processing"),
        job_id: job_id
      }, status: :accepted
    end
  end

  private

  def set_restaurant
    @restaurant = Restaurant.includes(build_includes).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t("errors.not_found.restaurant") }, status: :not_found
  end
end
