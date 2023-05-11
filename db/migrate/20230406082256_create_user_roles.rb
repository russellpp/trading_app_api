class CreateUserRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :role, null: false, foreign_key: true

      t.timestamps
    end
  end
end
