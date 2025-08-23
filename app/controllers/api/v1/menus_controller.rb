class Api::V1::MenusController < ApplicationController
  def index
    menus = Menu.all
    render json: MenuSerializer.new(menus).serializable_hash, status: :ok
  end
end
