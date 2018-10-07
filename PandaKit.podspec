Pod::Spec.new do |s|

  s.name         = "PandaKit"
  s.version      = "0.1-beta"
  s.summary      = "An asynchronous render and layout framework which can be used to achieve high performance tableview"

  s.description  = <<-DESC  
                   Panda is a asynchronous render and layout framework which can be used to achieve high performance tableview.
                   DESC

  s.homepage     = "https://github.com/nangege/Panda"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = { "Tang.Nan" => "tang22nan@gmail.com" }

  s.swift_version = "4.2"

  s.ios.deployment_target = "8.0"
  s.module_name = "Panda"


  s.source       = { :git => "https://github.com/nangege/Panda.git", :tag => '0.1-beta' }
  s.source_files  = ["Panda/**/*.swift", "Panda/Panda.h"]
  s.public_header_files = ["Panda/Panda.h"]
  

  s.requires_arc = true

  s.dependency 'SwiftCassowary', '~> 0.1-beta'
  s.dependency 'SwiftLayoutable', '~> 0.1-beta'

end
