require 'spec_helper'

describe User do
  let(:parent) {populate_groups_and_users}
  let(:child1) {parent.children.first}
  let(:child2) {parent.children.last}
  let(:child1_1) {child1.children.first}
  let(:child1_2) {child1.children.last}
  let(:user_1) {User.find_by_group_id(child1.id)}


  it 'creates a default Admin User if there are no admins' do

  end

  it 'gets all admins' do
    g = Group.root
    g.add_user('test@mail.com', true)
    User.get_admins.count.should == 1
  end

  it "gets only accessible groups" do
    user_1.accessible_groups.find_by_id(parent.id).should == nil
    user_1.accessible_groups.find_by_id(child1_1.id).should == child1_1
    user_1.accessible_groups.find_by_id(child1_2.id).should == child1_2
    user_1.accessible_groups.find_by_id(child2.id).should == nil
  end

  it "gets only accessible users" do
    accessible_users = user_1.accessible_users
    accessible_users.where(group_id: parent.id).to_a.count.should == 0
    accessible_users.where(group_id: child2.id).to_a.count.should == 0
    accessible_users.where(group_id: child1.id).to_a.count.should == 3
    accessible_users.where(group_id: child1_1.id).to_a.count.should == 1
    accessible_users.where(group_id: child1_2.id).to_a.count.should == 1
  end
end
