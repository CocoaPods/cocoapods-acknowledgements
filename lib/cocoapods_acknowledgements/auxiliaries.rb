module CocoaPodsAcknowledgements
	module Auxiliaries
      def file_accessor(spec, platform, sandbox)
        pod_root = sandbox.pod_dir(spec.name)
        if pod_root.exist?
          path_list = Pod::Sandbox::PathList.new(pod_root)
          Pod::Sandbox::FileAccessor.new(path_list, spec.consumer(platform))
        end
      end

      # Returns the text of the license for the given spec.
      #
      # @param  [Specification] spec
      #         the specification for which license is needed.
      #
      # @return [String] The text of the license.
      # @return [Nil] If not license text could be found.
      #
      def license_text(spec, file_accessor)
        return nil unless spec.license
        text = spec.license[:text]
        unless text
          if file_accessor
            if license_file = file_accessor.license
              if license_file.exist?
                text = IO.read(license_file)
              else
                Pod::UI.warn "Unable to read the license file `#{license_file }` " \
                  "for the spec `#{spec}`"
              end
            end
          end
        end
        text
      end
	end
end