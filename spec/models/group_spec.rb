require 'spec_helper'

describe Group do
  
  let(:parent) {create_parent_and_some_descendant_groups}
  let(:child1) {parent.children.first}
  let(:child1_1) {child1.children.first}
  let(:child1_2) {child1.children.last}

  before do

  end

  it 'should already have a root node named OPS' do
    parent.name.should == "OPS"
  end

  it "should only add a group if a valid parent is assigned" do
    num_groups = parent.children.count
    group_name = "New Group"
    parent.add_group(group_name)
    parent.children.count.should == num_groups + 1
  end

  it "can add a user" do
    parent.add_user("test_user@mail.com")
    parent.users.count.should == 1
  end

  it "will return the number of users" do
    parent.add_user("test_user@mail.com")
    parent.get_user_count.should == 1
    child1.add_user "user1@mail.com"
    child1.add_user "user2@mail.com"
    child1.get_user_count.should == 2
    child1_1.add_user "user1_1@mail.com"
    child1_1.add_user "user1_2@mail.com"
    child1_1.get_user_count.should == 2
    User.accessible_users_for(parent).to_a.count.should == 5
    User.accessible_users_for(child1).to_a.count.should == 4
  end

  it "will return a list of allowed parents" do
    potential_parents = child1.get_allowed_parents
    potential_parents.should include parent
    potential_parents.should include parent.children.last
    potential_parents.should_not include child1
    potential_parents.should_not include child1.children.first
  end

  it "deletes a group with all children" do
    child1.destroy
    Group.count.should == 2
  end

  it "groups users by self and sub-groups" do
    populate_groups_and_users(parent)
    users_by_group = parent.users_by_allowed_groups
    users_by_group["#{parent.id}"].count.should == 1
    users_by_group["#{child1.id}"].count.should == 3
    users_by_group["#{child1_1.id}"].count.should == 1
    users_by_group["#{child1_2.id}"].count.should == 1
  end

  it "returns a query object with itself and children" do
    allowed_groups = Group.allowed_groups(child1)
    allowed_groups.find_by_id(parent.id).should == nil
    allowed_groups.find_by_id(child1.id).should == child1
    allowed_groups.find_by_id(child1_1.id).should == child1_1
    allowed_groups.find_by_id(child1_2.id).should == child1_2
  end
  
end
