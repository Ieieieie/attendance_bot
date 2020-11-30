class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances do |t|
      t.string :user_id
      t.date :work_date, null: true
      t.time :begin_time, null:false
      t.time :finish_time

    end
    add_foreign_key :attendances, :user_id
    add_index :attendances, :user_id
  end
end
