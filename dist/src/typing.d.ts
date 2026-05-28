export type Recordable<T = any> = Record<string, T>;
/**
 * 阿里云号码认证 SDK 返回的通用结果。
 * iOS 上结构体一致；Android 上 TokenRet JSON 会被原样解析。
 * 错误码请参考 PNSReturnCode（iOS）/ ResultCode（Android）。
 */
export type NumberAuthResponse<T = Recordable> = {
    /** 事件类型，如：setAuthSDKInfo / checkEnvAvailable / getLoginToken / verifyToken / authPageEvent */
    type: string;
    /** 阿里云返回码，例如 600000 / 600001 / 700000 等 */
    code: string;
    /** 提示信息 */
    msg?: string;
    /** SDK 原始 JSON 字符串（一般等于平台原始返回） */
    raw?: string;
    /** 透传字段：token、isChecked、url、urlName 等 */
    data?: T;
};
export type SetAuthSDKInfoResponse = NumberAuthResponse<{}>;
export type CheckEnvResponse = NumberAuthResponse<{}>;
export type AccelerateResponse = NumberAuthResponse<{}>;
export type LoginTokenResponse = NumberAuthResponse<{
    /** 获取到的临时 token，用于服务端换取手机号 */
    token?: string;
    /** 授权页协议复选框状态 */
    isChecked?: boolean;
    /** 协议富文本点击时回传的协议链接 */
    url?: string;
    /** 协议富文本点击时回传的协议名 */
    urlName?: string;
}>;
export type VerifyTokenResponse = NumberAuthResponse<{
    token?: string;
}>;
export type AuthPageEventResponse = NumberAuthResponse<{
    isChecked?: boolean;
    url?: string;
    urlName?: string;
}>;
/**
 * 一键登录 / 本机号码校验 类型。
 */
export declare enum AuthType {
    /** 本机号码校验 */
    VerifyToken = 1,
    /** 一键登录 */
    LoginToken = 2
}
/**
 * 授权页自定义配置（跨平台子集，覆盖最常用的样式项）。
 * iOS 对应 TXCustomModel；Android 对应 AuthUIConfig。
 * 颜色统一使用 #RRGGBB / #AARRGGBB 字符串；尺寸单位 dp（Android）/ pt（iOS）。
 */
