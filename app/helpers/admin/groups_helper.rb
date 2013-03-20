module Admin::GroupsHelper
  def group_with_depth(group)
    ("-")*group.depth + " " + group.name
  end
end
