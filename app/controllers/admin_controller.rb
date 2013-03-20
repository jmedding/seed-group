class AdminController < ApplicationController
  before_filter :admins_only

  def index
    @roots = Group.roots
  end

  private

  def admins_only
    permission_denied unless current_user.admin
  end
end
