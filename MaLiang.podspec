#
# Be sure to run `pod lib lint MaLiang.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MaLiang'
  s.version          = '1.1.8'
  s.summary          = 'MaLiang is a painting Framework based on OpenGL ES.'

  s.description      = <<-DESC
The name of "MaLiang" comes from a boy who had a magical brush in Chinese ancient fairy story.
                        DESC

  s.homepage         = 'https://github.com/harley-xk/MaLiang'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'harley-xk' => 'halrey.gb@foxmail.com' }
  s.source           = { :git => 'https://github.com/harley-xk/MaLiang.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }

  s.source_files = 'MaLiang/Classes/**/*'
  
  s.resource_bundles = {
     'MaLiang' => ['MaLiang/Resources/*']
  }

end
