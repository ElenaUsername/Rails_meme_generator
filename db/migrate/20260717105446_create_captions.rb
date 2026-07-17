class CreateCaptions < ActiveRecord::Migration[8.1]
  def change
    create_table :captions do |t|
      t.string :url
      t.string :text
      t.string :caption_url
      t.string :kind
      t.string :type_field
      t.string :color
      t.string :start_color
      t.string :end_color
      t.string :filter
      t.string :unique_name

      t.timestamps
    end
  end
end
