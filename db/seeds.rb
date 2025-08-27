# Clear existing data
puts "Clearing existing data..."
MenuItem.delete_all
Menu.delete_all
Restaurant.delete_all

ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name IN ('restaurants', 'menus', 'menu_items', 'menu_items_menus')")

puts "Creating restaurants..."

restaurants_data = [
  { name: "Bella Italia", description: "Authentic Italian cuisine with fresh ingredients", cuisine: "Italian" },
  { name: "Dragon Palace", description: "Traditional Chinese dishes and modern fusion", cuisine: "Chinese" },
  { name: "El Sombrero", description: "Authentic Mexican flavors and vibrant atmosphere", cuisine: "Mexican" },
  { name: "The Burger Joint", description: "Gourmet burgers and craft beers", cuisine: "American" },
  { name: "Sakura Sushi", description: "Fresh sushi and Japanese specialties", cuisine: "Japanese" },
  { name: "Le Petit Bistro", description: "Classic French cuisine in an intimate setting", cuisine: "French" }
]

restaurants = []
restaurants_data.each do |restaurant_data|
  restaurant = Restaurant.create!(
    name: restaurant_data[:name],
    description: restaurant_data[:description]
  )
  restaurants << { restaurant: restaurant, cuisine: restaurant_data[:cuisine] }
  puts "  Created #{restaurant.name}"
end

puts "Creating menus..."

menu_templates = {
  "Italian" => [ "Lunch Menu", "Dinner Menu", "Wine & Appetizers" ],
  "Chinese" => [ "Dim Sum Menu", "Main Course", "Vegetarian Selection" ],
  "Mexican" => [ "Tacos & Burritos", "Dinner Specials", "Drinks & Appetizers" ],
  "American" => [ "Burger Menu", "Sides & Appetizers", "Desserts" ],
  "Japanese" => [ "Sushi Selection", "Hot Dishes", "Lunch Bento" ],
  "French" => [ "Prix Fixe Menu", "À la Carte", "Wine Selection" ]
}

menus = []
restaurants.each do |restaurant_info|
  restaurant = restaurant_info[:restaurant]
  cuisine = restaurant_info[:cuisine]

  menu_templates[cuisine].each do |menu_name|
    menu = restaurant.menus.create!(
      name: menu_name,
      description: FFaker::Lorem.sentence(4)
    )
    menus << { menu: menu, cuisine: cuisine, menu_type: menu_name }
    puts "  Created #{menu_name} for #{restaurant.name}"
  end
end

puts "Creating menu items..."

menu_items_by_cuisine = {
  "Italian" => [
    { name: "Margherita Pizza", description: "Fresh tomatoes, mozzarella, basil", price: 16.99 },
    { name: "Pasta Carbonara", description: "Creamy pasta with bacon and parmesan", price: 18.50 },
    { name: "Risotto ai Funghi", description: "Mushroom risotto with truffle oil", price: 22.00 },
    { name: "Tiramisu", description: "Classic Italian dessert", price: 8.99 },
    { name: "Bruschetta", description: "Toasted bread with tomatoes and herbs", price: 9.50 },
    { name: "Osso Buco", description: "Braised veal shanks with vegetables", price: 28.00 }
  ],
  "Chinese" => [
    { name: "Kung Pao Chicken", description: "Spicy chicken with peanuts and vegetables", price: 15.99 },
    { name: "Sweet and Sour Pork", description: "Crispy pork with pineapple sauce", price: 16.50 },
    { name: "Mapo Tofu", description: "Spicy tofu in Sichuan sauce", price: 13.99 },
    { name: "Dumplings", description: "Steamed pork and vegetable dumplings", price: 11.00 },
    { name: "Fried Rice", description: "Wok-fried rice with eggs and vegetables", price: 12.50 },
    { name: "Peking Duck", description: "Roasted duck with pancakes and sauce", price: 32.00 }
  ],
  "Mexican" => [
    { name: "Beef Tacos", description: "Seasoned beef with fresh salsa", price: 12.99 },
    { name: "Chicken Burrito", description: "Grilled chicken with rice and beans", price: 14.50 },
    { name: "Guacamole", description: "Fresh avocado dip with tortilla chips", price: 8.99 },
    { name: "Quesadilla", description: "Cheese-filled tortilla with peppers", price: 11.50 },
    { name: "Enchiladas", description: "Rolled tortillas with sauce and cheese", price: 16.00 },
    { name: "Churros", description: "Fried pastry with cinnamon sugar", price: 6.99 }
  ],
  "American" => [
    { name: "Classic Cheeseburger", description: "Beef patty with cheese and fixings", price: 14.99 },
    { name: "BBQ Bacon Burger", description: "Burger with BBQ sauce and crispy bacon", price: 17.50 },
    { name: "Chicken Wings", description: "Buffalo wings with celery and blue cheese", price: 12.99 },
    { name: "French Fries", description: "Crispy golden fries", price: 5.99 },
    { name: "Onion Rings", description: "Beer-battered onion rings", price: 7.50 },
    { name: "Apple Pie", description: "Homemade apple pie with vanilla ice cream", price: 8.99 }
  ],
  "Japanese" => [
    { name: "Salmon Sashimi", description: "Fresh salmon slices", price: 18.99 },
    { name: "California Roll", description: "Crab, avocado, and cucumber roll", price: 12.50 },
    { name: "Chicken Teriyaki", description: "Grilled chicken with teriyaki sauce", price: 16.99 },
    { name: "Miso Soup", description: "Traditional soybean soup", price: 4.99 },
    { name: "Tempura", description: "Lightly battered and fried vegetables", price: 14.50 },
    { name: "Ramen", description: "Rich pork broth with noodles and toppings", price: 15.99 }
  ],
  "French" => [
    { name: "Coq au Vin", description: "Chicken braised in red wine", price: 24.99 },
    { name: "Bouillabaisse", description: "Traditional Provençal fish stew", price: 28.50 },
    { name: "Escargot", description: "Snails in garlic butter", price: 16.99 },
    { name: "French Onion Soup", description: "Rich onion soup with cheese", price: 9.99 },
    { name: "Crème Brûlée", description: "Vanilla custard with caramelized sugar", price: 10.50 },
    { name: "Ratatouille", description: "Traditional vegetable stew", price: 18.00 }
  ]
}

created_menu_items = {}

menu_items_by_cuisine.each do |cuisine, items|
  items.each do |item_data|
    unless created_menu_items[item_data[:name]]
      menu_item = MenuItem.create!(
        name: item_data[:name],
        description: item_data[:description],
        price: item_data[:price]
      )
      created_menu_items[item_data[:name]] = menu_item
      puts "  Created #{menu_item.name} ($#{menu_item.price})"
    end
  end
end

puts "Creating menu associations..."

menus.each do |menu_info|
  menu = menu_info[:menu]
  cuisine = menu_info[:cuisine]

  cuisine_items = menu_items_by_cuisine[cuisine] || []
  selected_items = cuisine_items.sample(rand(3..5))

  selected_items.each do |item_data|
    menu_item = created_menu_items[item_data[:name]]
    if menu_item && !menu.menu_items.include?(menu_item)
      menu.menu_items << menu_item
      puts "  Associated #{menu_item.name} with #{menu.name}"
    end
  end
end

puts "Seeding complete!"
puts "Created:"
puts "  #{Restaurant.count} restaurants"
puts "  #{Menu.count} menus"
puts "  #{MenuItem.count} menu items"
puts "  #{ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM menu_items_menus").first[0]} menu associations"

puts "Database seeded successfully!"
