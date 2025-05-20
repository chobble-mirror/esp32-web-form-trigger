class AddIntroImageHoverOutlineColorToForms < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :intro_image_hover_outline_color, :string
  end
end
