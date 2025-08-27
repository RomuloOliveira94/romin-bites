# Romin Bites API Documentation

## 📋 Overview

RESTful API for restaurant management, menus, and menu items, built with Ruby on Rails 8.0.2 following the JSON:API specification.

## 🚀 Tech Stack

- **Ruby on Rails** 8.0.2
- **SQLite3** (Database)
- **JSON:API Serializer** (Response formatting)
- **Puma** (Web server)
- **RSpec** (Testing framework)
- **GitHub Actions** (CI/CD)

## 📦 Installation

### Prerequisites

- Ruby 3.x
- Bundler
- SQLite3

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd romin-bites

# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Run the server
rails server
```

## 📡 API Endpoints

### Base URL

```
https://rominbites.romin.dev.br/api/v1
```

### Authentication

Currently, the API does not require authentication (public access).

---

## 🏪 Restaurants

### List all restaurants

```http
GET /api/v1/restaurants
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/restaurants" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Response:**

```json
{
  "data": [
    {
      "id": "1",
      "type": "restaurant",
      "attributes": {
        "name": "Bella Italia",
        "description": "Authentic Italian cuisine",
        "created_at": "2025-08-25T10:00:00.000Z",
        "updated_at": "2025-08-25T10:00:00.000Z"
      },
      "relationships": {
        "menus": {
          "data": []
        }
      }
    }
  ]
}
```

### Get a specific restaurant

```http
GET /api/v1/restaurants/:id
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/restaurants/1" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

### Include menus with restaurant

```http
GET /api/v1/restaurants/:id?include=menus
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/restaurants/1?include=menus" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Response with includes:**

```json
{
  "data": {
    "id": "1",
    "type": "restaurant",
    "attributes": {
      "name": "Bella Italia",
      "description": "Authentic Italian cuisine",
      "created_at": "2025-08-25T10:00:00.000Z",
      "updated_at": "2025-08-25T10:00:00.000Z"
    },
    "relationships": {
      "menus": {
        "data": [
          {
            "id": "1",
            "type": "menu"
          }
        ]
      }
    }
  },
  "included": [
    {
      "id": "1",
      "type": "menu",
      "attributes": {
        "name": "Lunch Menu",
        "description": "Available from 12:00 to 15:00",
        "created_at": "2025-08-25T10:00:00.000Z",
        "updated_at": "2025-08-25T10:00:00.000Z"
      },
      "relationships": {
        "menu_items": {
          "data": []
        }
      }
    }
  ]
}
```

### Include nested menu items

```http
GET /api/v1/restaurants/:id?include=menus.menu_items
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/restaurants/1?include=menus.menu_items" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

### Import restaurants from file

```http
POST /api/v1/restaurants/import
```

**cURL Example:**

```bash
curl -X POST "https://rominbites.romin.dev.br/api/v1/restaurants/import" \
  -H "Accept: application/json" \
  -F "file=@restaurants.json"
```

**Response:**

```json
{
  "success": true,
  "message": "Import queued for processing",
  "job_id": "12345-67890-abcdef",
  "status_url": "https://rominbites.romin.dev.br/api/v1/restaurants/import_status?job_id=12345-67890-abcdef"
}
```

### Check import status

```http
GET /api/v1/restaurants/import_status?job_id=:job_id
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/restaurants/import_status?job_id=12345-67890-abcdef" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Response (Processing):**

```json
{
  "success": false,
  "message": "Still processing",
  "job_id": "12345-67890-abcdef"
}
```

**Response (Completed - Success):**

```json
{
  "success": true,
  "message": "Import completed successfully",
  "logs": {
    "restaurants": {
      "success": [
        "Restaurant 'Bella Italia' created with ID: 1",
        "Restaurant 'Pizza Palace' found with ID: 2"
      ],
      "error": []
    },
    "menus": {
      "success": [
        "Menu 'Lunch Menu' created for restaurant Bella Italia with ID: 1",
        "Menu 'Dinner Menu' created for restaurant Bella Italia with ID: 2"
      ],
      "error": []
    },
    "menu_items": {
      "success": [
        "Menu item 'Margherita Pizza' created with price: 12.99 and ID: 1",
        "Menu item 'Caesar Salad' found with ID: 2"
      ],
      "error": []
    },
    "associations": {
      "success": [
        "Association created between 'Margherita Pizza' and 'Lunch Menu'",
        "Association created between 'Caesar Salad' and 'Lunch Menu'"
      ],
      "error": []
    }
  },
  "stats": {
    "restaurants_created": 1,
    "restaurants_found": 1,
    "menus_created": 2,
    "menus_found": 0,
    "menu_items_created": 1,
    "menu_items_found": 1,
    "associations_created": 2
  }
}
```

