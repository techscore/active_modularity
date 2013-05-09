# ActiveModularity

ActiveRecord model inheritance support by module.
Fix inner module association and single table inheritance.

## Installation

Add this line to your application's Gemfile:

    gem 'active_modularity'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_modularity

## Examples ##

    # config/initializers/acts_as_modurarity.rb
    
    # enable active modurality
    ActiveRecord::Base.acts_as_modurality
    
    # load all files (Must be loaded the models and controllers.)
    YourApp::Application.eager_load! unless Rails.configuration.cache_classes
    
    #
    # has many association
    # 
    
    # app/models/user.rb
    class Person < ActiveRecord::Base
      has_many :entries
    end
    
    # app/models/entry.rb
    class Entry < ActiveRecord::Base
      belongs_to :person
    end
    
    # app/models/admin/user.rb
    module Admin
      class Person < ::Person
      end
    end
    
    # app/models/admin/user.rb
    module Admin
      class Entry < ::Entry
      end
    end
    
    # standard association
    person = Person.create
    person.entries.build.class.name # Entry
    
    # inner module association
    admin_person = Admin::Person.create
    admin_person.entries.build.class.name # Admin::Entry
    
    
    #
    # single table inheritance
    #
    
    # app/models/person.rb
    class Person < ActiveRecord::Base
    end
    
    # app/models/customer.rb
    class Customer < Person
    end
    
    # app/models/employee.rb
    class Employee < Person
    end

    # app/models/admin/person.rb
    module Admin
      class Person < ::Person
        module Common
          extend ActiveSupport::Concern
          included do
            # Admin::Person common class macro
            validates :name, :presence => true
          end
          
          def common_method
            # do something...
          end
        end
      end
    end
    
    # app/models/admin/customer.rb
    module Admin
      class Customer < ::Customer
        include Admin::Person::Common
      end
    end
    
    # app/models/admin/employee.rb
    module Admin
      class Employee < ::Employee
        include Admin::Person::Common
      end
    end
    
    
    # create
    alice = Customer.create(:name => "alice")
    alice.class.name # Customer
    alice.type       # Customer
    
    bob = Admin::Customer.create(:name => "bob")
    bob.class.name   # Admin::Customer
    bob.type         # Customer (not Admin::Customer)
    
    # find 
    Person.find(alice.id).class.name        # Customer
    Person.find(bob.id  ).class.name        # Customer
    Admin::Person.find(alice.id).class.name # Admin::Customer
    Admin::Person.find(bob.id  ).class.name # Admin::Customer


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
