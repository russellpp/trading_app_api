# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_05_07_145117) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cryptos", force: :cascade do |t|
    t.string "name"
    t.string "ticker"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gecko_id"
  end

  create_table "cryptos_watchlists", id: false, force: :cascade do |t|
    t.bigint "watchlist_id", null: false
    t.bigint "crypto_id", null: false
    t.index ["crypto_id", "watchlist_id"], name: "index_cryptos_watchlists_on_crypto_id_and_watchlist_id"
    t.index ["watchlist_id", "crypto_id"], name: "index_cryptos_watchlists_on_watchlist_id_and_crypto_id"
  end

  create_table "funds_transfers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "transaction_type"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_funds_transfers_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "crypto_id", null: false
    t.decimal "total_value"
    t.decimal "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "transaction_type"
    t.index ["crypto_id"], name: "index_transactions_on_crypto_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "user_cryptos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "crypto_id", null: false
    t.decimal "quantity", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "on_watchlist", default: false
    t.index ["crypto_id"], name: "index_user_cryptos_on_crypto_id"
    t.index ["user_id"], name: "index_user_cryptos_on_user_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.boolean "verified"
    t.boolean "approved"
    t.decimal "balance"
  end

  create_table "watchlists", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_watchlists_on_user_id"
  end

  add_foreign_key "funds_transfers", "users"
  add_foreign_key "transactions", "cryptos"
  add_foreign_key "transactions", "users"
  add_foreign_key "user_cryptos", "cryptos"
  add_foreign_key "user_cryptos", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users", on_delete: :cascade
  add_foreign_key "watchlists", "users"
end
