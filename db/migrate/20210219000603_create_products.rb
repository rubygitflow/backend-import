class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products, force: :cascade do |t|
      t.string "price_list", null: false
      t.string "brand", null: false
      t.string "code", null: false
      t.integer "stock", default: 0, null: false
      t.decimal "cost", precision: 12, scale: 2, null: false
      t.string "name"

      t.timestamps

      t.index [ :price_list, :brand, :code ], name: "index_list_brand_code_uniqueness", unique: true
    end
  end
end
