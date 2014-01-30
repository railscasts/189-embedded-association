class User < ActiveRecord::Base
  acts_as_authentic
  has_many :articles
  has_many :comments
  
  named_scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }
  
  ROLES = %w[admin moderator author]
  
# There are 3 possible values for role: admin, author, moderator

# In binary format this can be represented by 2^3 states or 8 possible combinations of roles

 
# ------------------------------------------
# admin moderator author - Integer value
# -------------------------------------------
# 0       0       0		        0
# 0       0	      1		        1
# 0	      1	      0		        2
# 0	      1	      1		        3
# 1	      0	      0		        4
# 1	      0	      1		        5
# 1	      1	      0		        6
# 1	      1	      1		        7	

# 2**ROLES converts into binary
# 2**ROLES.index(r) retrieves the corresponding integer equivalent of the binary state
# 2**ROLES.index(r).sum gives the sum of the indices, for example if @user.roles = ["admin","author"],  
# then 2**ROLES.index(r).sum = 4 + 1 = 5

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

# For example say @user.roles = ["admin","moderator", "author"]
# Therefore roles_mask will be [4 + 2 + 1 = 7]
# roles_mask || 0 ( OR operation with 0) = [111, 111, 111]
# ((roles_mask || 0) & 2**ROLES.index(r)) will be as follows:
# 1 1 1
# &
# 1 0 0
# -----
# 1 0 0 
# The same operation is performed with the rest of the indices that is (111 & 010), (111 & 001)
# check if the result is not zero, else reject!
  
  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end
  
  def role_symbols
    roles.map(&:to_sym)
  end
end