**Response (Completed - With Errors):**

```json
{
  "success": false,
  "message": "Import completed with errors",
  "logs": {
    "restaurants": {
      "success": [
        "Restaurant 'Bella Italia' created with ID: 1"
      ],
      "error": [
        "Error creating restaurant 'Invalid Restaurant': Name can't be blank"
      ]
    },
    "menus": {
      "success": [
        "Menu 'Lunch Menu' created for restaurant Bella Italia with ID: 1"
      ],
      "error": [
        "Error in menu 'Invalid Menu' for restaurant Bella Italia: Name can't be blank"
      ]
    },
    "menu_items": {
      "success": [
        "Menu item 'Margherita Pizza' created with price: 12.99 and ID: 1"
      ],
      "error": [
        "Error creating menu item 'Invalid Item': Price must be greater than or equal to 0"
      ]
    },
    "associations": {
      "success": [
        "Association created between 'Margherita Pizza' and 'Lunch Menu'"
      ],
      "error": []
    }
  },
  "stats": {
    "restaurants_created": 1,
    "restaurants_found": 0,
    "menus_created": 1,
    "menus_found": 0,
    "menu_items_created": 1,
    "menu_items_found": 0,
    "associations_created": 1
  }
}
```

**Response (Failed):**

```json
{
  "success": false,
  "message": "Import failed: Invalid JSON format",
  "errors": ["Invalid JSON format"],
  "logs": [],
  "stats": {}
}
```

---

## 🍽️ Menus

### List all menus

```http
GET /api/v1/menus
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/menus" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

### List menus for a specific restaurant

```http
GET /api/v1/restaurants/:restaurant_id/menus
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/restaurants/1/menus" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Response:**

```json
{
  "data": [
    {
      "id": "1",
      "type": "menu",
      "attributes": {
        "name": "Lunch Menu",
        "description": "Available from 12:00 to 15:00",
        "created_at": "2025-08-25T10:00:00.000Z",
        "updated_at": "2025-08-25T10:00:00.000Z"
      },
      "relationships": {
        "menu_items": {
          "data": []
        }
      }
    }
  ]
}
```

### Get a specific menu

```http
GET /api/v1/menus/:id
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/menus/1" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

### Include menu items with menu

```http
GET /api/v1/menus/:id?include=menu_items
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/menus/1?include=menu_items" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Response with includes:**

```json
{
  "data": {
    "id": "1",
    "type": "menu",
    "attributes": {
      "name": "Lunch Menu",
      "description": "Available from 12:00 to 15:00",
      "created_at": "2025-08-25T10:00:00.000Z",
      "updated_at": "2025-08-25T10:00:00.000Z"
    },
    "relationships": {
      "menu_items": {
        "data": [
          {
            "id": "1",
            "type": "menu_item"
          }
        ]
      }
    }
  },
  "included": [
    {
      "id": "1",
      "type": "menu_item",
      "attributes": {
        "name": "Margherita Pizza",
        "description": "Fresh tomatoes, mozzarella, basil",
        "price": "12.99",
        "created_at": "2025-08-25T10:00:00.000Z",
        "updated_at": "2025-08-25T10:00:00.000Z"
      },
      "relationships": {
        "menus": {
          "data": []
        }
      }
    }
  ]
}
```

---

## 🍕 Menu Items

### List all menu items

```http
GET /api/v1/menu_items
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/menu_items" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

### List menu items for a specific menu

```http
GET /api/v1/menus/:menu_id/menu_items
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/menus/1/menu_items" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Response:**

```json
{
  "data": [
    {
      "id": "1",
      "type": "menu_item",
      "attributes": {
        "name": "Margherita Pizza",
        "description": "Fresh tomatoes, mozzarella, basil",
        "price": "12.99",
        "created_at": "2025-08-25T10:00:00.000Z",
        "updated_at": "2025-08-25T10:00:00.000Z"
      },
      "relationships": {
        "menus": {
          "data": []
        }
      }
    }
  ]
}
```

### Get a specific menu item

