#
# Be sure to run `pod lib lint UseDesk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UseDesk'
  s.version          = '0.1.5'
  s.summary          = 'A short description of UseDesk.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/xot-dog/UseDesk.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'serega@budyakov.com' => 'ixotdog@gmail.com' }
  s.source           = { :git => 'https://github.com/usedesk/Use_Desk_iOS_SDK', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.0'
  s.requires_arc = true
  s.static_framework = true
  
  s.ios.source_files = 'UseDesk/Classes/*.{h,m}'
  
  s.resources = 'UseDesk/Classes/*.{png,jpeg,jpg,storyboard,xib}'
  #s.resources = 'UseDesk/Assets/*.{png,storyboard}'
  #s.resource_bundles = {
  #   'UseDesk' => ['UseDesk/Classes/*']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit' ,'AVFoundation'
  s.dependency 'MBProgressHUD'
  s.dependency 'NYTPhotoViewer', '1.2.0'
  s.dependency 'ProgressHUD'
  s.dependency 'RCAudioPlayer'
  s.dependency 'Socket.IO-Client-Swift', '~> 9.0.1'
  s.dependency 'AFNetworking', '>= 3.1.0'
  s.dependency 'RCAudioPlayer'
  s.dependency 'NSDate-Escort'
  s.dependency 'QBImagePickerController'
  s.dependency 'NSDate+Helpers'
end