export type AuthUIConfig = {
    /** 导航栏背景色 */
    navColor?: string;
    /** 导航栏标题 */
    navText?: string;
    /** 导航栏标题颜色 */
    navTextColor?: string;
    /** 是否隐藏导航栏 */
    navHidden?: boolean;
    /** 是否隐藏导航栏返回按钮 */
    navReturnHidden?: boolean;
    /** 导航栏标题字号 */
    navTextSize?: number;
    /** 导航栏返回按钮图片（资源名） */
    navReturnImage?: string;
    /** 状态栏文字深色 (true=深色文字/浅色背景) */
    lightColor?: boolean;
    /** 状态栏背景色（仅 Android 生效，iOS 不支持设置状态栏背景） */
    statusBarColor?: string;
    /** 是否隐藏状态栏 */
    statusBarHidden?: boolean;
    /** 协议详情页（点击协议后打开的内置网页）导航栏背景色 */
    webNavColor?: string;
    /** 协议详情页导航栏标题颜色 */
    webNavTextColor?: string;
    /** 协议详情页导航栏标题字号 */
    webNavTextSize?: number;
    /** 协议详情页导航栏返回按钮图片（资源名） */
    webNavReturnImage?: string;
    /** logo 资源名（需在原生工程 assets / Images.xcassets 中已存在），不传则使用 SDK 默认 logo */
    logoImage?: string;
    /** 是否隐藏 logo */
    logoHidden?: boolean;
    /** logo 宽度（Android: px / iOS: pt；iOS 走已废弃但仍有效的属性） */
    logoWidth?: number;
    /** logo 高度（Android: px / iOS: pt） */
    logoHeight?: number;
    /** logo 相对导航栏底部的 Y 轴偏移（Android: px / iOS: pt，<=0 不生效） */
    logoOffsetY?: number;
    /** slogan 文案（顶部认证服务字样） */
    sloganText?: string;
    /** slogan 文字颜色 */
    sloganTextColor?: string;
    /** 是否隐藏 slogan */
    sloganHidden?: boolean;
    /** slogan 字号 */
    sloganTextSize?: number;
    /** slogan 相对导航栏底部的 Y 轴偏移（Android: px / iOS: pt，<=0 不生效） */
    sloganOffsetY?: number;
    /** 手机号码字段文字颜色 */
    numberColor?: string;
    /** 手机号码字段字号 */
    numberSize?: number;
    /** 手机号码字段相对导航栏底部的 Y 轴偏移（Android: px / iOS: pt，<=0 不生效） */
    numberFieldOffsetY?: number;
    /** 登录按钮文案 */
    logBtnText?: string;
    /** 登录按钮文字颜色 */
    logBtnTextColor?: string;
    /** 登录按钮背景图（资源名），不传则使用默认背景色 */
    logBtnBackgroundImage?: string;
    /** 登录按钮背景色（在未提供 logBtnBackgroundImage 时生效） */
    logBtnBackgroundColor?: string;
    /** 登录按钮文字字号 */
    logBtnTextSize?: number;
    /** 登录按钮相对导航栏底部的 Y 轴偏移（Android: px / iOS: pt，<=0 不生效） */
    logBtnOffsetY?: number;
    /** 切换按钮文案（"其他方式登录"） */
    switchAccText?: string;
    /** 切换按钮文字颜色 */
    switchAccTextColor?: string;
    /** 是否隐藏切换按钮 */
    switchAccHidden?: boolean;
    /** 切换按钮文字字号 */
    switchAccTextSize?: number;
    /** 切换按钮相对导航栏底部的 Y 轴偏移（Android: px / iOS: pt，<=0 不生效） */
    switchOffsetY?: number;
    /** 协议复选框是否默认勾选 */
    checkboxIsChecked?: boolean;
    /** 协议复选框是否隐藏（与 privacyState 等价，命名更清晰，推荐用此项） */
    checkboxHidden?: boolean;
    /** @deprecated 协议复选框是否隐藏（历史命名，建议改用 checkboxHidden） */
    privacyState?: boolean;
    /** 自定义协议数组：每一项 [协议名, 协议链接] */
    privacyOne?: [string, string];
    privacyTwo?: [string, string];
    privacyThree?: [string, string];
    /** 协议前后缀文案 */
    privacyPrefix?: string;
    /** 协议结尾 */
    privacyEnd?: string;
    /** 协议字体颜色：[未选中色, 选中色] */
    privacyColors?: [string, string];
    /** 协议字号 */
    privacySize?: number;
    /** 运营商协议名称前缀，仅支持 <([《（【『 */
    vendorPrivacyPrefix?: string;
    /** 运营商协议名称后缀，仅支持 >)]》）】』 */
    vendorPrivacySuffix?: string;
    /** 协议整体相对屏幕底部的 Y 轴偏移（Android: px / iOS: pt，不能 <0） */
    privacyBottomOffsetY?: number;
    /** 授权页是否使用窗口模式（弹窗） */
    dialogMode?: boolean;
    /** 弹窗模式：宽（dp/pt） */
    dialogWidth?: number;
    /** 弹窗模式：高（dp/pt） */
    dialogHeight?: number;
    /** 弹窗模式：x 偏移 */
    dialogOffsetX?: number;
    /** 弹窗模式：y 偏移 */
    dialogOffsetY?: number;
    /** 弹窗模式：底部弹出（仅 Android 生效） */
    dialogBottom?: boolean;
    /** 弹窗模式：是否隐藏弹窗标题栏（仅 iOS 生效） */
    dialogBarHidden?: boolean;
    /** 弹窗模式：标题栏右上角关闭按钮图片（资源名，仅 iOS 生效） */
    dialogCloseImage?: string;
    /** 隐私协议二次弹窗：是否需要弹出 */
    privacyAlertIsNeed?: boolean;
    /** 二次弹窗宽度（Android: px / iOS: pt）。不设置时 SDK 默认尺寸偏小，协议长易变形 */
    privacyAlertWidth?: number;
    /** 二次弹窗高度（Android: px / iOS: pt）。iOS 默认仅 200，建议按内容设大 */
    privacyAlertHeight?: number;
    /** 二次弹窗相对屏幕中心的 X 偏移 */
    privacyAlertOffsetX?: number;
    /** 二次弹窗相对屏幕中心的 Y 偏移 */
    privacyAlertOffsetY?: number;
    /** 二次弹窗圆角（四角统一值） */
    privacyAlertCornerRadius?: number;
    /** 二次弹窗标题文案 */
    privacyAlertTitle?: string;
    /** 二次弹窗确认按钮文案 */
    privacyAlertBtnText?: string;
    /** 二次弹窗协议文字颜色：[非点击色, 点击色] */
    privacyAlertContentColors?: [string, string];
    /** 二次弹窗是否隐藏右上角关闭按钮 */
    privacyAlertCloseHidden?: boolean;
};
export type SendAuthEventName = 'SetAuthSDKInfoResp' | 'CheckEnvAvailableResp' | 'AccelerateLoginResp' | 'AccelerateVerifyResp' | 'GetLoginTokenResp' | 'GetVerifyTokenResp' | 'AuthPageEvent';