```http
GET /api/v1/menu_items/:id
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/menu_items/1" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

### Include menus with menu item

```http
GET /api/v1/menu_items/:id?include=menus
```

**cURL Example:**

```bash
curl -X GET "https://rominbites.romin.dev.br/api/v1/menu_items/1?include=menus" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

**Response with includes:**

```json
{
  "data": {
    "id": "1",
    "type": "menu_item",
    "attributes": {
      "name": "Margherita Pizza",
      "description": "Fresh tomatoes, mozzarella, basil",
      "price": "12.99",
      "created_at": "2025-08-25T10:00:00.000Z",
      "updated_at": "2025-08-25T10:00:00.000Z"
    },
    "relationships": {
      "menus": {
        "data": [
          {
            "id": "1",
            "type": "menu"
          }
        ]
      }
    }
  },
  "included": [
    {
      "id": "1",
      "type": "menu",
      "attributes": {
        "name": "Lunch Menu",
        "description": "Available from 12:00 to 15:00",
        "created_at": "2025-08-25T10:00:00.000Z",
        "updated_at": "2025-08-25T10:00:00.000Z"
      },
      "relationships": {
        "menu_items": {
          "data": []
        }
      }
    }
  ]
}
```

---

## 📊 Response Format

All responses follow the JSON:API specification:

### Success Response Structure

```json
{
  "data": {
    "id": "1",
    "type": "resource_type",
    "attributes": {
      // resource attributes
    },
    "relationships": {
      // resource relationships
    }
  },
  "included": [
    // related resources when using include parameter
  ]
}
```

### Error Response Structure

```json
{
  "error": "Error message"
}
```

## 🔍 Query Parameters

### Include Related Resources

You can include related resources using the `include` parameter:

- `?include=menus` - Include menus (for restaurants)
- `?include=menu_items` - Include menu items (for menus)
- `?include=menus.menu_items` - Include nested relationships (menus with their menu items)

**Examples:**

```bash
# Get restaurant with its menus
curl "https://rominbites.romin.dev.br/api/v1/restaurants/1?include=menus"

# Get restaurant with menus and their items
curl "https://rominbites.romin.dev.br/api/v1/restaurants/1?include=menus.menu_items"

# Get menu with its items
curl "https://rominbites.romin.dev.br/api/v1/menus/1?include=menu_items"

# Get menu item with its menus
curl "https://rominbites.romin.dev.br/api/v1/menu_items/1?include=menus"
```

## 📝 Model Attributes

### Restaurant

- **id** (integer) - Unique identifier
- **name** (string, required) - Restaurant name
- **description** (text, optional) - Restaurant description
- **created_at** (datetime) - Creation timestamp
- **updated_at** (datetime) - Last update timestamp

### Menu

- **id** (integer) - Unique identifier
- **name** (string, required) - Menu name
- **description** (text, optional) - Menu description
- **restaurant_id** (integer, required) - Reference to restaurant
- **created_at** (datetime) - Creation timestamp
- **updated_at** (datetime) - Last update timestamp

### MenuItem

- **id** (integer) - Unique identifier
- **name** (string, required, unique) - Menu item name
- **description** (text, optional) - Item description
- **price** (decimal, required, >= 0) - Item price with 2 decimal places
- **created_at** (datetime) - Creation timestamp
- **updated_at** (datetime) - Last update timestamp

## 🔄 Relationships

- **Restaurant** has many **Menus** (one-to-many)
- **Menu** belongs to **Restaurant** (many-to-one)
- **Menu** has many **MenuItems** (many-to-many through join table)
- **MenuItem** has many **Menus** (many-to-many through join table)

## ⚡ HTTP Status Codes

- **200 OK** - Successful GET request
- **202 Accepted** - Import job queued or still processing
- **404 Not Found** - Resource not found
- **422 Unprocessable Content** - Missing required parameters
- **500 Internal Server Error** - Server error during import

## 🛠️ Development

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/requests/api/v1/restaurants_spec.rb

# Run with documentation format
bundle exec rspec --format documentation
```

### Code Quality

```bash
# Security analysis
bundle exec brakeman

# Code style
bundle exec rubocop

# N+1 query detection (in development)
# Bullet gem is configured to detect N+1 queries
```

## 📄 License

This project is open source and available under the MIT License.

---

**Note:** This API follows RESTful conventions and JSON:API specification. All timestamps are in ISO 8601 format (UTC).
