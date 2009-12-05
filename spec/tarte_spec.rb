require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

FakeModelParent.send(:include, Tarte)

class ModelWithOne < ActiveRecord::Base
  one_code = 1
  has_one_baked_in(:one, :names => [:uno, :dos, :tres])
end

class ModelWithMany < ActiveRecord::Base
  many_code = 3
  has_many_baked_in(:many, :names => [:fish, :chips, :sauce])
end

describe Tarte, "accessors" do
  before(:each) do
    
    # mock_model
  end
  
  it "should have accessors for an has_many_baked_in associations that hit an association_mask" do
    pending
  end
  
  it "should have accessors for an has_one_baked_in association that hit an association_code" do
    pending
  end
end

describe Tarte, "query methods" do
  it "should have query methods for an has_many_baked_in associations that hit an association_mask" do
    pending
  end
  
  it "should have query methods for an has_one_baked_in association that hit an association_code" do
    pending
  end
end

describe Tarte, "dirty associations" do
  it "should track dirty has_many_baked_in with names" do
    pending
  end
  
  it "should track dirty has_one_baked_in with names" do
    pending
  end
end

describe Tarte, "finder methods/scopes" do
  it "should define scopes based on value gorups" do
    pending
  end
end

describe Tarte, "validations" do
  it "should allow to validate using value groups" do
    pending
  end
end