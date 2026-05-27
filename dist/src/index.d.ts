import { AuthType, AuthPageEventResponse, AuthUIConfig, CheckEnvResponse, LoginTokenResponse, SetAuthSDKInfoResponse, AccelerateResponse, VerifyTokenResponse } from './typing';
export * from './typing';
export * from './hooks';
/**
 * 销毁本组件内全局事件桥（一般无需调用，热更/卸载时使用）。
 */
export declare const teardown: () => void;
/**
 * 获取 SDK 版本号。
 */
export declare const getVersion: () => Promise<string>;
/**
 * 设置阿里云号码认证 SDK 秘钥信息。
 * 建议在 App 启动时调用一次（重复调用以最新 info 为准）。
 *
 * @param info 阿里云控制台获取的秘钥串
 */
export declare const setAuthSDKInfo: (info: string) => Promise<SetAuthSDKInfoResponse>;
/**
 * 检查当前环境是否支持一键登录 / 本机号码校验。
 * 成功 (code=600000) 之后才能调用 getLoginToken / getVerifyToken。
 */
export declare const checkEnvAvailable: (authType?: AuthType) => Promise<CheckEnvResponse>;
/**
 * 预取号 / 加速授权页弹起。建议在拉起授权页前一两秒调用。
 */
export declare const accelerateLoginPage: (timeout?: number) => Promise<AccelerateResponse>;
/**
 * 加速本机号码校验。
 */
export declare const accelerateVerify: (timeout?: number) => Promise<AccelerateResponse>;
/**
 * 拉起一键登录授权页并获取 token。
 * 成功回调 code=600000 时 data.token 有值；
 * 授权页事件（点击返回 / 切换 / 协议等）通过 useAuthPageEvent 或 addAuthPageListener 监听。
 */
export declare const getLoginToken: (options?: {
    timeout?: number;
    uiConfig?: AuthUIConfig;
}) => Promise<LoginTokenResponse>;
/**
 * 本机号码校验：获取 verifyToken（业务侧使用该 token 调用服务端验证手机号）。
 */
export declare const getVerifyToken: (timeout?: number) => Promise<VerifyTokenResponse>;
/**
 * 注销/关闭授权页。
 * @param animated 是否动画退出
 */
export declare const quitLoginPage: (animated?: boolean) => Promise<void>;
/**
 * 手动隐藏一键登录获取 token 后的等待 loading（autoHideLoginLoading=NO 时使用）。
 */
export declare const hideLoginLoading: () => Promise<void>;
/**
 * 修改授权页协议复选框选中状态。
 */
export declare const setCheckboxIsChecked: (isChecked: boolean) => Promise<void>;
/**
 * 查询授权页协议复选框当前状态。
 */
export declare const queryCheckBoxIsChecked: () => Promise<boolean>;
/**
 * 设置 SDK 日志开关（仅在 debug 阶段开启，正式发布前请关闭）。
 */
export declare const setLoggerEnable: (enable: boolean) => Promise<void>;
/**
 * 监听授权页事件：返回 / 切换 / 复选框 / 协议点击等。
 * 推荐在 React 组件内使用 useAuthPageEvent；这里给非 hook 场景的入口。
 */
export declare const addAuthPageListener: (handler: (response: AuthPageEventResponse) => void) => void;
export declare const removeAuthPageListener: (handler: (response: AuthPageEventResponse) => void) => void;
