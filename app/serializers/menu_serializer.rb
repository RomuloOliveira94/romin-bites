class MenuSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :created_at, :updated_at

  has_many :menu_items, serializer: MenuItemSerializer
end
