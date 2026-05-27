#import <Foundation/Foundation.h>
#import <ATAuthSDK/ATAuthSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface MdNumberAuthUIHelper : NSObject

/// 将 JS 传入的字典转成 SDK 使用的 TXCustomModel。
/// 颜色支持 "#RGB" / "#RRGGBB" / "#AARRGGBB"。
/// 尺寸单位 pt。
+ (TXCustomModel *)buildModelFromConfig:(nullable NSDictionary *)config;

/// 解析十六进制颜色字符串。
+ (UIColor * _Nullable)colorFromHex:(NSString * _Nullable)hex;

@end

NS_ASSUME_NONNULL_END
