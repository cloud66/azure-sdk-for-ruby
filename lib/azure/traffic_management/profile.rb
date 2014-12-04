module Azure
	module TrafficManagement
		class Profile
			def initialize
				yield self if block_given?
			end

			attr_accessor :domain_name
			attr_accessor :name
			attr_accessor :status
		end
	end
end
