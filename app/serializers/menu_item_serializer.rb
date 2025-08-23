class MenuItemSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :price, :created_at, :updated_at

  belongs_to :menu
end
