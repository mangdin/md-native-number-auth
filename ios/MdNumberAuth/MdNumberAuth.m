#import "MdNumberAuth.h"
#import "MdNumberAuthUIHelper.h"
#import <ATAuthSDK/ATAuthSDK.h>

static NSString * const kEventName = @"MdNumberAuth_Event";

@interface MdNumberAuth ()
@property (nonatomic, assign) BOOL hasListeners;
@property (nonatomic, assign) BOOL loginCallbackInvoked;
@end

@implementation MdNumberAuth

RCT_EXPORT_MODULE(MdNumberAuth)

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents {
    return @[kEventName];
}

- (void)startObserving { self.hasListeners = YES; }
- (void)stopObserving  { self.hasListeners = NO;  }

#pragma mark - helpers

- (NSDictionary *)wrapResp:(NSString *)type result:(NSDictionary *)resultDic {
    NSString *code = resultDic[@"resultCode"] ?: @"";
    NSString *msg  = resultDic[@"msg"] ?: @"";
    NSString *token = resultDic[@"token"];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (token) data[@"token"] = token;
    if (resultDic[@"isChecked"]) data[@"isChecked"] = resultDic[@"isChecked"];
    if (resultDic[@"url"])       data[@"url"]       = resultDic[@"url"];
    if (resultDic[@"urlName"])   data[@"urlName"]   = resultDic[@"urlName"];

    NSString *raw = @"";
    if ([NSJSONSerialization isValidJSONObject:resultDic]) {
        NSData *d = [NSJSONSerialization dataWithJSONObject:resultDic options:0 error:nil];
        if (d) raw = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] ?: @"";
    }

    return @{
        @"type": type ?: @"",
        @"code": code,
        @"msg": msg,
        @"raw": raw,
        @"data": data,
    };
}

- (BOOL)isPageEventCode:(NSString *)code {
    return [code isEqualToString:PNSCodeLoginControllerPresentSuccess]    // 600001
        || [code isEqualToString:PNSCodeLoginControllerPresentFailed]      // 600002
        || [code isEqualToString:PNSCodeLoginControllerClickCancel]        // 700000
        || [code isEqualToString:PNSCodeLoginControllerClickChangeBtn]     // 700001
        || [code isEqualToString:PNSCodeLoginControllerClickLoginBtn]      // 700002
        || [code isEqualToString:PNSCodeLoginControllerClickCheckBoxBtn]   // 700003
        || [code isEqualToString:PNSCodeLoginControllerClickProtocol]      // 700004
        || [code isEqualToString:PNSCodeLoginClickPrivacyAlertView]        // 700006
        || [code isEqualToString:PNSCodeLoginPrivacyAlertViewClose]        // 700007
        || [code isEqualToString:PNSCodeLoginPrivacyAlertViewClickContinue]// 700008
        || [code isEqualToString:PNSCodeLoginPrivacyAlertViewPrivacyContentClick] // 700009
        || [code isEqualToString:PNSCodeLoginControllerSuspendDisMissVC]   // 700010
        || [code isEqualToString:PNSCodeLoginControllerDeallocVC];          // 700020
}

- (UIViewController *)topmostController {
    UIViewController *root = nil;
    UIWindow *keyWindow = nil;
    NSArray *windows = UIApplication.sharedApplication.windows;
    for (UIWindow *w in windows) {
        if (w.isKeyWindow) { keyWindow = w; break; }
    }
    if (!keyWindow) keyWindow = windows.firstObject;
    root = keyWindow.rootViewController;
    while (root.presentedViewController) {
        root = root.presentedViewController;
    }
    return root;
}

#pragma mark - exported methods

RCT_EXPORT_METHOD(getVersion:(RCTResponseSenderBlock)callback) {
    NSString *v = [[TXCommonHandler sharedInstance] getVersion] ?: @"";
    callback(@[[NSNull null], v]);
}

RCT_EXPORT_METHOD(setAuthSDKInfo:(NSString *)info
                  callback:(RCTResponseSenderBlock)callback)
{
    [[TXCommonHandler sharedInstance] setAuthSDKInfo:info
                                            complete:^(NSDictionary * _Nonnull resultDic) {
        NSDictionary *resp = [self wrapResp:@"setAuthSDKInfo" result:resultDic];
        NSString *code = resultDic[@"resultCode"] ?: @"";
        if ([code isEqualToString:PNSCodeSuccess]) {
            callback(@[[NSNull null], resp]);
        } else {
            callback(@[resp, [NSNull null]]);
        }
    }];
}

RCT_EXPORT_METHOD(checkEnvAvailable:(NSInteger)authType
                  callback:(RCTResponseSenderBlock)callback)
{
    PNSAuthType type = (authType == 1) ? PNSAuthTypeVerifyToken : PNSAuthTypeLoginToken;
    [[TXCommonHandler sharedInstance] checkEnvAvailableWithAuthType:type
                                                           complete:^(NSDictionary * _Nullable resultDic) {
        NSDictionary *resp = [self wrapResp:@"checkEnvAvailable" result:resultDic ?: @{}];
        NSString *code = resultDic[@"resultCode"] ?: @"";
        if ([code isEqualToString:PNSCodeSuccess]) {
            callback(@[[NSNull null], resp]);
        } else {
            callback(@[resp, [NSNull null]]);
        }
    }];
}

RCT_EXPORT_METHOD(accelerateLoginPage:(double)timeout
                  callback:(RCTResponseSenderBlock)callback)
{
    [[TXCommonHandler sharedInstance] accelerateLoginPageWithTimeout:timeout
                                                            complete:^(NSDictionary * _Nonnull resultDic) {
        NSDictionary *resp = [self wrapResp:@"accelerateLoginPage" result:resultDic];
        NSString *code = resultDic[@"resultCode"] ?: @"";
        if ([code isEqualToString:PNSCodeSuccess]) {
            callback(@[[NSNull null], resp]);
        } else {
            callback(@[resp, [NSNull null]]);
        }
    }];
}

