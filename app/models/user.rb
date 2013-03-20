class User < ActiveRecord::Base
  belongs_to :group
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
          :recoverable, :rememberable #, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :group_id

  validates :group_id, :presence => true

  def self.accessible_users_for(group) 
    allowed_group_ids = Group.allowed_groups(group).map { |group| group.id}
    User.where(group_id: allowed_group_ids)
  end

  def accessible_users
    User.accessible_users_for group
  end
  
  def password_required?
    super if confirmed?
  end

  def password_match?
    self.errors[:password] = "Password can't be blank" if password.blank?
    self.errors[:password_confirmation] = "Password confirmation can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] = "password_confirmation does not match the password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  def accessible_groups
    #returns a query object containing the user's group and it's children
    Group.allowed_groups(group)
  end
  
  def self.get_admins
    User.where(admin: true)
  end
end
