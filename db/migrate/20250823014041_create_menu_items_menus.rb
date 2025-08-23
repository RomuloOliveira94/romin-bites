class CreateMenuItemsMenus < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_items_menus do |t|
      t.references :menu_item, null: false, foreign_key: true
      t.references :menu, null: false, foreign_key: true

      t.timestamps
    end

    add_index :menu_items_menus, [ :menu_item_id, :menu_id ], unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO menu_items_menus (menu_item_id, menu_id, created_at, updated_at)
          SELECT id, menu_id, created_at, updated_at
          FROM menu_items
          WHERE menu_id IS NOT NULL
        SQL
      end
    end
  end
end
