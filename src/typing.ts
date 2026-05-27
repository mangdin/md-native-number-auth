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
export enum AuthType {
  /** 本机号码校验 */
  VerifyToken = 1,
  /** 一键登录 */
  LoginToken = 2,
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
  /** 状态栏文字深色 (true=深色文字/浅色背景) */
  lightColor?: boolean;

  /** logo 资源名（需在原生工程 assets / Images.xcassets 中已存在），不传则使用 SDK 默认 logo */
  logoImage?: string;
  /** 是否隐藏 logo */
  logoHidden?: boolean;

  /** slogan 文案（顶部认证服务字样） */
  sloganText?: string;
  /** slogan 文字颜色 */
  sloganTextColor?: string;
  /** 是否隐藏 slogan */
  sloganHidden?: boolean;

  /** 手机号码字段文字颜色 */
  numberColor?: string;
  /** 手机号码字段字号 */
  numberSize?: number;

  /** 登录按钮文案 */
  logBtnText?: string;
  /** 登录按钮文字颜色 */
  logBtnTextColor?: string;
  /** 登录按钮背景图（资源名），不传则使用默认背景色 */
  logBtnBackgroundImage?: string;
  /** 登录按钮背景色（在未提供 logBtnBackgroundImage 时生效） */
  logBtnBackgroundColor?: string;

  /** 切换按钮文案（"其他方式登录"） */
  switchAccText?: string;
  /** 切换按钮文字颜色 */
  switchAccTextColor?: string;
  /** 是否隐藏切换按钮 */
  switchAccHidden?: boolean;

  /** 协议复选框是否默认勾选 */
  checkboxIsChecked?: boolean;
  /** 协议复选框是否隐藏 */
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

  /** 隐私协议二次弹窗 */
  privacyAlertIsNeed?: boolean;
};

export type SendAuthEventName =
  | 'SetAuthSDKInfoResp'
  | 'CheckEnvAvailableResp'
  | 'AccelerateLoginResp'
  | 'AccelerateVerifyResp'
  | 'GetLoginTokenResp'
  | 'GetVerifyTokenResp'
  | 'AuthPageEvent';
