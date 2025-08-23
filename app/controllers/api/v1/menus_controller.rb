class Api::V1::MenusController < ApplicationController
  include JsonApiSerializable
  include IncludeBuilder

  allow_include "menu_items", :menu_items

  before_action :set_menu, only: [ :show ]

  def index
    menus = Menu.includes(build_includes)
    options = build_serializer_options
    render json: MenuSerializer.new(menus, options).serializable_hash, status: :ok
  end

  def show
    options = build_serializer_options
    render json: MenuSerializer.new(@menu, options).serializable_hash, status: :ok
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: I18n.t("errors.not_found.menu") }, status: :not_found
  end
end
