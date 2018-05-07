class CreateAnimals < ActiveRecord::Migration[5.1]
  def change
    create_table :animals do |t|
      t.integer :participantId
      t.date :date
      t.string :room
      t.integer :reloc_seq
      t.string :objectId

      t.timestamps
    end
  end
end
