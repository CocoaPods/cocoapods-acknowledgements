module CocoaPodsAcknowledgements
  require 'cocoapods_acknowledgements/plist_generator'

  Pod::HooksManager.register('cocoapods-acknowledgements', :post_install) do |context|
    require 'cocoapods'
    
    p context
    Pod::UI.section 'Adding Acknowledgements' do
    
      sandbox = Pod::Sandbox.new(context.sandbox_root)
      context.umbrella_targets.each do |umbrella_target|
        project = Xcodeproj::Project.open(umbrella_target.user_project_path)
        
        umbrella_target.user_target_uuids.each do |user_target_uuid|
        
          metadata = PlistGenerator.generate(umbrella_target, sandbox)
          plist_path = sandbox.root + "#{umbrella_target.cocoapods_target_label}-metadata.plist"
          Xcodeproj.write_plist(metadata, plist_path)

          project = Xcodeproj::Project.open(umbrella_target.user_project_path)
          cocoapods_group = project.main_group["CocoaPods"]
          unless cocoapods_group
            cocoapods_group = project.main_group.new_group("CocoaPods", sandbox.root)
          end

          file_ref = cocoapods_group.files.find { |file| file.real_path == plist_path }
          unless file_ref
            file_ref = cocoapods_group.new_file(plist_path)
          end

          target = project.objects_by_uuid[user_target_uuid]
          unless target.resources_build_phase.files_references.include?(file_ref)
            target.add_resources([file_ref])
          end

          project.save

        end
        
      end
      


    end
    
  end
end


