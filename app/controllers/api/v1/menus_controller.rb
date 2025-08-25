
class Api::V1::MenusController < ApplicationController
  include JsonApiSerializable
  include IncludeBuilder

  allow_include "menu_items", :menu_items

  before_action :set_restaurant, only: [ :index ], if: -> { params[:restaurant_id].present? }
  before_action :set_menu, only: [ :show ]

  def index
    menus = if @restaurant
      @restaurant.menus.includes(build_includes)
    else
      Menu.includes(build_includes)
    end
    options = build_serializer_options
    render json: MenuSerializer.new(menus, options).serializable_hash, status: :ok
  end

  def show
    options = build_serializer_options
    render json: MenuSerializer.new(@menu, options).serializable_hash, status: :ok
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t("errors.not_found.restaurant") }, status: :not_found
  end

  def set_menu
    @menu = Menu.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t("errors.not_found.menu") }, status: :not_found
  end
end
