require 'azure/traffic_management/serialization'

module Azure
	module TrafficManagement
		class TrafficManagementService < BaseManagementService
			def initialize(management_certificate, subscription_id)
				super(management_certificate, subscription_id)
			end

			def list_profiles
				profiles = []
				request_path = '/services/WATM/profiles'
				request = ManagementHttpRequest.new(:get, request_path, nil, self.cert_key, self.pr_key, self.subscr_id)
				request.warn = true
				response = request.call

				profiles << Serialization.profiles_from_xml(response)

				profiles.flatten.compact
			end

			def create_profile(profile_name,profile_dns_name)
				Loggerx.info 'Creating profile...'
				body = Serialization.profile_to_xml(profile_name,profile_dns_name)
				path = '/services/WATM/profiles'
				request = ManagementHttpRequest.new(:post, path, body, self.cert_key, self.pr_key, self.subscr_id)
				request.call
				profiles = self.list_profiles
				profiles.select {|pf| pf.name == profile_name}.first
			rescue Exception => e
				e.message
			end

			def list_definitions(profile_name)
				definitions = []
				request_path = "/services/WATM/profiles/#{profile_name}/definitions"
				request = ManagementHttpRequest.new(:get, request_path, nil, self.cert_key, self.pr_key, self.subscr_id)
				request.warn = true
				response = request.call
				definitions << Serialization.definitions_from_xml(response)
				definitions.flatten.compact
			end

			def create_definition(profile_name,params)
				body = Serialization.definition_to_xml(params)
				path = "/services/WATM/profiles/#{profile_name}/definitions"
				Loggerx.info 'Definition creation in progress...'
				request = ManagementHttpRequest.new(:post, path, body, self.cert_key, self.pr_key, self.subscr_id)
				request.call
			rescue Exception => e
				e.message
			end

		end
	end
end
