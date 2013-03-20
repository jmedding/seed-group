class Admin::GroupsController < AdminController

  def edit
    @group = current_user.accessible_groups.find_by_id!(params[:id])
    @allowed_parents = @group.get_allowed_parents
    redirect_to admin_path if @group.blank?
  end

  def new
    begin
      parent = current_user.accessible_groups.find_by_id!(params[:parent_id])
      @group = Group.new parent_id: parent.id
      @allowed_parents = current_user.accessible_groups.to_a
      render "new"
    rescue ActiveRecord::RecordNotFound => e
      p "whoops: " + e.message
      flash[:error] = "The requested group could not be found"
      redirect_to admin_path
    end
  end

  def create
    begin
      parent = current_user.accessible_groups.find_by_id!(params[:group][:parent_id])
      @group = parent.add_group params[:group][:name]
      if @group
        message = "Group '#{@group.name}' was created as a sub-group of '#{parent.name}'."
        redirect_to admin_path, notice: message
      else
        @allowed_parents = current_user.accessible_groups.to_a
        @group = Group.new parent_id: parent.id
        flash[:error] = "Sorry, the group could not be created"
        render :new
      end
    rescue ActiveRecord::RecordNotFound => e
      p "That's weird: " + e.message
      flash[:error] = "The requested group could not be found. Please select the 'parent' group."
      @group = Group.new name: params[:group][:name]
      @allowed_parents = get_authorized_parents
      render :edit
    end
  end

  def update
    @group = current_user.accessible_groups.find_by_id!(params[:id])
    if @group.update_attributes(params[:group])
      redirect_to admin_path
    else
      render :action => :edit
    end
  end

  def destroy
    #only delete groups that have no users, including subgroups
    begin
      group = current_user.accessible_groups.find_by_id!(params[:id])
      if User.accessible_users_for(group).to_a.empty?
        if group.destroy
          flash[:notice] = "Group '#{group.name}' and all sub-groups have been deleted."
          redirect_to admin_path
        else
          flash[:error] = "Group '#{group.name}' could not be deleted."
          redirect_to admin_path
        end
      else
        flash[:notice] = "The group '#{group.name}' or its sub-groups contain active users. Please delete or move the User to a group outside of the selected group."
        redirect_to admin_path
      end
    rescue ActiveRecord::RecordNotFound => e
      p "Destroy action Error: " + e.message
      flash[:error] = "The requested group was not found"
      redirect_to admin_path
    end

  end

  private

  def get_authorized_parents(group)
    group.get_allowed_parents(current_user.accessible_groups)
  end

end
