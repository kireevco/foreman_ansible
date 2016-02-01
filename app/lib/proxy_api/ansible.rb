module ::ProxyAPI
  class Ansible < ::ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + '/ansible/'
      super args
    end

    def available_roles
      role_list = parse(get('roles'))
      results = []
      role_list.each do |role|
        results << ::AnsibleRole.where(:name => role).first_or_create
      end
      # We have to return an ActiveRecord Relation in order to use this data in
      # a form
      ::AnsibleRole.where(:name => results.map(&:name))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to find Ansible roles'))
    end

    def variables(role_name)
      parse(get("roles/#{role_name}/variables"))
    end
  end
end
