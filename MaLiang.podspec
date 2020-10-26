
Pod::Spec.new do |s|
  
  s.name             = 'MaLiang'
  s.version          = '2.9.0'
  s.summary          = 'MaLiang is a painting Framework based on Metal.'
  s.description      = 'The name of "MaLiang" comes from a boy who had a magical brush in Chinese ancient fairy story.'

  s.homepage         = 'https://github.com/Harley-xk/MaLiang'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Harley-xk' => 'harley.gb@foxmail.com' }
  s.source           = { :git => 'https://github.com/Harley-xk/MaLiang.git', :tag => s.version.to_s }

  s.swift_versions = ['5.0']
  s.ios.deployment_target = '9.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  s.source_files = 'MaLiang/Classes/**/*'
  
end
