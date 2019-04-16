require File.expand_path('../spec_helper.rb', __FILE__)

describe PlistGenerator = CocoaPodsAcknowledgements::PlistGenerator do

  before do
    @spec1 = SpecHelper.spec1
    @spec2 = SpecHelper.spec2
    PlistGenerator.stubs(:file_accessor).returns(nil)
    @sandbox = temporary_sandbox
    @target_description = stub('target_description',
                              :specs => [@spec1, @spec2],
                              :platform_name => 'ios')
  end

  describe 'In general' do
    it 'generates metadata' do
      result = PlistGenerator.generate(@target_description, @sandbox, [])
      result.should == {
        "specs" => [
          {
            "name" => "monkeylib",
            "version"=> Pod::Version.new(1.0),
            "authors"=> {
              "CocoaPods" => "email@cocoapods.org"
            },
            "socialMediaURL" => "https://twitter.com/CocoaPods",
            "summary" => "A lib to do monkey things",
            "description" => "<h2>What is it</h2>\n\n<p>A lib to do monkey things</p>\n\n<h2>Why?</h2>\n\n<p>Why not?</p>\n",
            "licenseType" => "MIT",
            "licenseText" => "Permission is hereby granted ...",
            "homepage" => "https://github.com/CocoaPods/monkeylib"
          },
          {
            "name" => "BananaLib",
            "version" => Pod::Version.new(1.0),
            "authors" => {
              "Banana Corp" => nil,
              "Monkey Boy" => "monkey@banana-corp.local"
            },
            "socialMediaURL" => nil,
            "summary" => "Chunky bananas!",
            "description" => "<p>Full of chunky bananas.</p>\n",
            "licenseType" => "MIT",
            "licenseText" => "Permission is hereby granted ...",
            "homepage" => "http://banana-corp.local/banana-lib.html"
          }
        ]
      }
    end

    it 'generates nil if specs is empty' do
      target_description = stub('target_description',
                                :specs => [],
                                :platform_name => 'ios')
      result = PlistGenerator.generate(target_description, @sandbox, [])
      result.should.be.nil?
    end

    it 'does not include metadata for excluded specs' do
      target_description = stub('target_description',
                                :specs => [@spec1, @spec2],
                                :platform_name => 'ios')
      result = PlistGenerator.generate(target_description, @sandbox, [@spec1.name])
      result.should == {
        "specs" => [
          {
            "name" => "BananaLib",
            "version" => Pod::Version.new(1.0),
            "authors" => {
              "Banana Corp" => nil,
              "Monkey Boy" => "monkey@banana-corp.local"
            },
            "socialMediaURL" => nil,
            "summary" => "Chunky bananas!",
            "description" => "<p>Full of chunky bananas.</p>\n",
            "licenseType" => "MIT",
            "licenseText" => "Permission is hereby granted ...",
            "homepage" => "http://banana-corp.local/banana-lib.html"
          }
        ]
      }
    end

    it 'generates nil when all specs are excluded' do
      target_description = stub('target_description',
                                :specs => [@spec1, @spec2],
                                :platform_name => 'ios')
      result = PlistGenerator.generate(target_description, @sandbox, [@spec1.name, @spec2.name])
      result.should.be.nil?
    end

    describe '#license_text' do
      it 'returns nil if license is missing' do
        spec = stub('spec', :license => nil)
        result = PlistGenerator.license_text(spec, nil)
        result.should.be.nil?
      end

      it 'returns text if specified' do
        spec = stub('spec', :license => { :text => 'Permission is hereby granted ...'})
        result = PlistGenerator.license_text(spec, nil)
        result.should == 'Permission is hereby granted ...'
      end

      it 'reads license files when specified' do
        license_file = SpecHelper.temporary_directory + 'LICENSE'
        license_file.open('w') { |f| f.write("Permission is hereby granted ...") }
        spec = stub('spec', :license => { :file => license_file })
        file_accessor = stub('file_accessor', :license => license_file)
        result = PlistGenerator.license_text(spec, file_accessor)
        result.should == 'Permission is hereby granted ...'
        FileUtils.rm_f(license_file)
      end

      it 'warns when a license file is specified but does not exist' do
        license_file = SpecHelper.temporary_directory + 'non-existent-file.txt'
        spec = stub('spec', :license => { :file => license_file })
        file_accessor = stub('file_accessor', :license => license_file)
        PlistGenerator.license_text(spec, file_accessor)
        Pod::UI.warnings.should.match /Unable to read the license file/
      end
    end

    it 'renders markdown' do
      contents = <<EOT
# Title
Title description

## H2 Title
* List item 1
* List item 2

### Sub Sub Head
> Some interesting quote
**
EOT
      expected = "<h1>Title</h1>\n\n<p>Title description</p>\n\n<h2>H2 Title</h2>\n\n<ul>\n<li>List item 1</li>\n<li>List item 2</li>\n</ul>\n\n<h3>Sub Sub Head</h3>\n\n<blockquote>\n<p>Some interesting quote\n**</p>\n</blockquote>\n"
      result = PlistGenerator.parse_markdown(contents)
      result.should == "<h1>Title</h1>\n\n<p>Title description</p>\n\n<h2>H2 Title</h2>\n\n<ul>\n<li>List item 1</li>\n<li>List item 2</li>\n</ul>\n\n<h3>Sub Sub Head</h3>\n\n<blockquote>\n<p>Some interesting quote\n**</p>\n</blockquote>\n"
    end
  end
end
