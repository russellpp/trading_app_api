#seed for roles
admin_role = Role.find_or_create_by(name: 'admin')
trader_role = Role.find_or_create_by(name: 'trader')

#seed for admin user
admin_user = User.create(email: 'admin@coinswift.com', phone_number: '+639456421991' ) 

#update admin user password digest
password_hash = BCrypt::Password.create('password')
admin_user.update(password_digest: password_hash, verified: true, approved: true)

#userrole update
admin_user.save!
admin_user.user_roles.create(role: admin_role)
