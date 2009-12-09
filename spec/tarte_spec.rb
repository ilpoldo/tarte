require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class HasOneStatus < ActiveRecord::Base
  attr_accessor :status_code
  [:status_code_changed?, :status_code_was].each { |m| define_method m, lambda {}}
  has_one_baked_in :status, :names => [:red, :yellow, :green], :groups => {:stop => [:red, :yellow]}
  
  validates_baked_in :status, :is => :stop
end

class HasManyIngredients < ActiveRecord::Base
  attr_accessor :ingredients_mask
  [:ingredients_mask_changed?, :ingredients_mask_was].each { |m| define_method m, lambda {}}
  has_many_baked_in :ingredients, :names => [:fish, :chips, :sauce, :pudding], :groups => {:"fish&chips" => [:fish, :chips]}
  
  validates_baked_in :ingredients, :matches => :"fish&chips"
end

describe Tarte, "accessors" do  
  it "should have accessors for an has_many_baked_in associations that hit an association_mask" do    
    entry = HasOneStatus.new
    
    entry.status = :green
    entry.status.should eql(:green)
    
    entry.should_receive(:status_code).and_return(0)
    entry.status.should eql(:red)
    
    entry.should_receive(:status_code=).with(2)
    entry.status = :green
  end
  
  it "should have accessors for an has_one_baked_in association that hit an association_code" do
    entry = HasManyIngredients.new
    
    entry.ingredients = [:fish, :pudding]
    entry.ingredients.should eql([:fish, :pudding])
    
    entry.should_receive(:ingredients_mask).any_number_of_times.and_return(5)
    entry.ingredients.should eql([:fish, :sauce])
    
    entry.should_receive(:ingredients_mask=).with(3)
    entry.ingredients = [:fish, :chips]
  end
end

describe Tarte, "query methods" do
  it "should have query methods for an has_many_baked_in associations that hit an association_mask" do
    entry = HasOneStatus.new
    
    entry.status = :green
    entry.green?.should be_true
    entry.red?.should be_false
  end
  
  it "should have query methods for an has_one_baked_in association that hit an association_code" do
    entry = HasManyIngredients.new
    
    entry.ingredients = [:fish, :chips]
    entry.has_fish?.should be_true
    entry.has_sauce?.should be_false
  end
end

describe Tarte, "dirty associations" do
  it "should track dirty has_many_baked_in with names" do
    entry = HasOneStatus.new
    
    entry.should_receive(:status_code_changed?).and_return(true)
    entry.should_receive(:status_code_was).and_return(1)
    
    entry.status_changed?
    entry.status_was.should eql(:yellow)
    
    entry.should_receive(:status_code_was).and_return(1)
    entry.status_was.should eql(:yellow)
  end
  
  it "should track dirty has_many_baked_in with names" do
    entry = HasOneStatus.new
    
    entry.should_receive(:status_code_changed?).and_return(true)
    entry.should_receive(:status_code).and_return(0)
    entry.status_changed_to_red?.should be_true
  end
  
  it "should track dirty has_one_baked_in" do
    entry = HasManyIngredients.new
    
    entry.should_receive(:ingredients_mask_changed?).and_return(true)
    entry.should_receive(:ingredients_mask_was).any_number_of_times.and_return(3) # [:fish, :chips]
    
    entry.ingredients_changed?
    entry.ingredients_were.should eql([:fish, :chips])
    
    # entry.had_fish?.should be_true
    # entry.has_sauce?.should be_false
  end
end

describe Tarte, "grouping and group querying" do
  it "should return an array of codes for a group of has_one values for an attribute" do
    HasOneStatus.status_codes_for(:stop).should eql([0,1])
  end
  
  it "should return mask for a group of has_many values for an attribute" do
    HasManyIngredients.ingredients_mask_for(:"fish&chips").should eql(3)
  end
end

describe Tarte, "finder methods/scopes" do
  it "should define scopes based on value gorups" do
    pending
  end
end

describe Tarte, "validations" do
  it "should allow to validate using value groups" do
    entry = HasOneStatus.new    
    entry.errors.should_receive(:add)
    entry.status = :green
    entry.save
  end
end