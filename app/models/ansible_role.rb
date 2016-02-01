class AnsibleRole < ActiveRecord::Base
  include Authorizable
  extend FriendlyId
  friendly_id :name

  attr_accessible :name, :host_id

  has_many :hosts, :through => :host_ansible_roles, :class_name => '::Host::Managed'
  has_many :host_ansible_roles, :foreign_key => :host_ansible_role_id
  has_many :hostgroups, :through => :hostgroup_ansible_roles
  has_many :hostgroup_ansible_roles, :foreign_key => :hostgroup_ansible_role_id

  validates :name, :uniqueness => true, :presence => true
end
