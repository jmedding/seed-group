require 'spec_helper'

feature 'Authorization' do

  given(:parent) {populate_groups_and_users}
  given(:child1) {parent.children.first}
  given(:admin) {create_admin_for_group(child1, "admin_1")}
  given(:user) {child1.users.first}
  
  scenario "Admin can visit admin group index" do
    login_user admin
    page.should have_content "Capex Group Admin Page"
  end

  scenario "Admin can visit admin user page" do
    login_user admin
    visit admin_users_path
    page.should have_content "Capex User Admin Page"
  end

  scenario "User cannot visit group index" do
    login_user user
    page.should_not have_content "Capex Group Admin Page"
  end

  scenario "User cannot visit admin user page" do
    login_user user
    visit admin_users_path
    page.should_not  have_content "Capex User Admin Page"
  end

end