RCT_EXPORT_METHOD(accelerateVerify:(double)timeout
                  callback:(RCTResponseSenderBlock)callback)
{
    [[TXCommonHandler sharedInstance] accelerateVerifyWithTimeout:timeout
                                                         complete:^(NSDictionary * _Nonnull resultDic) {
        NSDictionary *resp = [self wrapResp:@"accelerateVerify" result:resultDic];
        NSString *code = resultDic[@"resultCode"] ?: @"";
        if ([code isEqualToString:PNSCodeSuccess]) {
            callback(@[[NSNull null], resp]);
        } else {
            callback(@[resp, [NSNull null]]);
        }
    }];
}

RCT_EXPORT_METHOD(getLoginToken:(double)timeout
                  uiConfig:(NSDictionary *)uiConfig
                  callback:(RCTResponseSenderBlock)callback)
{
    self.loginCallbackInvoked = NO;
    __block RCTResponseSenderBlock cb = [callback copy];
    __weak typeof(self) weakSelf = self;

    TXCustomModel *model = [MdNumberAuthUIHelper buildModelFromConfig:uiConfig];

    UIViewController *controller = [self topmostController];
    if (!controller) {
        NSDictionary *resp = [self wrapResp:@"getLoginToken"
                                     result:@{@"resultCode": @"600002", @"msg": @"no root view controller"}];
        callback(@[resp, [NSNull null]]);
        return;
    }

    [[TXCommonHandler sharedInstance] getLoginTokenWithTimeout:timeout
                                                    controller:controller
                                                         model:model
                                                      complete:^(NSDictionary * _Nonnull resultDic) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        NSString *code = resultDic[@"resultCode"] ?: @"";
        NSDictionary *resp = [strongSelf wrapResp:@"getLoginToken" result:resultDic];

        // 真实成功 -> 拿到 token
        if ([code isEqualToString:PNSCodeSuccess]) {
            if (!strongSelf.loginCallbackInvoked && cb) {
                strongSelf.loginCallbackInvoked = YES;
                cb(@[[NSNull null], resp]);
                cb = nil;
            }
            return;
        }

        // 授权页相关事件：单独通过 event 派发
        if ([strongSelf isPageEventCode:code]) {
            NSDictionary *event = [strongSelf wrapResp:@"authPageEvent" result:resultDic];
            if (strongSelf.hasListeners) {
                [strongSelf sendEventWithName:kEventName body:event];
            }

            // 用户取消 / 点击切换 / 授权页拉起失败 -> 同时回调失败一次
            if (([code isEqualToString:PNSCodeLoginControllerClickCancel]
                 || [code isEqualToString:PNSCodeLoginControllerClickChangeBtn]
                 || [code isEqualToString:PNSCodeLoginControllerPresentFailed])
                && !strongSelf.loginCallbackInvoked && cb) {
                strongSelf.loginCallbackInvoked = YES;
                cb(@[resp, [NSNull null]]);
                cb = nil;
            }
            return;
        }

        // 其它失败（超时、运营商错误等）
        if (!strongSelf.loginCallbackInvoked && cb) {
            strongSelf.loginCallbackInvoked = YES;
            cb(@[resp, [NSNull null]]);
            cb = nil;
        }
    }];
}

RCT_EXPORT_METHOD(getVerifyToken:(double)timeout
                  callback:(RCTResponseSenderBlock)callback)
{
    [[TXCommonHandler sharedInstance] getVerifyTokenWithTimeout:timeout
                                                       complete:^(NSDictionary * _Nonnull resultDic) {
        NSDictionary *resp = [self wrapResp:@"getVerifyToken" result:resultDic];
        NSString *code = resultDic[@"resultCode"] ?: @"";
        if ([code isEqualToString:PNSCodeSuccess]) {
            callback(@[[NSNull null], resp]);
        } else {
            callback(@[resp, [NSNull null]]);
        }
    }];
}

RCT_EXPORT_METHOD(quitLoginPage:(BOOL)animated
                  callback:(RCTResponseSenderBlock)callback)
{
    [[TXCommonHandler sharedInstance] cancelLoginVCAnimated:animated complete:^{
        callback(@[[NSNull null], [NSNull null]]);
    }];
}

RCT_EXPORT_METHOD(hideLoginLoading:(RCTResponseSenderBlock)callback) {
    [[TXCommonHandler sharedInstance] hideLoginLoading];
    callback(@[[NSNull null], [NSNull null]]);
}

RCT_EXPORT_METHOD(setCheckboxIsChecked:(BOOL)isChecked
                  callback:(RCTResponseSenderBlock)callback)
{
    [[TXCommonHandler sharedInstance] setCheckboxIsChecked:isChecked];
    callback(@[[NSNull null], [NSNull null]]);
}

RCT_EXPORT_METHOD(queryCheckBoxIsChecked:(RCTResponseSenderBlock)callback) {
    BOOL checked = [[TXCommonHandler sharedInstance] queryCheckBoxIsChecked];
    callback(@[[NSNull null], @(checked)]);
}

RCT_EXPORT_METHOD(setLoggerEnable:(BOOL)enable
                  callback:(RCTResponseSenderBlock)callback)
{
    [[[TXCommonHandler sharedInstance] getReporter] setConsolePrintLoggerEnable:enable];
    callback(@[[NSNull null], [NSNull null]]);
}

@end
