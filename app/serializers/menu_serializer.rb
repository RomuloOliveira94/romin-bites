class MenuSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :created_at, :updated_at
end
