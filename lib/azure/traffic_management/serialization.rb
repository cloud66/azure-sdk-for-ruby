require 'azure/traffic_management/profile'
require 'azure/traffic_management/definition'
require 'base64'

module Azure
	module TrafficManagement
		module Serialization

			def self.profiles_from_xml(profilesXML)
				unless profilesXML.nil? or profilesXML.at_css('Profiles').nil?
					profiles = profilesXML.css('Profiles Profile')
					pfs = []
					profiles.each do |profile|
						pf = Profile.new
						pf.domain_name = xml_content(profile, 'DomainName')
						pf.name = xml_content(profile, 'Name')
						pf.status = xml_content(profile, 'Status')
						pfs << pf
					end
					pfs
				end
			end

			def self.profile_to_xml(profile_name, profile_dns_name)
				builder = Nokogiri::XML::Builder.new do |xml|
					xml.Profile(
							'xmlns' => 'http://schemas.microsoft.com/windowsazure',
							'xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance'
					) do
						xml.DomainName profile_dns_name
						xml.Name profile_name
					end
				end
				builder.doc.to_xml
			end

			def self.definitions_from_xml(definitionsXML)
				unless definitionsXML.nil? or definitionsXML.at_css('Definitions').nil?
					definitions = definitionsXML.css('Definitions Definition')
					dfs = []
					definitions.each do |definition|
						df = Definition.new
						df.status = xml_content(definition, 'Status')
						df.time_to_live = xml_content(definition, 'DnsOptions TimeToLiveInSeconds')
						df.monitor_interval = xml_content(definition, 'Monitors Monitor IntervalInSeconds')
						df.monitor_timeout = xml_content(definition, 'Monitors Monitor TimeoutInSeconds')
						df.monitor_tolerated_number_of_failures = xml_content(definition, 'Monitors Monitor ToleratedNumberOfFailures')
						df.monitor_protocol = xml_content(definition, 'Monitors Monitor Protocol')
						df.monitor_port = xml_content(definition, 'Monitors Monitor Port')
						df.monitor_http_verb = xml_content(definition, 'Monitors Monitor HttpOptions Verb')
						df.monitor_http_relative_path = xml_content(definition, 'Monitors Monitor HttpOptions RelativePath')
						df.monitor_http_expected_status_code = xml_content(definition, 'Monitors Monitor HttpOptions ExpectedStatusCode')
						df.load_balancing_method = xml_content(definition, 'Policy LoadBalancingMethod')
						end_points = definition.css('Policy Endpoints Endpoint')
						eps = []
						end_points.each do |end_point|
							ep = {}
							ep[:domain_name] = xml_content(end_point, 'DomainName')
							ep[:status] = xml_content(end_point, 'Status')
							ep[:monitor_status] = xml_content(end_point, 'MonitorStatus')
							ep[:location] = xml_content(end_point, 'Location')
							ep[:min_child_endpoints] = xml_content(end_point, 'MinChildEndpoints')
							eps << ep
						end
						df.end_points = eps
						dfs << df
					end
					dfs
				end
			end

		end
	end
end
