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
    CGFloat navTextSize = 17.0;
    if ([config[@"navTextSize"] respondsToSelector:@selector(doubleValue)]) {
        navTextSize = [config[@"navTextSize"] doubleValue];
    }
    if ([navText isKindOfClass:[NSString class]] && navText.length > 0) {
        model.navTitle = [[NSAttributedString alloc] initWithString:navText
                                                         attributes:@{NSForegroundColorAttributeName: navTextColor,
                                                                      NSFontAttributeName: [UIFont boldSystemFontOfSize:navTextSize]}];
    }
    if ([config[@"navHidden"] respondsToSelector:@selector(boolValue)]) {
        model.navIsHidden = [config[@"navHidden"] boolValue];
    }
    if ([config[@"navReturnHidden"] respondsToSelector:@selector(boolValue)]) {
        model.hideNavBackItem = [config[@"navReturnHidden"] boolValue];
    }
    UIImage *navBackImg = [self imageNamed:config[@"navReturnImage"]];
    if (navBackImg) model.navBackImage = navBackImg;
    if ([config[@"lightColor"] respondsToSelector:@selector(boolValue)]) {
        model.preferredStatusBarStyle = [config[@"lightColor"] boolValue]
            ? UIStatusBarStyleDarkContent
            : UIStatusBarStyleLightContent;
    }
    if ([config[@"statusBarHidden"] respondsToSelector:@selector(boolValue)]) {
        model.prefersStatusBarHidden = [config[@"statusBarHidden"] boolValue];
    }

    // 协议详情页（点击协议后打开的内置网页）导航栏。iOS 无独立 web 字号，复用 privacyNav* 系列。
    UIColor *webNavColor = [self colorFromHex:config[@"webNavColor"]];
    if (webNavColor) model.privacyNavColor = webNavColor;
    UIColor *webNavTextColor = [self colorFromHex:config[@"webNavTextColor"]];
    if (webNavTextColor) model.privacyNavTitleColor = webNavTextColor;
    if ([config[@"webNavTextSize"] respondsToSelector:@selector(doubleValue)]) {
        model.privacyNavTitleFont = [UIFont systemFontOfSize:[config[@"webNavTextSize"] doubleValue]];
    }
    UIImage *webNavBackImg = [self imageNamed:config[@"webNavReturnImage"]];
    if (webNavBackImg) model.privacyNavBackImage = webNavBackImg;

    // Logo
    UIImage *logoImg = [self imageNamed:config[@"logoImage"]];
    if (logoImg) model.logoImage = logoImg;
    if ([config[@"logoHidden"] respondsToSelector:@selector(boolValue)]) {
        model.logoIsHidden = [config[@"logoHidden"] boolValue];
    }

    // Slogan
    NSString *sloganText = config[@"sloganText"];
    UIColor *sloganColor = [self colorFromHex:config[@"sloganTextColor"]] ?: [UIColor lightGrayColor];
    CGFloat sloganTextSize = 13.0;
    if ([config[@"sloganTextSize"] respondsToSelector:@selector(doubleValue)]) {
        sloganTextSize = [config[@"sloganTextSize"] doubleValue];
    }
    if ([sloganText isKindOfClass:[NSString class]] && sloganText.length > 0) {
        model.sloganText = [[NSAttributedString alloc] initWithString:sloganText
                                                           attributes:@{NSForegroundColorAttributeName: sloganColor,
                                                                        NSFontAttributeName: [UIFont systemFontOfSize:sloganTextSize]}];
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
    CGFloat logBtnTextSize = 16.0;
    if ([config[@"logBtnTextSize"] respondsToSelector:@selector(doubleValue)]) {
        logBtnTextSize = [config[@"logBtnTextSize"] doubleValue];
    }
    if ([logBtnText isKindOfClass:[NSString class]] && logBtnText.length > 0) {
        model.loginBtnText = [[NSAttributedString alloc] initWithString:logBtnText
                                                             attributes:@{NSForegroundColorAttributeName: logBtnTextColor,
                                                                          NSFontAttributeName: [UIFont boldSystemFontOfSize:logBtnTextSize]}];
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
        NSMutableDictionary *switchAttrs =
            [@{NSForegroundColorAttributeName: switchAccColor} mutableCopy];
        if ([config[@"switchAccTextSize"] respondsToSelector:@selector(doubleValue)]) {
            switchAttrs[NSFontAttributeName] =
                [UIFont systemFontOfSize:[config[@"switchAccTextSize"] doubleValue]];
        }
        model.changeBtnTitle = [[NSAttributedString alloc] initWithString:switchAccText
                                                               attributes:switchAttrs];
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
    if ([config[@"checkboxHidden"] respondsToSelector:@selector(boolValue)]) {
        model.checkBoxIsHidden = [config[@"checkboxHidden"] boolValue];
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

    // 运营商协议名称前后缀（如《》）。SDK 限制：前缀仅支持 <([《（【『，后缀仅支持 >)]》）】』
    NSString *vendorPrefix = config[@"vendorPrivacyPrefix"];
    if ([vendorPrefix isKindOfClass:[NSString class]]) model.privacyOperatorPreText = vendorPrefix;
    NSString *vendorSuffix = config[@"vendorPrivacySuffix"];
    if ([vendorSuffix isKindOfClass:[NSString class]]) model.privacyOperatorSufText = vendorSuffix;

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
        model.contentViewFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
            CGFloat x = (screenSize.width - w) / 2 + offsetX;
            CGFloat y = (screenSize.height - h) / 2 + offsetY;
            return CGRectMake(x, y, w, h);
        };
        // 弹窗标题栏 / 右上角关闭按钮（仅弹窗模式，iOS 端能力，Android 端无对应）
        if ([config[@"dialogBarHidden"] respondsToSelector:@selector(boolValue)]) {
            model.alertBarIsHidden = [config[@"dialogBarHidden"] boolValue];
        }
        UIImage *dialogClose = [self imageNamed:config[@"dialogCloseImage"]];
        if (dialogClose) {
            model.alertCloseImage = dialogClose;
            model.alertCloseItemIsHidden = NO;
        }
    }

    // 各控件 Y 轴偏移 / Logo 尺寸：新版 SDK 推荐用 *FrameBlock，但旧的 *OffetY / logoWidth 仍然有效，
    // 这里沿用旧 onepass 的偏移语义，集中处理并屏蔽弃用告警。单位 pt。<=0 不生效（见头文件说明）。
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([config[@"logoWidth"] respondsToSelector:@selector(doubleValue)])
        model.logoWidth = [config[@"logoWidth"] doubleValue];
    if ([config[@"logoHeight"] respondsToSelector:@selector(doubleValue)])
        model.logoHeight = [config[@"logoHeight"] doubleValue];
    if ([config[@"logoOffsetY"] respondsToSelector:@selector(doubleValue)])
        model.logoTopOffetY = [config[@"logoOffsetY"] doubleValue];
    if ([config[@"sloganOffsetY"] respondsToSelector:@selector(doubleValue)])
        model.sloganTopOffetY = [config[@"sloganOffsetY"] doubleValue];
    if ([config[@"numberFieldOffsetY"] respondsToSelector:@selector(doubleValue)])
        model.numberTopOffetY = [config[@"numberFieldOffsetY"] doubleValue];
    if ([config[@"logBtnOffsetY"] respondsToSelector:@selector(doubleValue)])
        model.loginBtnTopOffetY = [config[@"logBtnOffsetY"] doubleValue];
    if ([config[@"switchOffsetY"] respondsToSelector:@selector(doubleValue)])
        model.changeBtnTopOffetY = [config[@"switchOffsetY"] doubleValue];
    if ([config[@"privacyBottomOffsetY"] respondsToSelector:@selector(doubleValue)])
        model.privacyBottomOffetY = [config[@"privacyBottomOffsetY"] doubleValue];
#pragma clang diagnostic pop

    // 隐私二次弹窗
    if ([config[@"privacyAlertIsNeed"] respondsToSelector:@selector(boolValue)]) {
        model.privacyAlertIsNeedShow = [config[@"privacyAlertIsNeed"] boolValue];
    }

    // 二次弹窗尺寸 / 样式（不设置时 SDK 默认高仅 200pt，协议较长会被撑变形）
    BOOL hasAlertW = [config[@"privacyAlertWidth"] respondsToSelector:@selector(doubleValue)];
    BOOL hasAlertH = [config[@"privacyAlertHeight"] respondsToSelector:@selector(doubleValue)];
    if (hasAlertW || hasAlertH) {
        CGFloat aw = hasAlertW ? [config[@"privacyAlertWidth"] doubleValue] : 0;
        CGFloat ah = hasAlertH ? [config[@"privacyAlertHeight"] doubleValue] : 0;
        CGFloat aox = [config[@"privacyAlertOffsetX"] respondsToSelector:@selector(doubleValue)]
            ? [config[@"privacyAlertOffsetX"] doubleValue] : 0;
        CGFloat aoy = [config[@"privacyAlertOffsetY"] respondsToSelector:@selector(doubleValue)]
            ? [config[@"privacyAlertOffsetY"] doubleValue] : 0;
        model.privacyAlertFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
            CGFloat w = aw > 0 ? aw : frame.size.width;
            CGFloat h = ah > 0 ? ah : frame.size.height;
            CGFloat x = (screenSize.width - w) / 2 + aox;
            CGFloat y = (screenSize.height - h) / 2 + aoy;
            return CGRectMake(x, y, w, h);
        };
    }
    if ([config[@"privacyAlertCornerRadius"] respondsToSelector:@selector(doubleValue)]) {
        NSNumber *r = @([config[@"privacyAlertCornerRadius"] doubleValue]);
        model.privacyAlertCornerRadiusArray = @[r, r, r, r];
    }
    NSString *alertTitle = config[@"privacyAlertTitle"];
    if ([alertTitle isKindOfClass:[NSString class]]) model.privacyAlertTitleContent = alertTitle;
    NSString *alertBtnText = config[@"privacyAlertBtnText"];
    if ([alertBtnText isKindOfClass:[NSString class]]) model.privacyAlertBtnContent = alertBtnText;
    NSArray *alertContentColors = config[@"privacyAlertContentColors"];
    if ([alertContentColors isKindOfClass:[NSArray class]] && alertContentColors.count >= 2) {
        UIColor *base = [self colorFromHex:alertContentColors[0]] ?: [UIColor grayColor];
        UIColor *clk = [self colorFromHex:alertContentColors[1]] ?: [UIColor blueColor];
        model.privacyAlertContentColors = @[base, clk];
    }
    if ([config[@"privacyAlertCloseHidden"] respondsToSelector:@selector(boolValue)]) {
        model.privacyAlertCloseButtonIsNeedShow = ![config[@"privacyAlertCloseHidden"] boolValue];
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
