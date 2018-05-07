class AddEndDateToAnimals < ActiveRecord::Migration[5.1]
  def change
    add_column :animals, :enddate, :date
  end
end
