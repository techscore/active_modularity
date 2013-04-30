require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiveModularity do
  context 'Has One Association' do
    before(:each) do
      @person        = Person.create!
      @profile       = @person.create_profile!
      @admin_person  = Admin::Person.create!
      @admin_profile = @admin_person.create_profile!
    end
    
    it { expect(@profile       ).to be_an_instance_of(Profile  ) }
    it { expect(@admin_profile ).to be_an_instance_of(Admin::Profile  ) }
    it { expect(Person.first.profile ).to be_an_instance_of(Profile  ) }
    it { expect(Admin::Person.first.profile ).to be_an_instance_of(Admin::Profile  ) }
  end
  
  context 'Belongs To Association' do
    before(:each) do
      @person  = Person.create!
      @profile = @person.create_profile!
    end
    
    it { expect(Profile.find(@profile).person ).to be_an_instance_of(Person  ) }
    it { expect(Admin::Profile.find(@profile).person ).to be_an_instance_of(Admin::Person  ) }
  end
  
  context 'Has Many Association' do
    before(:each) do
      @customer       = Customer.create!
      @admin_customer = Admin::Customer.create!
      @entry          = @customer.entries.create!
      @admin_entry    = @admin_customer.entries.create!
    end
    
    it { expect(@entry       ).to be_an_instance_of(Entry  ) }
    it { expect(@admin_entry ).to be_an_instance_of(Admin::Entry  ) }
  end
  
  context 'Has Many Through Association' do
    before(:each) do
      @entry       = Entry.create!
      @admin_entry = Admin::Entry.create!
      @tag         = @entry.tags.create!
      @admin_tag   = @admin_entry.tags.create!
    end
    
    it { expect(@tag       ).to be_an_instance_of(Tag  ) }
    it { expect(@admin_tag ).to be_an_instance_of(Admin::Tag  ) }
  end
  
  context 'Has And Belongs To Many Association' do
    before(:each) do
      @tag         = Tag.create!
      @admin_tag   = Admin::Tag.create!
      @entry       = @tag.entries.create!
      @admin_entry = @admin_tag.entries.create!
    end
    
    it { expect(@entry       ).to be_an_instance_of(Entry  ) }
    it { expect(@admin_entry ).to be_an_instance_of(Admin::Entry  ) }
  end
  
  context 'Polymorphic Association' do
    before(:each) do
      @person   = Person.create!
      @entry    = Entry.create!
      @person_resource = @person.resources.create!
      @entry_resource  = @entry.resources.create!
      @admin_person   = Admin::Person.create!
      @admin_entry    = Admin::Entry.create!
      @admin_person_resource = @admin_person.resources.create!
      @admin_entry_resource  = @admin_entry.resources.create!
    end
    
    it { expect(@person_resource).to be_an_instance_of(Resource  ) }
    it { expect(@entry_resource ).to be_an_instance_of(Resource  ) }
    it { expect(Person.find(@admin_person.id).resources.first.id).to eq(@admin_person_resource.id) }
    it { expect(Entry.find(@admin_entry.id).resources.first.id  ).to eq(@admin_entry_resource.id ) }
    
    it { expect(@admin_person_resource).to be_an_instance_of(Admin::Resource  ) }
    it { expect(@admin_entry_resource ).to be_an_instance_of(Admin::Resource  ) }
    it { expect(Admin::Person.find(@person.id).resources.first.id).to eq(@person_resource.id) }
    it { expect(Admin::Entry.find(@entry.id).resources.first.id  ).to eq(@entry_resource.id ) }
  end
  
  context 'Single table inheritance' do
    before(:each) do
      @person   = Person.create!
      @customer = Customer.create!
      @employee = Employee.create!
      @admin_person   = Admin::Person.create!
      @admin_customer = Admin::Customer.create!
      @admin_employee = Admin::Employee.create!
    end

    it { expect(Person.all.map(&:class)).to be_all{|klass| [Person, Customer, Employee].include?(klass) } }
    
    it { expect(@person  ).to be_an_instance_of(Person  ) }
    it { expect(@customer).to be_an_instance_of(Customer) }
    it { expect(@employee).to be_an_instance_of(Employee) }
    
    it { expect(Person.find(@admin_person.id  )).to be_an_instance_of(Person  ) }
    it { expect(Person.find(@admin_customer.id)).to be_an_instance_of(Customer) }
    it { expect(Person.find(@admin_employee.id)).to be_an_instance_of(Employee) }
    
    it { expect{Customer.find(@admin_person.id  )}.to raise_error  }
    it { expect(Customer.find(@admin_customer.id)).to be_an_instance_of(Customer) }
    it { expect{Customer.find(@admin_employee.id)}.to raise_error  }
    
    it { expect{Employee.find(@admin_person.id  )}.to raise_error  }
    it { expect{Employee.find(@admin_customer.id)}.to raise_error  }
    it { expect(Employee.find(@admin_employee.id)).to be_an_instance_of(Employee) }
    
    it { expect(Admin::Person.all.map(&:class)).to be_all{|klass| [Admin::Person, Admin::Customer, Admin::Employee].include?(klass) } }
    
    it { expect(@admin_person  ).to be_an_instance_of(Admin::Person  ) }
    it { expect(@admin_customer).to be_an_instance_of(Admin::Customer) }
    it { expect(@admin_employee).to be_an_instance_of(Admin::Employee) }
    
    it { expect(Admin::Person.find(@person.id  )).to be_an_instance_of(Admin::Person  ) }
    it { expect(Admin::Person.find(@customer.id)).to be_an_instance_of(Admin::Customer) }
    it { expect(Admin::Person.find(@employee.id)).to be_an_instance_of(Admin::Employee) }
    
    it { expect{Admin::Customer.find(@person.id  )}.to raise_error  }
    it { expect(Admin::Customer.find(@customer.id)).to be_an_instance_of(Admin::Customer) }
    it { expect{Admin::Customer.find(@employee.id)}.to raise_error  }
    
    it { expect{Admin::Employee.find(@person.id  )}.to raise_error  }
    it { expect{Admin::Employee.find(@customer.id)}.to raise_error  }
    it { expect(Admin::Employee.find(@employee.id)).to be_an_instance_of(Admin::Employee) }
  end
end