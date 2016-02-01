class CreateAnsibleRoles < ActiveRecord::Migration
  def change
    create_table :ansible_roles do |t|
      t.string :name, :null => false
      t.timestamps
    end

    create_table :host_ansible_roles, :id => false do |t|
      t.column :host_id, :integer
      t.column :ansible_role_id, :integer
    end

    add_index :ansible_roles, :name, :unique => true
  end
end
