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

			def self.definition_to_xml(params)
				builder = Nokogiri::XML::Builder.new do |xml|
					xml.Definition(
							'xmlns' => 'http://schemas.microsoft.com/windowsazure',
							'xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance'
					) do
						unless params[:time_to_live].nil?
							xml.DnsOptions do
								xml.TimeToLiveInSeconds params[:time_to_live]
							end
						end

						http_option_not_needed = params[:monitor_http_verb].nil? && params[:monitor_http_relative_path].nil? && params[:monitor_http_expected_status_code].nil?
						monitor_not_needed = params[:monitor_interval].nil? && params[:monitor_timeout].nil? && params[:monitor_tolerated_number_of_failures].nil? && params[:monitor_protocol].nil? && params[:monitor_port].nil? && http_option_not_needed

						unless monitor_not_needed
							xml.Monitors do
								xml.Monitor do
									xml.IntervalInSeconds  params[:monitor_interval] unless params[:monitor_interval].nil?
									xml.TimeoutInSeconds  params[:monitor_timeout] unless params[:monitor_timeout].nil?
									xml.ToleratedNumberOfFailures  params[:monitor_tolerated_number_of_failures] unless params[:monitor_tolerated_number_of_failures].nil?
									xml.Protocol  params[:monitor_protocol] unless params[:monitor_protocol].nil?
									xml.Port  params[:monitor_port] unless params[:monitor_port].nil?
									unless http_option_not_needed
										xml.HttpOptions do
											xml.Verb  params[:monitor_http_verb] unless params[:monitor_http_verb].nil?
											xml.RelativePath  params[:monitor_http_relative_path] unless params[:monitor_http_relative_path].nil?
											xml.ExpectedStatusCode  params[:monitor_http_expected_status_code] unless params[:monitor_http_expected_status_code].nil?
										end
									end
								end
							end
						end

						unless params[:load_balancing_method].nil? && params[:end_points].nil?
							xml.Policy do
								xml.LoadBalancingMethod  params[:load_balancing_method] unless params[:load_balancing_method].nil?
								unless params[:end_points].nil? || params[:end_points].class != Array
									xml.Endpoints do
										params[:end_points].each do |ep|
											next if ep[:domain_name].nil? && ep[:status].nil? && ep[:type].nil? && ep[:location].nil? && ep[:min_child_endpoints].nil? && ep[:weight].nil?
											xml.Endpoint do
												xml.DomainName  ep[:domain_name] unless ep[:domain_name].nil?
												xml.Status  ep[:status] unless ep[:status].nil?
												xml.Type  ep[:type] unless ep[:type].nil?
												xml.Location  ep[:location] unless ep[:location].nil?
												xml.MinChildEndpoints  ep[:min_child_endpoints] unless ep[:min_child_endpoints].nil?
												xml.Weight  ep[:weight] unless ep[:weight].nil?
											end
										end
									end
								end
							end
						end
					end
				end
				builder.doc.to_xml
			end
		end
	end
end
