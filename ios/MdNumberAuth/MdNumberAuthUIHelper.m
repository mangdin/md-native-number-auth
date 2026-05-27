#import "MdNumberAuthUIHelper.h"
#import <UIKit/UIKit.h>

@implementation MdNumberAuthUIHelper

+ (UIColor *)colorFromHex:(NSString *)hex {
    if (![hex isKindOfClass:[NSString class]] || hex.length == 0) {
        return nil;
    }
    NSString *clean = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if (clean.length == 3) {
        NSString *r = [clean substringWithRange:NSMakeRange(0, 1)];
        NSString *g = [clean substringWithRange:NSMakeRange(1, 1)];
        NSString *b = [clean substringWithRange:NSMakeRange(2, 1)];
        clean = [NSString stringWithFormat:@"%@%@%@%@%@%@", r, r, g, g, b, b];
    }
    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:clean];
    if (![scanner scanHexInt:&rgbValue]) {
        return nil;
    }
    CGFloat alpha = 1.0;
    CGFloat red, green, blue;
    if (clean.length == 8) {
        alpha = ((rgbValue & 0xFF000000) >> 24) / 255.0;
        red   = ((rgbValue & 0x00FF0000) >> 16) / 255.0;
        green = ((rgbValue & 0x0000FF00) >>  8) / 255.0;
        blue  =  (rgbValue & 0x000000FF)        / 255.0;
    } else {
        red   = ((rgbValue & 0xFF0000) >> 16) / 255.0;
        green = ((rgbValue & 0x00FF00) >>  8) / 255.0;
        blue  =  (rgbValue & 0x0000FF)        / 255.0;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIImage *)imageNamed:(NSString *)name {
    if (![name isKindOfClass:[NSString class]] || name.length == 0) {
        return nil;
    }
    UIImage *img = [UIImage imageNamed:name];
    return img;
}

+ (NSArray<NSString *> *)privacyArrayFromValue:(id)value {
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *arr = value;
        if (arr.count >= 2) {
            return @[arr[0], arr[1]];
        }
    }
    return nil;
}

