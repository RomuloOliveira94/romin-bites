module IncludeBuilder
  extend ActiveSupport::Concern

  private

  def build_includes
    return [] unless params[:include].present?

    includes = []
    include_params = params[:include].split(",").map(&:strip)

    allowed_includes = self.class.allowed_includes

    include_params.each do |param|
      if allowed_includes.key?(param)
        includes << allowed_includes[param]
      end
    end

    includes.uniq
  end

  class_methods do
    def allowed_includes
      @allowed_includes ||= {}
    end

    def allow_include(param, association)
      allowed_includes[param] = association
    end
  end
end
