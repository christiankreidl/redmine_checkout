class AddCheckoutUrlInfo < ActiveRecord::Migration[4.2]
  def self.up
    add_column :repositories, :checkout_url_type, :string, :default => 'none', :null => false
    add_column :repositories, :checkout_url, :string, :default => '', :null => false
  end

  def self.down
    remove_column :repositories, :checkout_url_type
    remove_column :repositories, :checkout_url
  end
end
