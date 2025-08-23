class Api::V1::MenusController < ApplicationController
  before_action :set_menu, only: [ :show ]

  def index
    menus = Menu.all
    render json: MenuSerializer.new(menus).serializable_hash, status: :ok
  end

  def show
    render json: MenuSerializer.new(@menu).serializable_hash, status: :ok
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Menu not found" }, status: :not_found
  end
end
