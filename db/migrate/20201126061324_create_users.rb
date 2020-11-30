class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: false do |t|
      t.column :user_id, 'varchar PRIMARY KEY'
      t.string :name, limit: 30 ,null: false 
      t.string :job, null:true
      t.integer :age, null:false
      t.string :telno,limit: 15, null: true

      t.timestamps
    end
  end
end
