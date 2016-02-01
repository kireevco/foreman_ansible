require 'timeout'
module ForemanAnsible
  module Concerns
    module HostExtensions
      extend ActiveSupport::Concern

      included do
        has_many :ansible_roles, :through => :host_ansible_roles, :class_name => 'AnsibleRole'
        has_many :host_ansible_roles, :foreign_key => :host_id, :class_name => 'HostAnsibleRole'

        attr_accessible :ansible_role_ids, :ansible_role_names,
          :ansible_parameters_attributes

        def pingable?
          # Timeout should be configurable
          Timeout::timeout(300) do
            until system("ping #{self.execution_interface} -c 3")
            end
          end
        end

        def ansible_roles
          result = []
          if hostgroup.present? && hostgroup.ansible_roles.present?
            result += hostgroup.ansible_roles
          end
          result += super

          result.compact
        end

        def built_with_run_roles_playbook(installed = true)
          result = built_without_run_roles_playbook(installed)
          if result == true
            run_roles_playbook
          end
        end
        alias_method_chain :built, :run_roles_playbook

        def run_roles_playbook
          return if ansible_roles.empty?
          wait_until_pingable

          if ansible_roles.present?
            playbook = create_playbook
            create_job_invocation(playbook)
          else
            return
          end
        end

        private

        def wait_until_pingable
          pingable?
        rescue Timeout::Error
          update_attributes(:ansible_roles => [])
        end

        def create_playbook
          roles_in_yaml = ansible_roles.map { |role| "    - #{role.name}" }.
            join("\n")
          hosts_section   = "---\n- hosts: #{name}\n"
          nofacts_section = "  gather_facts: False\n" # only for CoreOS
          roles_section   = "  roles:\n#{roles_in_yaml}"
          template_content = hosts_section
          template_content += nofacts_section if os.family == 'Coreos'
          template_content += roles_section

          job_template = JobTemplate.find_by_name("Ansible - #{name} roles")
          job_template ||= JobTemplate.create(
            :name => "Ansible - #{name} roles",
            :provider_type => 'Ansible',
            :job_category => 'Miscellaneous')
          job_template.template = template_content
          job_template.save
          job_template
        end

        def create_job_invocation(playbook)
          params = {
            'job_invocation' => {
              'job_category' => 'Miscellaneous',
              'providers'    => {
                'Ansible' => {
                  'job_template_id' => playbook.id
                }
              },
              'description'  => 'Miscellaneous',
              'description_override' => '%{job_category}',
              'description_format'   => '%{job_category}'
            },
            'targeting' => {
              'search_query'   => "name = #{name}",
              'targeting_type' => 'static_query'
            },
            'triggering' => {
              'mode'         => 'immediate',
              'start_at_raw' => Time.now } }.with_indifferent_access

          # copied from job_invocations controller, refactor
          composer = JobInvocationComposer.from_ui_params(params)
          if composer.save
            job_invocation = composer.job_invocation
            job_invocation.generate_description! if job_invocation.description.blank?
            composer.triggering.trigger(::Actions::RemoteExecution::RunHostsJob, job_invocation)
          end
        end
      end
    end
  end
end
