require 'azure/traffic_management/profile'
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

		end
	end
end
