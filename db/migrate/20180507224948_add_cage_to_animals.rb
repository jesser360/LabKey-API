class AddCageToAnimals < ActiveRecord::Migration[5.1]
  def change
    add_column :animals, :cage, :integer
  end
end
