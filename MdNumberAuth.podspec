require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name            = "MdNumberAuth"
  s.version         = package["version"]
  s.summary         = package["description"]
  s.description     = package["description"]
  s.homepage        = "https://github.com/md/md-native-number-auth"
  s.license         = package["license"]
  s.platforms       = { :ios => "11.0" }
  s.author          = { "md" => "md@example.com" }
  s.source          = { :git => "https://github.com/md/md-native-number-auth.git", :tag => "#{s.version}" }

  s.source_files    = "ios/MdNumberAuth/**/*.{h,m,mm,swift}"
  s.public_header_files = "ios/MdNumberAuth/**/*.h"

  s.vendored_frameworks = [
    "ios/Frameworks/ATAuthSDK.xcframework",
    "ios/Frameworks/YTXOperators.xcframework",
    "ios/Frameworks/YTXMonitor.xcframework"
  ]

  # ATAuthSDK 的默认 UI 图片（复选框 icon_check/icon_uncheck、导航返回箭头、关闭按钮）
  # 打在 ATAuthSDK.framework 内的 ATAuthSDK.bundle 里。静态 xcframework 不会被
  # CocoaPods 自动拷贝其内嵌 bundle，必须显式作为 resources 打进 App，否则运行时
  # 找不到这些图 → 复选框/返回按钮不显示。
  s.resources = ["ios/Resources/ATAuthSDK.bundle"]

  s.frameworks = [
    "UIKit",
    "Foundation",
    "CoreTelephony",
    "SystemConfiguration",
    "Security",
    "WebKit"
  ]

  s.libraries = ["c++", "resolv.9", "z"]

  s.pod_target_xcconfig = {
    "OTHER_LDFLAGS" => "-ObjC",
    "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => ""
  }

  s.dependency "React-Core"

  if defined?(install_modules_dependencies)
    install_modules_dependencies(s)
  end
end
