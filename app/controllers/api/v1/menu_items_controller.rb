class Api::V1::MenuItemsController < ApplicationController
  before_action :set_menu_item, only: [ :show ]

  def index
    menu_items = MenuItem.all
    options = build_serializer_options
    render json: MenuItemSerializer.new(menu_items, options).serializable_hash, status: :ok
  end

  def show
    options = build_serializer_options
    render json: MenuItemSerializer.new(@menu_item, options).serializable_hash, status: :ok
  end

  private

  def build_serializer_options
    options = {}
    if params[:include].present?
      options[:include] = params[:include].split(",").map(&:to_sym)
    end
    options
  end

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Menu item not found" }, status: :not_found
  end
end
