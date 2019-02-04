Pod::Spec.new do |s|
  s.name         = "FlexibleDiff"
  s.version      = "0.0.7"
  s.summary      = "A Swift collection diffing μframework."
  s.description  = <<-DESC
                   A Swift collection diffing μframework implementing the O(N) Paul Heckel diff algorithm.
                   DESC
  s.homepage     = "https://github.com/RACCommunity/FlexibleDiff"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = "ReactiveCocoa"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/RACCommunity/FlexibleDiff.git", :tag => "#{s.version}" }
  
  s.source_files  = "FlexibleDiff/*.{swift}"
  s.swift_version = "4.0"
end
