#
# Be sure to run `pod lib lint TMCollectionViewTemplate.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TMCollectionViewTemplate'
  s.version          = '1.0'
  s.summary          = 'Template auto layout cell for automatically UICollectionViewCell size calculate, cache and precache'
  s.description      = "Template auto layout cell for automatically UICollectionViewCell size calculate, cache and precache. Requires a `self-satisfied` UICollectionViewCell, using system's `- systemLayoutSizeFittingSize:`, provides size caching."

  s.homepage         = 'https://github.com/Tovema-iOS/TMCollectionViewTemplate'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lxb_0605@qq.com' => 'lxb_0605@qq.com' }
  s.source           = { :git => 'https://github.com/Tovema-iOS/TMCollectionViewTemplate.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'TMCollectionViewTemplate/Classes/**/*'
end
