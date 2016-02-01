module ForemanAnsible
  module AnsibleHostTabHelper
    def ansible_proxy
      # TODO - make this smarter and find the host subnet or something
      SmartProxy.with_features('Ansible').first
    end

    def ansible_roles
      ProxyAPI::Ansible.new(:url => ansible_proxy.url).available_roles
    end
  end
end

