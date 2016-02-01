require 'deface'
module ForemanAnsible
  # This engine connects ForemanAnsible with Foreman core
  class Engine < ::Rails::Engine
    engine_name 'foreman_ansible'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers"]
    config.autoload_paths += Dir["#{config.root}/app/lib"]
    config.autoload_paths += Dir["#{config.root}/app/models/"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]
    config.autoload_paths += Dir["#{config.root}/app/services"]
    config.autoload_paths += Dir["#{config.root}/app/views"]

    initializer "foreman_ansible.assets.precompile" do |app|
      app.config.assets.precompile += %w(foreman_ansible/select_host_roles.js)
    end

    initializer 'foreman_ansible.configure_assets', :group => :assets do
      SETTINGS[:foreman_ansible] =
        { :assets => { :precompile => ['foreman_ansible/select_host_roles.js'] } }
    end

    initializer 'foreman_ansible.register_plugin', :before => :finisher_hook do
      Foreman::Plugin.register :foreman_ansible do
        requires_foreman '>= 1.11'
        security_block :ansible_roles do
          permission :view_ansible_roles, {}, :resource_type => 'AnsibleRole'
        end
      end

    end

    initializer 'foreman_ansible.load_app_instance_data' do |app|
      ForemanAnsible::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    config.to_prepare do
      begin
        ::Host::Managed.send(:include, ForemanAnsible::Concerns::HostExtensions)
        ::Hostgroup.send(:include,
                         ForemanAnsible::Concerns::HostgroupExtensions)
        ::FactImporter.register_fact_importer(:ansible,
                                              ForemanAnsible::FactImporter)
        ::FactParser.register_fact_parser(:ansible, ForemanAnsible::FactParser)
      rescue => e
        Rails.logger "Foreman Ansible: skipping engine hook (#{e})"
      end
    end
  end
end
