module Azure
	module TrafficManagement
		class Definition
			def initialize
				yield self if block_given?
			end

			attr_accessor :status
			attr_accessor :time_to_live
			attr_accessor :monitor_interval
			attr_accessor :monitor_timeout
			attr_accessor :monitor_tolerated_number_of_failures
			attr_accessor :monitor_protocol
			attr_accessor :monitor_port
			attr_accessor :monitor_http_verb
			attr_accessor :monitor_http_relative_path
			attr_accessor :monitor_http_expected_status_code
			attr_accessor :load_balancing_method
			attr_accessor :end_points
		end
	end
end
