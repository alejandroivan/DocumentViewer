#
# Be sure to run `pod lib lint DocumentViewer.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'DocumentViewer'
  s.version          = '1.1.0'
  s.summary          = 'A library to be used to display different file types on iOS.'
  
  s.module_name      = 'DocumentViewer'
  s.swift_version    = '5.0'

  s.description      = <<-DESC
                        A `DocumentViewer` view controller that can be used to
                        present different types of documents.
                       DESC

  s.homepage         = 'https://github.com/alejandroivan/DocumentViewer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alejandro Melo Domínguez' => 'alejandroivan@icloud.com' }
  s.source           = { :git => 'https://github.com/alejandroivan/DocumentViewer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/alejandroivan'

  s.ios.deployment_target = '12.0'

  s.source_files = 'DocumentViewer/Classes/**/*'

  s.frameworks = 'Foundation', 'PDFKit', 'SystemConfiguration', 'UIKit'
end
