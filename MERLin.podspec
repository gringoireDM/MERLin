Pod::Spec.new do |s|

    s.platform = :ios
    s.version = "1.0.1"
    s.ios.deployment_target = '10.0'
    s.name = "MERLin"
 	s.summary      = "A framework to build an event based, reactive architecture for swift iOS projects"
	s.swift_version = '4.1'
	
  	s.description  = <<-DESC
                   MERLin' is a reactive framework that aims to simplify the adoption of an events based architectural style within an iOS app. It emphasise the concept of modularity, taking to the highest level the principle of separation of concerns.
                   DESC
                   
    s.requires_arc = true

    s.license = { :type => "MIT" }
	s.homepage = "https://www.pfrpg.net"
    s.author = { "Giuseppe Lanza" => "gringoire986@gmail.com" }

    s.source = {
        :git => "https://github.com/gringoireDM/MERLin.git",
        :tag => "v1.0.1"
    }
    
	s.dependency 'LNZWeakCollection', '~>1.1.0'
	s.dependency 'RxCocoa', '~>4.1.2'
	
    s.framework = "UIKit"
	
    s.source_files = "MERLin/MERLin/**/*.{swift, h, m}"
end