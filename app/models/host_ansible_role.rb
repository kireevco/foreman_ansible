class HostAnsibleRole < ActiveRecord::Base
  belongs_to :host, :class_name => 'Host::Managed', :foreign_key => :host_id
  belongs_to :ansible_role
end
