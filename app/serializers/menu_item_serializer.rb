class MenuItemSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :price, :created_at, :updated_at

  has_many :menus, serializer: MenuSerializer
end
