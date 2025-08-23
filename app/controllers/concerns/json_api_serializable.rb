module JsonApiSerializable
  extend ActiveSupport::Concern

  private

  def build_serializer_options
    options = {}
    if params[:include].present?
      options[:include] = params[:include].split(",").map(&:to_sym)
    end
    options
  end
end
