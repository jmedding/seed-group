require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/rspec'
  require 'capybara/rails'
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  
  def create_parent_and_some_descendant_groups
    parent = Group.root
    child1 = Group.create!(name: "child1").move_to_child_of(parent)
    child2 = Group.create!(name: "child2").move_to_child_of(parent)
    child1_1 = Group.create!(name: "child 1.1").move_to_child_of(child1)
    child1_2 = Group.create!(name: "child 1.2").move_to_child_of(child1)
    parent
  end

  def create_new_user(email, group)
    click_link "new_user_group_#{group.id}_link"
    within("#new_user") do
      fill_in "Email", with: email
      click_button "Create User"
    end
    #return user id???
  end

  def populate_groups_and_users(parent = nil)
    parent ||= create_parent_and_some_descendant_groups
    names = %w( _a 1_a 1_b 1_c 1.1_a 1.2_b)
    names.each do |name|
      parts = name.split("_")
      gparts = parts[0].split(".")
      group = gparts.inject(parent) {|g,i| g =  g.children[i.to_i - 1]}
      user = group.users.build(email: name + "@test.com", password: "password", password_confirmation: "password")
      user.save
      user.confirm!
    end
    parent
  end

  def create_admin_for_group(group, name)
    group.add_user(name+"@mail.com", true)
    user = group.users.last
    user.update_attributes( password: "password", password_confirmation: "password")
    user.save
    user.confirm!
    user
  end

  def login_user(user)
    visit new_user_session_path
    within "#new_user" do
      fill_in "Email", with: user.email
      fill_in "Password", with: "password"
      click_button "Sign in"
    end
  end

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.use_transactional_fixtures = false
    config.include(MailerMacros)
  
    config.before(:each) do
      DatabaseCleaner.start
      Group.create!(name: "OPS")
      reset_email
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
    
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
    end
    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #  config.fixture_path = "#{::Rails.root}/spec/fixtures"

    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  

end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.




# This file is copied to spec/ when you run 'rails generate rspec:install'
