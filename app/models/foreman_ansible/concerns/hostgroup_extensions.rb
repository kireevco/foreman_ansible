module ForemanAnsible
  module Concerns
    module HostgroupExtensions
      extend ActiveSupport::Concern

      included do
        has_many :ansible_roles, :through => :hostgroup_ansible_roles, :class_name => 'AnsibleRole'
        has_many :hostgroup_ansible_roles, :foreign_key => :hostgroup_id, :class_name => 'HostgroupAnsibleRole'

        attr_accessible :ansible_role_ids, :ansible_role_names
      end
    end
  end
end
