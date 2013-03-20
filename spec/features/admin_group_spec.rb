require 'spec_helper'

feature "Group features for admins:" do
  given(:parent) {populate_groups_and_users}
  given(:child1) {parent.children.first}
  given(:child1_1) {child1.children.first}
  given(:admin) {create_admin_for_group(child1, "admin_1")}

  background do
    login_user admin
  end

  scenario " create a default admin user if none exist" do
    page.should have_content 'Capex Group Admin Page'
    page.should have_table 'group_table'
    rows = page.all('table#group_table tr')
    rows.count.should == 6
    rows[1].should have_content "OPS"
    rows[2].should have_content "- #{child1.name}"
    rows[2].should have_content "#{child1.users.count}"
    rows[3].should have_content "-- #{child1_1.name}"
    rows[3].should_not have_content "--- #{child1_1.name}"
  end

  scenario " create a new sub-group" do
    click_link "add_group_#{child1.id}_link"
    form_id = "#new_group"
    page.should have_css form_id
    within form_id do
        find_field("Parent Group").value.should == child1.id.to_s
        fill_in "Name", with: "child1.3"
        click_button "Create Group"        
    end  
    page.should have_content "-- child1.3"
  end

  scenario " edit an existing group" do
    click_link("edit_group_#{child1.id}_link")
    page.should have_content child1.name
    page.should_not have_content 'Capex Group Admin Page'
    
    form_id = "#edit_group_#{child1.id}"
    page.should have_css form_id
    within form_id do
        fill_in "Name", with: "Child2.2"
        select "child2", from: "Parent"
        click_button "Update Group"
    end
    page.should have_content "-- Child2.2"
    #Group.all.each{|g| p g}
  end

  scenario " a group and its sub-groups can be deleted" do
    child1_1_1 = child1_1.add_group("Child1.1.1")
    child1_1_1.add_user("1.1.1_a@mail.com")
    click_link "delete_group_#{child1_1.id}_button"
    find("table#group_table").should have_content child1_1.name
    #check flash message
    page.should have_content "Please delete or move"    
    visit admin_path
    User.delete User.accessible_users_for(child1_1).to_a
    click_link "delete_group_#{child1_1.id}_button"
    #check flash notice
    page.should have_content "have been deleted"
    within "table#group_table" do
      page.should_not have_content child1_1.name
      page.should_not have_content child1_1_1.name
    end
      
  end
end