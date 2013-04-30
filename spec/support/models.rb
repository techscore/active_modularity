require 'active_record'
ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => ':memory:')

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table(:people      ) {|t| t.string :name; t.string :type}
    create_table(:resources   ) {|t| t.string :owner_type; t.integer :owner_id; t.text :content }
    create_table(:profiles    ) {|t| t.integer :person_id }
    create_table(:entries     ) {|t| t.integer :person_id; t.string :name }
    create_table(:tags        ) {|t| t.string :name }
    create_table(:entries_tags) {|t| t.integer :entry_id; t.integer :tag_id}
  end
end

ActiveRecord::Migration.verbose = false
CreateAllTables.up

ActiveRecord::Base.acts_as_modularity

class Person < ActiveRecord::Base
  has_one :profile
  has_many :entries
  has_many :resources, :as => :owner
end
class Customer < Person;end;
class Employee < Person;end;
class Profile < ActiveRecord::Base
  belongs_to :person
end
class Resource < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
end
class Entry < ActiveRecord::Base
  has_many :resources, :as => :owner
  has_many :entries_tags
  has_many :tags, :through => :entries_tags
end
class Tag < ActiveRecord::Base
  has_and_belongs_to_many :entries
end
class EntriesTag < ActiveRecord::Base
  belongs_to :entry
  belongs_to :tag
end

module Admin
  class Person     < ::Person   ; end;
  class Customer   < ::Customer ; end;
  class Employee   < ::Employee ; end;
  class Profile    < ::Profile  ; end;
  class Resource   < ::Resource ; end;
  class Entry      < ::Entry    ; end;
  class Tag        < ::Tag      ; end;
  class EntriesTag < ::EntriesTag ; end;
end