+ (TXCustomModel *)buildModelFromConfig:(NSDictionary *)config {
    TXCustomModel *model = [[TXCustomModel alloc] init];
    if (![config isKindOfClass:[NSDictionary class]]) {
        return model;
    }

    // 导航
    UIColor *navColor = [self colorFromHex:config[@"navColor"]];
    if (navColor) model.navColor = navColor;
    NSString *navText = config[@"navText"];
    UIColor *navTextColor = [self colorFromHex:config[@"navTextColor"]] ?: [UIColor whiteColor];
    if ([navText isKindOfClass:[NSString class]] && navText.length > 0) {
        model.navTitle = [[NSAttributedString alloc] initWithString:navText
                                                         attributes:@{NSForegroundColorAttributeName: navTextColor,
                                                                      NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]}];
    }
    if ([config[@"navHidden"] respondsToSelector:@selector(boolValue)]) {
        model.navIsHidden = [config[@"navHidden"] boolValue];
    }
    if ([config[@"navReturnHidden"] respondsToSelector:@selector(boolValue)]) {
        model.hideNavBackItem = [config[@"navReturnHidden"] boolValue];
    }
    if ([config[@"lightColor"] respondsToSelector:@selector(boolValue)]) {
        model.preferredStatusBarStyle = [config[@"lightColor"] boolValue]
            ? UIStatusBarStyleDarkContent
            : UIStatusBarStyleLightContent;
    }

    // Logo
    UIImage *logoImg = [self imageNamed:config[@"logoImage"]];
    if (logoImg) model.logoImage = logoImg;
    if ([config[@"logoHidden"] respondsToSelector:@selector(boolValue)]) {
        model.logoIsHidden = [config[@"logoHidden"] boolValue];
    }

    // Slogan
    NSString *sloganText = config[@"sloganText"];
    UIColor *sloganColor = [self colorFromHex:config[@"sloganTextColor"]] ?: [UIColor lightGrayColor];
    if ([sloganText isKindOfClass:[NSString class]] && sloganText.length > 0) {
        model.sloganText = [[NSAttributedString alloc] initWithString:sloganText
                                                           attributes:@{NSForegroundColorAttributeName: sloganColor,
                                                                        NSFontAttributeName: [UIFont systemFontOfSize:13.0]}];
    }
    if ([config[@"sloganHidden"] respondsToSelector:@selector(boolValue)]) {
        model.sloganIsHidden = [config[@"sloganHidden"] boolValue];
    }

    // Number
    UIColor *numberColor = [self colorFromHex:config[@"numberColor"]];
    if (numberColor) model.numberColor = numberColor;
    if ([config[@"numberSize"] respondsToSelector:@selector(doubleValue)]) {
        model.numberFont = [UIFont boldSystemFontOfSize:[config[@"numberSize"] doubleValue]];
    }

    // 登录按钮
    NSString *logBtnText = config[@"logBtnText"];
    UIColor *logBtnTextColor = [self colorFromHex:config[@"logBtnTextColor"]] ?: [UIColor whiteColor];
    if ([logBtnText isKindOfClass:[NSString class]] && logBtnText.length > 0) {
        model.loginBtnText = [[NSAttributedString alloc] initWithString:logBtnText
                                                             attributes:@{NSForegroundColorAttributeName: logBtnTextColor,
                                                                          NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0]}];
    }
    UIImage *logBtnBg = [self imageNamed:config[@"logBtnBackgroundImage"]];
    if (logBtnBg) {
        model.loginBtnBgImgs = @[logBtnBg, logBtnBg, logBtnBg];
    } else {
        UIColor *logBtnBgColor = [self colorFromHex:config[@"logBtnBackgroundColor"]];
        if (logBtnBgColor) {
            UIImage *pure = [self imageFromColor:logBtnBgColor];
            if (pure) model.loginBtnBgImgs = @[pure, pure, pure];
        }
    }

    // 切换按钮
    NSString *switchAccText = config[@"switchAccText"];
    UIColor *switchAccColor = [self colorFromHex:config[@"switchAccTextColor"]] ?: [UIColor lightGrayColor];
    if ([switchAccText isKindOfClass:[NSString class]] && switchAccText.length > 0) {
        model.changeBtnTitle = [[NSAttributedString alloc] initWithString:switchAccText
                                                               attributes:@{NSForegroundColorAttributeName: switchAccColor}];
    }
    if ([config[@"switchAccHidden"] respondsToSelector:@selector(boolValue)]) {
        model.changeBtnIsHidden = [config[@"switchAccHidden"] boolValue];
    }

    // 协议
    if ([config[@"checkboxIsChecked"] respondsToSelector:@selector(boolValue)]) {
        model.checkBoxIsChecked = [config[@"checkboxIsChecked"] boolValue];
    }
    if ([config[@"privacyState"] respondsToSelector:@selector(boolValue)]) {
        model.checkBoxIsHidden = [config[@"privacyState"] boolValue];
    }

    NSArray *p1 = [self privacyArrayFromValue:config[@"privacyOne"]];
    if (p1) model.privacyOne = p1;
    NSArray *p2 = [self privacyArrayFromValue:config[@"privacyTwo"]];
    if (p2) model.privacyTwo = p2;
    NSArray *p3 = [self privacyArrayFromValue:config[@"privacyThree"]];
    if (p3) model.privacyThree = p3;

    NSString *privacyPrefix = config[@"privacyPrefix"];
    if ([privacyPrefix isKindOfClass:[NSString class]]) model.privacyPreText = privacyPrefix;
    NSString *privacyEnd = config[@"privacyEnd"];
    if ([privacyEnd isKindOfClass:[NSString class]]) model.privacySufText = privacyEnd;

    NSArray *privacyColors = config[@"privacyColors"];
    if ([privacyColors isKindOfClass:[NSArray class]] && privacyColors.count >= 2) {
        UIColor *unchecked = [self colorFromHex:privacyColors[0]] ?: [UIColor lightGrayColor];
        UIColor *checked = [self colorFromHex:privacyColors[1]] ?: [UIColor blueColor];
        model.privacyColors = @[unchecked, checked];
    }

    if ([config[@"privacySize"] respondsToSelector:@selector(doubleValue)]) {
        model.privacyFont = [UIFont systemFontOfSize:[config[@"privacySize"] doubleValue]];
    }

    // 弹窗模式
    BOOL dialogMode = [config[@"dialogMode"] respondsToSelector:@selector(boolValue)]
        && [config[@"dialogMode"] boolValue];
    if (dialogMode) {
        CGFloat w = [config[@"dialogWidth"] respondsToSelector:@selector(doubleValue)]
            ? [config[@"dialogWidth"] doubleValue] : 300;
        CGFloat h = [config[@"dialogHeight"] respondsToSelector:@selector(doubleValue)]
            ? [config[@"dialogHeight"] doubleValue] : 400;
        CGFloat offsetX = [config[@"dialogOffsetX"] respondsToSelector:@selector(doubleValue)]
            ? [config[@"dialogOffsetX"] doubleValue] : 0;
        CGFloat offsetY = [config[@"dialogOffsetY"] respondsToSelector:@selector(doubleValue)]
            ? [config[@"dialogOffsetY"] doubleValue] : 0;
        model.contentViewFrameBlock = ^CGRect(CGSize screenSize, CGSize contentSize) {
            CGFloat x = (screenSize.width - w) / 2 + offsetX;
            CGFloat y = (screenSize.height - h) / 2 + offsetY;
            return CGRectMake(x, y, w, h);
        };
    }

    // 隐私二次弹窗
    if ([config[@"privacyAlertIsNeed"] respondsToSelector:@selector(boolValue)]) {
        model.privacyAlertIsNeedShow = [config[@"privacyAlertIsNeed"] boolValue];
    }

    return model;
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    if (!color) return nil;
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        UIGraphicsEndImageContext();
        return nil;
    }
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
