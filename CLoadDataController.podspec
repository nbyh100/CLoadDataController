Pod::Spec.new do |s|
  s.name             = 'CLoadDataController'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CLoadDataController.'
  s.description      = <<-DESC
This is a long description, is longer than the short description.
                       DESC

  s.homepage         = 'https://github.com/nbyh100@sina.com/CLoadDataController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nbyh100@sina.com' => 'jiuzhou.zhang@fengjr.com' }
  s.source           = { :git => 'https://github.com/nbyh100@sina.com/CLoadDataController.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'CLoadDataController/Classes/**/*'
  s.frameworks = 'UIKit'
  s.dependency 'PromiseKit/Promise', '1.7.2'
  s.dependency 'MJRefresh', '3.1.12'
end
