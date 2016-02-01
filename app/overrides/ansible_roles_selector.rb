if defined?(ForemanRemoteExecution)
  Deface::Override.new(:virtual_path => 'hosts/_form',
                       :name => 'add_ansible_roles_tab_to_host',
                       :insert_after => 'li.active',
                       :partial => 'foreman_ansible/ansible_roles/host_tab')

  Deface::Override.new(:virtual_path => 'hosts/_form',
                       :name => 'add_ansible_roles_tab_pane_to_host',
                       :insert_before => "erb[loud]:contains('puppetclasses_tab')",
                       :partial => 'foreman_ansible/ansible_roles/host_tab_pane')

  Deface::Override.new(:virtual_path => 'hostgroups/_form',
                       :name => 'add_ansible_roles_tab_to_hg',
                       :insert_after => 'li.active',
                       :partial => 'foreman_ansible/ansible_roles/host_tab')

  Deface::Override.new(:virtual_path => 'hostgroups/_form',
                       :name => 'add_ansible_roles_tab_pane_to_hg',
                       :insert_before => "erb[loud]:contains('puppetclasses_tab')",
                       :partial => 'foreman_ansible/ansible_roles/host_tab_pane')
end
