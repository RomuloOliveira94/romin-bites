class Api::V1::RestaurantsController < ApplicationController
  include JsonApiSerializable

  def index
    restaurants = Restaurant.all
    options = build_serializer_options
    render json: RestaurantSerializer.new(restaurants, options).serializable_hash, status: :ok
  end
end
