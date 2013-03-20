class Group < ActiveRecord::Base
  has_many :users

  acts_as_nested_set

  attr_accessible :name, :parent_id
  attr_reader :destroy_error

  scope :allowed_groups, lambda{ |parent| where(lft: parent.lft..parent.rgt)}
  
  def add_group(name)
    child = Group.new(name: name)
    if child.save
      child.move_to_child_of self
      Group.root.reload
      child
    else
      false
    end
  end

  def add_user(email, admin=nil)
    new_user = self.users.build attributes = {email: email}
    new_user.admin = admin 

    new_user.save!
  end

  def get_user_count
    self.users.count
  end

  def users_from_self_and_children_xxx
    all_users = self_and_descendants.map do |group|
      group.users
    end
    all_users.flatten
  end

  def users_by_allowed_groups
    users_by_group = Hash.new
    self_and_descendants.each do |group|
      users_by_group["#{group.id}"] = group.users.all
    end
    users_by_group
  end

  def get_allowed_parents(allowed_groups = nil)
    #Group.all gives an array, so query not chainable
    allowed_groups ||= Group.where("id >= 0")
    allowed_groups.where('lft < ? OR lft > ?', lft, rgt).to_a
  end

  private


end
