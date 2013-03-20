# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#All groups must decend from this node
ops = Group.create!(name: "OPS")

admin = User.create(  group_id: ops.id,
                      email: "admin@mail.com",
                      password: "password",
                      password_confirmation: "password"
                   )
admin.admin = true
admin.save!
