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
