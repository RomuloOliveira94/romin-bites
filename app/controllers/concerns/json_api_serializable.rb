module JsonApiSerializable
  extend ActiveSupport::Concern

  private

  def build_serializer_options
    options = {}

    if respond_to?(:build_includes, true)
      valid_includes = extract_valid_include_params
      options[:include] = valid_includes if valid_includes.any?
    elsif params[:include].present?
      options[:include] = params[:include].split(",").map(&:to_sym)
    end

    options
  end

  def extract_valid_include_params
    return [] unless params[:include].present?

    requested_includes = params[:include].split(",").map(&:strip)
    allowed_includes = self.class.respond_to?(:allowed_includes) ? self.class.allowed_includes : {}

    valid_includes = requested_includes.select { |inc| allowed_includes.key?(inc) }
    valid_includes.map(&:to_sym)
  end
end
