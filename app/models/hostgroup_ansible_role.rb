class HostgroupAnsibleRole < ActiveRecord::Base
  belongs_to :hostgroup
  belongs_to :ansible_role
end
