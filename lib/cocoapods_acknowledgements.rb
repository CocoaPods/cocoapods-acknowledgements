module CocoaPodsAcknowledgements
  require 'cocoapods_acknowledgements/plist_generator'
  require 'cocoapods_acknowledgements/html_generator'
  require 'cocoapods_acknowledgements/settings_plist_generator'
  require 'cocoapods_acknowledgements/writers'
  def self.write_metadata(metadata, filepath)
    Writers.write(metadata, filepath)
  end

  def self.add_metadata_to_project(plist_path, project, sandbox, user_target_uuid)
    # Find a root folder in the users Xcode Project called Pods, or make one
    cocoapods_group = project.main_group["Pods"]
    unless cocoapods_group
      cocoapods_group = project.main_group.new_group("Pods", sandbox.root)
    end

    # Add the example plist to the found CocoaPods group
    plist_pathname = Pathname.new(File.expand_path(plist_path))
    file_ref = cocoapods_group.files.find {|file| file.real_path == plist_pathname}
    unless file_ref
      file_ref = cocoapods_group.new_file(plist_path)
    end

    # Ensure that the plist is added to target
    target = project.objects_by_uuid[user_target_uuid]
    unless target.resources_build_phase.files_references.include?(file_ref)
      target.add_resources([file_ref])
    end

    project.save
  end

  def self.save_metadata(metadata, plist_path, project, sandbox, user_target_uuid)
    write_metadata(metadata, plist_path)
    add_metadata_to_project(plist_path, project, sandbox, user_target_uuid)
  end

  def self.settings_bundle_in_project(project)
    file = project.files.find {|f| f.path =~ /Settings\.bundle$/}
    file.real_path.to_path unless file.nil?
  end

  Pod::HooksManager.register('cocoapods-acknowledgements', :post_install) do |context, user_options|
    require 'cocoapods'
    require 'set'

    # Until CocoaPods provides a HashWithIndifferentAccess, normalize the hash keys here.
    # See https://github.com/CocoaPods/CocoaPods/issues/3354

    user_options.inject({}) do |normalized_hash, (key, value)|
      normalized_hash[key.to_s] = value
      normalized_hash
    end

    Pod::UI.section 'Adding Acknowledgements' do

      should_include_settings = user_options["settings_bundle"] != nil
      excluded_pods = Set.new(user_options["exclude"])

      sandbox = context.sandbox if defined? context.sandbox
      sandbox ||= Pod::Sandbox.new(context.sandbox_root)

      context.umbrella_targets.each do |umbrella_target|
        project = Xcodeproj::Project.open(umbrella_target.user_project_path)

        umbrella_target.user_target_uuids.each do |user_target_uuid|

          # Generate a plist representing all of the podspecs
          plist_metadata = PlistGenerator.generate(umbrella_target, sandbox, excluded_pods)
          html_metadata = HTMLGenerator.generate(umbrella_target, sandbox, excluded_pods)
          next unless plist_metadata

          # save plist file.
          plist_path = sandbox.root + "#{umbrella_target.cocoapods_target_label}-metadata.plist"
          save_metadata(plist_metadata, plist_path, project, sandbox, user_target_uuid)

          # save html file.
          html_path = sandbox.root + "#{umbrella_target.cocoapods_target_label}-metadata.html"
          save_metadata(html_metadata, html_path, project, sandbox, user_target_uuid)

          # save markdown file.
          markdown_path = sandbox.root + "#{umbrella_target.cocoapods_target_label}-metadata.md"
          save_metadata(html_metadata, markdown_path, project, sandbox, user_target_uuid)

          if should_include_settings
            # Generate a plist in Settings format
            settings_metadata = SettingsPlistGenerator.generate(umbrella_target, sandbox, excluded_pods)

            # We need to look for a Settings.bundle
            # and add this to the root of the bundle

            settings_bundle = settings_bundle_in_project(project)
            if settings_bundle == nil
              Pod::UI.warn "Could not find a Settings.bundle to add the Pod Settings Plist to."
            else
              settings_plist_path = settings_bundle + "/#{umbrella_target.cocoapods_target_label}-settings-metadata.plist"
              save_metadata(settings_metadata, settings_plist_path, project, sandbox, user_target_uuid)
              Pod::UI.info "Added Pod info to Settings.bundle for target #{umbrella_target.cocoapods_target_label}"

              # Support a callback for the key :settings_post_process
              if user_options["settings_post_process"]
                user_options["settings_post_process"].call(settings_plist_path, umbrella_target, excluded_pods)
              end

            end
          end

        end

      end

    end

  end
end
