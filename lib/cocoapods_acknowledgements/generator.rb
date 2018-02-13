require 'cocoapods_acknowledgements/auxiliaries'
module CocoaPodsAcknowledgements
	class Generator
		class << self
			include Auxiliaries
			def generate_specs(target_description, sandbox, excluded, root_specs)
				[]
			end
			def generate(target_description, sandbox, excluded)
				root_specs = target_description.specs.map(&:root).uniq.reject { |spec| excluded.include?(spec.name) }
		        return nil if root_specs.empty?
		        generate_specs(target_description, sandbox, excluded, root_specs)
			end		
		end
	end
end