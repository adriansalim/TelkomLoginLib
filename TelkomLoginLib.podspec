Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '11.0'
s.name = "TelkomLoginLib"
s.summary = "TelkomLoginLib."
s.requires_arc = true
s.version = "1.0.0"
s.license = { :type => "MIT", :file => "LICENSE" }
s.author = { "Adrian Hartanto Salim" => "adriansalimlim@gmail.com" }
s.homepage = "https://github.com/adriansalim/TelkomLoginLib"
s.source = { :git => "https://github.com/adriansalim/TelkomLoginLib.git", 
             :tag => "#{s.version}" }
s.framework = "UIKit"
s.source_files = "TelkomLoginLib/**/*.{swift}"
s.swift_version = "4.2"

end
