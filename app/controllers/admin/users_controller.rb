class Admin::UsersController < AdminController

  def index
    #get users by group for the allowed groups
    @users_by_group = current_user.group.users_by_allowed_groups
  end


  def new
    begin
      #TODO: add allowed groups by loggedin admin!!
      @group = Group.find(params[:group_id])
      @user = @group.users.build
    rescue ActiveRecord::RecordNotFound => e
      p "whoops: " + e.message
      flash[:error] = "Sorry, but no matching group was found"
      redirect_to admin_path
    end
  end

  def create
    #TODO: add allowed groups by loggedin admin!!
    @user = User.new(params[:user])
    if @user.save
      redirect_to admin_path, notice: "A confirmation was sent to #{@user.email}."
    else
      flash[:error] = "This user could not be created"
      render :edit
    end
  end

  def destroy
    victem = current_user.accessible_users.find_by_id!(params[:id])
    if victem.destroy
      redirect_to admin_path, notice: "The account for '#{victem.email}' was permanently deleted"
    else
      flash[:error] = "The account for '#{victem.email}' could not be deleted"
      redirect_to admin_path
    end
  end

  def edit
    @user = current_user.accessible_users.find_by_id(params[:id])
    @allowed_groups = current_user.accessible_groups.to_a
    redirect_to  admin_users_path, notice: "The requested user does not exist or is not accessible." unless @user

  end

  def update
    p params
    admin = params[:user][:admin] == "1"
    @user = current_user.accessible_users.find_by_id!(params[:id])
    @allowed_groups = current_user.accessible_groups.to_a
    if @user.blank?
      redirect_to admin_users_path, notice: "The requested user does not exist or is not accessible."
    else
      unless @user.update_attributes(params[:user].reject!{|k| k== "admin"})
        flash[:error] = "The user could not be updated - sorry"
      end
      p admin
      @user.admin = admin
      @user.save!
      redirect_to admin_users_path
    end
  end

  private

end