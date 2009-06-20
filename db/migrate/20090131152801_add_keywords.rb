class AddKeywords < ActiveRecord::Migration
  def self.up     
    create_table :gallery_keywords, :unique => true, :force => true do |t|
      t.column :keyword, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end                 
    
    create_table :galleries_keywords, :id => false, :unique => true, :force => true do |t|
      t.column :gallery_id, :integer
      t.column :keyword_id, :integer
    end
                                
    create_table :gallery_items_keywords, :id => false, :unique => true, :force => true do |t|
      t.column :gallery_item_id, :integer
      t.column :keyword_id, :integer
    end
    
  end
  
  def self.down                         
    drop_table :table_name
    drop_table :gallery_items_keywords
    drop_table :galleries_keywords
    drop_table :gallery_keywords
  end
end   
       