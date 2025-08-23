class RestaurantSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :created_at, :updated_at

  has_many :menus, serializer: MenuSerializer
end
