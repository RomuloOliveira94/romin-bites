class Api::V1::MenusController < ApplicationController
  before_action :set_menu, only: [:show]

  def index
    menus = Menu.all
    options = build_serializer_options
    render json: MenuSerializer.new(menus, options).serializable_hash, status: :ok
  end

  def show
    options = build_serializer_options
    render json: MenuSerializer.new(@menu, options).serializable_hash, status: :ok
  end

  private

  def build_serializer_options
    options = {}
    if params[:include].present?
      options[:include] = params[:include].split(',').map(&:to_sym)
    end
    options
  end

  def set_menu
    @menu = Menu.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Menu not found" }, status: :not_found
  end
end
