require 'spec_helper'

feature 'The admin can' do
  
  given(:parent) {populate_groups_and_users}
  given(:child1) {parent.children.first}
  given(:admin) {create_admin_for_group(child1, "admin_1")}
  
  background do
    login_user admin
  end
  
  scenario ' add a user to a group' do
    email = 'new_user@user_test.com'
    group = child1
    num_users = child1.users.count
    create_new_user(email, child1)
    find("#group_#{group.id}_users").text.should == (num_users + 1).to_s
    last_email.to.should include email
  end

  scenario ' view users by group, but only their groups' do
    click_link "Users"
    page.should have_content admin.group.name
    page.should_not have_content admin.group.parent.name
  end

  scenario " delete a user" do
    click_link "Users"
    user = admin.group.users.first
    find("table#group_table").should have_content user.email
    click_link "delete_user_#{user.id}_button"
    find("table#group_table").should_not have_content user.email
  end

  scenario "can edit a user" do
    user = admin.group.users.first
    allowed_groups = admin.group.self_and_descendants.map{|g| g.name}
    click_link "Users"
    click_link "edit_user_#{user.id}_link"
    page.has_select?("user_group_id", options: allowed_groups).should == true
    page.has_select?("user_group_id", with_options: [Group.root.name]).should == false
    #can assign a user to a new group if admin permissions are ok
    new_group = admin.group.leaves.first
    select(new_group.name, from: "user_group_id")
    click_button "Update User"
    updated_user = admin.accessible_users.find(user.id)
    updated_user.group.should == new_group
    #can delete a user
    click_link "delete_user_#{user.id}_button"
    within_table("group_table") do
      page.should_not have_content(user.email)
    end
    User.where(id: user.id).count.should == 0    
  end

  scenario "indicates if the user has not yet confirmed their account" do
    #find td with email address, it should also include icon-warning-sign
    icon_xpath = "i[@class='icon-envelope']"
    email = 'new_user@user_test.com'
    group = child1
    num_users = child1.users.count
    create_new_user(email, child1)
    visit admin_users_path
    new_user_field = find(:xpath, "//td", text: /#{Regexp.quote(email)}/)
    new_user_field.should have_xpath(icon_xpath)
    admin_user_field = find(:xpath, "//td", text:/#{Regexp.quote(admin.email)}/)
    admin_user_field.should_not have_xpath(icon_xpath)
    group.users.last.confirm!
    visit admin_users_path
    new_user_field = find(:xpath, "//td", text: /#{Regexp.quote(email)}/)
    new_user_field.should_not have_xpath(icon_xpath)    
  end
end