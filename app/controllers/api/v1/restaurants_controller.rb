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

  private

  def set_restaurant
    @restaurant = Restaurant.includes(build_includes).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Restaurant not found" }, status: :not_found
  end
end
