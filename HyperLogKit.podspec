Pod::Spec.new do |spec|

  spec.name         = "HyperLogKit"
  spec.version      = "0.0.1"
  spec.summary      = "Modified LogKit to use local DB of iOS"
  spec.description  = "This HyperLogKit is based on LogKit(http://www.logkit.info/). 			       Modified to use CoreData of iOS at Endpoint"
  spec.homepage     = "https://github.com/solusguard/HyperLogKit.git"
  spec.license      = { :type => "LogKit", :file => "LICENSE.txt" }
  spec.author       = { "Kasiel Solutions Inc" }
  spec.platform     = :ios
  spec.ios.deployment_target = "8.0"

  spec.source       = { :git => "https://github.com/solusguard/HyperLogKit.git", :tag => "{spec.version}" }

  spec.source_files  = "HyperLogKit"
  spec.exclude_files = "Classes/Exclude"
  spec.swift_version = "5.1"
end
