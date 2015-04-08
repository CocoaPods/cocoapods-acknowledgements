module CocoaPodsAcknowledgements
  require 'cocoapods_acknowledgements/plist_generator'
  require 'cocoapods_acknowledgements/settings_plist_generator'

  def self.save_metadata(metadata, plist_path, project, sandbox, user_target_uuid)
    Xcodeproj.write_plist(metadata, plist_path)

    # Find a root folder in the users Xcode Project called CocoaPods, or make one
    cocoapods_group = project.main_group["CocoaPods"]
    unless cocoapods_group
      cocoapods_group = project.main_group.new_group("CocoaPods", sandbox.root)
    end

    # Add the example plist to the found CocoaPods group
    file_ref = cocoapods_group.files.find { |file| file.real_path == plist_path }
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

  Pod::HooksManager.register('cocoapods-acknowledgements', :post_install) do |context, user_options|
    require 'cocoapods'
    
    Pod::UI.section 'Adding Acknowledgements' do
    
      sandbox = Pod::Sandbox.new(context.sandbox_root)
      context.umbrella_targets.each do |umbrella_target|
        project = Xcodeproj::Project.open(umbrella_target.user_project_path)
        
        umbrella_target.user_target_uuids.each do |user_target_uuid|
        
          # Generate a plist representing all of the podspecs
          metadata = PlistGenerator.generate(umbrella_target, sandbox)
          plist_path = sandbox.root + "#{umbrella_target.cocoapods_target_label}-metadata.plist"
          save_metadata(metadata, plist_path, project, sandbox, user_target_uuid)
          
          # Generate a plist in Settings format
          settings_metadata = SettingsPlistGenerator.generate(umbrella_target, sandbox)
          settings_plist_path = sandbox.root + "#{umbrella_target.cocoapods_target_label}-settings-metadata.plist"
          save_metadata(settings_metadata, settings_plist_path, project, sandbox, user_target_uuid)

        end
        
      end
      


    end
    
  end
end


