class AddHostgroupAnsibleRoles < ActiveRecord::Migration
  def change
    create_table :hostgroup_ansible_roles do |t|
      t.column :hostgroup_id, :integer
      t.column :ansible_role_id, :integer
    end

    add_column :host_ansible_roles, :id, :primary_key
  end
end
