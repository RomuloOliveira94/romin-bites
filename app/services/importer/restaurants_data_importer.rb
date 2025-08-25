module Importer
  class RestaurantsDataImporter
    ENTITY_CONFIGS = {
      restaurant: {
        fields: [ :name ],
        children_keys: [ "menus" ]
      },
      menu: {
        fields: [ :name ],
        children_keys: [ "menu_items", "dishes" ]
      },
      menu_item: {
        fields: [ :name, :price, :description ]
      }
    }.freeze

    def initialize(file)
      @file = file
      @logs = {
        restaurants: { success: [], error: [] },
        menus: { success: [], error: [] },
        menu_items: { success: [], error: [] },
        associations: { success: [], error: [] }
      }
      @stats = {
        restaurants_created: 0,
        restaurants_found: 0,
        menus_created: 0,
        menus_found: 0,
        menu_items_created: 0,
        menu_items_found: 0,
        associations_created: 0
      }
    end

    def import!
      ActiveRecord::Base.transaction do
        restaurants_data = load_restaurants_data
        import_all_data(restaurants_data)

        if has_errors?
          {
            success: false,
            message: I18n.t("importers.restaurants.completed_with_errors"),
            logs: @logs,
            stats: @stats
          }
        else
          {
            success: true,
            message: I18n.t("importers.restaurants.success"),
            logs: @logs,
            stats: @stats
          }
        end
      rescue StandardError => e
        Rails.logger.error "Fatal import error: #{e.message}"
        {
          success: false,
          message: I18n.t("importers.restaurants.fatal_error", error: e.message),
          logs: @logs,
          stats: @stats
        }
      end
    end

    private

    def load_restaurants_data
      Importer::JsonImporter.new(@file).import!
    end

    def import_all_data(restaurants_data)
      restaurants_data["restaurants"].each do |restaurant_data|
        begin
          restaurant = create_or_find_restaurant(restaurant_data)
          if restaurant
            menus_data = find_children_data(restaurant_data, :restaurant)
            import_restaurant_menus(restaurant, menus_data) if menus_data
          end
        rescue StandardError => e
          add_log(I18n.t("importers.restaurants.restaurant_error", name: restaurant_data["name"], error: e.message), :error, :restaurants)
        end
      end
    end

    def create_or_find_restaurant(restaurant_data)
      attributes = extract_attributes(restaurant_data, :restaurant)
      created = false

      restaurant = Restaurant.find_or_create_by!(name: attributes[:name]) do |new_restaurant|
        attributes.each { |key, value| new_restaurant.send("#{key}=", value) }
        created = true
      end

      if created
        add_log(I18n.t("importers.restaurants.logs.restaurant_created", name: attributes[:name], id: restaurant.id), :success, :restaurants)
        @stats[:restaurants_created] += 1
      else
        add_log(I18n.t("importers.restaurants.logs.restaurant_found", name: attributes[:name], id: restaurant.id), :success, :restaurants)
        @stats[:restaurants_found] += 1
      end

      restaurant
    rescue StandardError => e
      add_log(I18n.t("importers.restaurants.create_restaurant_error", name: restaurant_data["name"], error: e.message), :error, :restaurants)
      nil
    end

    def import_restaurant_menus(restaurant, menus_data)
      return if menus_data.nil?

      menus_data.each do |menu_data|
        begin
          menu = create_or_find_menu(restaurant, menu_data)
          if menu
            menu_items_data = find_children_data(menu_data, :menu)
            import_menu_items(menu, menu_items_data) if menu_items_data
          end
        rescue StandardError => e
          add_log(I18n.t("importers.restaurants.menu_error", name: menu_data["name"], restaurant: restaurant.name, error: e.message), :error, :menus)
        end
      end
    end

    def create_or_find_menu(restaurant, menu_data)
      attributes = extract_attributes(menu_data, :menu)
      created = false

      menu = restaurant.menus.find_or_create_by!(name: attributes[:name]) do |new_menu|
        attributes.each { |key, value| new_menu.send("#{key}=", value) }
        created = true
      end

      if created
        add_log(I18n.t("importers.restaurants.logs.menu_created", name: attributes[:name], restaurant: restaurant.name, id: menu.id), :success, :menus)
        @stats[:menus_created] += 1
      else
        add_log(I18n.t("importers.restaurants.logs.menu_found", name: attributes[:name], restaurant: restaurant.name, id: menu.id), :success, :menus)
        @stats[:menus_found] += 1
      end

      menu
    rescue StandardError => e
      add_log(I18n.t("importers.restaurants.create_menu_error", name: menu_data["name"], error: e.message), :error, :menus)
      nil
    end

    def import_menu_items(menu, menu_items_data)
      return if menu_items_data.nil?

      menu_items_data.each do |item_data|
        begin
          menu_item = create_or_find_menu_item(item_data)
          associate_menu_item(menu, menu_item) if menu_item
        rescue StandardError => e
          add_log(I18n.t("importers.restaurants.menu_item_error", name: item_data["name"], menu: menu.name, error: e.message), :error, :menu_items)
        end
      end
    end

    def create_or_find_menu_item(item_data)
      attributes = extract_attributes(item_data, :menu_item)
      created = false

      menu_item = MenuItem.find_or_create_by!(name: attributes[:name]) do |new_item|
        attributes.each { |key, value| new_item.send("#{key}=", value) if value.present? }
        created = true
      end

      if created
        add_log(I18n.t("importers.restaurants.logs.menu_item_created", name: attributes[:name], price: attributes[:price], id: menu_item.id), :success, :menu_items)
        @stats[:menu_items_created] += 1
      else
        add_log(I18n.t("importers.restaurants.logs.menu_item_found", name: attributes[:name], id: menu_item.id), :success, :menu_items)
        @stats[:menu_items_found] += 1
      end

      menu_item
    rescue StandardError => e
      add_log(I18n.t("importers.restaurants.create_menu_item_error", name: item_data["name"], error: e.message), :error, :menu_items)
      nil
    end

    def associate_menu_item(menu, menu_item)
      unless menu.menu_items.include?(menu_item)
        menu.menu_items << menu_item
        add_log(I18n.t("importers.restaurants.logs.association_created", item: menu_item.name, menu: menu.name), :success, :associations)
        @stats[:associations_created] += 1
      else
        add_log(I18n.t("importers.restaurants.logs.association_exists", item: menu_item.name, menu: menu.name), :success, :associations)
      end
    rescue StandardError => e
      add_log(I18n.t("importers.restaurants.association_error", item: menu_item.name, menu: menu.name, error: e.message), :error, :associations)
    end

    def extract_attributes(data, entity_type)
      config = ENTITY_CONFIGS[entity_type]
      config[:fields].each_with_object({}) do |field, attributes|
        attributes[field] = data[field.to_s] if data[field.to_s].present?
      end
    end

    def find_children_data(data, entity_type)
      config = ENTITY_CONFIGS[entity_type]
      return nil unless config && data.is_a?(Hash)

      config[:children_keys].map(&:to_s).each do |key|
        return data[key] if data[key].present?
      end

      nil
    end

    def add_log(message, type = :success, category = :restaurants)
      unless @logs.key?(category)
        raise ArgumentError, "Invalid category: #{category}. Valid categories: #{@logs.keys.join(', ')}"
      end

      @logs[category][type] << message
    end

    def has_errors?
      @logs.values.any? { |category| category[:error].any? }
    end
  end
end
