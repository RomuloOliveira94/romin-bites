
class Api::V1::MenuItemsController < ApplicationController
  include JsonApiSerializable
  include IncludeBuilder

  allow_include "menus", :menus

  before_action :set_menu, only: [ :index ], if: -> { params[:menu_id].present? }
  before_action :set_menu_item, only: [ :show ]

  def index
    menu_items = if @menu
      @menu.menu_items.includes(build_includes)
    else
      MenuItem.includes(build_includes)
    end
    options = build_serializer_options
    render json: MenuItemSerializer.new(menu_items, options).serializable_hash, status: :ok
  end

  def show
    options = build_serializer_options
    render json: MenuItemSerializer.new(@menu_item, options).serializable_hash, status: :ok
  end

  private

  def set_menu
    @menu = Menu.find(params[:menu_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t("errors.not_found.menu") }, status: :not_found
  end

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t("errors.not_found.menu_item") }, status: :not_found
  end
end
