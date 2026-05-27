import {NativeEventEmitter, EmitterSubscription} from 'react-native';
import Notification from './notification';
import {promisifyNativeFunction} from './utils';
import NativeModule from './NativeModule';
import {
  AuthType,
  AuthPageEventResponse,
  AuthUIConfig,
  CheckEnvResponse,
  LoginTokenResponse,
  NumberAuthResponse,
  SetAuthSDKInfoResponse,
  AccelerateResponse,
  VerifyTokenResponse,
} from './typing';

export * from './typing';
export * from './hooks';

const NATIVE_EVENT_NAME = 'MdNumberAuth_Event';

const notification = new Notification();

let initialized = false;
let emitter: NativeEventEmitter | null = null;
let nativeSubscription: EmitterSubscription | null = null;

const assertInitialized = (name: string) => {
  if (!initialized) {
    throw new Error(
      `[md-native-number-auth] Please call setAuthSDKInfo() before invoking ${name}().`,
    );
  }
};

const ensureEmitter = () => {
  if (!emitter) {
    emitter = new NativeEventEmitter(NativeModule);
  }
  if (!nativeSubscription) {
    nativeSubscription = emitter.addListener(
      NATIVE_EVENT_NAME,
      (response: NumberAuthResponse) => {
        notification.dispatch(response.type, response);
      },
    );
  }
};

/**
 * 销毁本组件内全局事件桥（一般无需调用，热更/卸载时使用）。
 */
export const teardown = () => {
  nativeSubscription?.remove();
  nativeSubscription = null;
  emitter = null;
  initialized = false;
};

/**
 * 获取 SDK 版本号。
 */
export const getVersion = (): Promise<string> => {
  const fn = promisifyNativeFunction<string>(NativeModule.getVersion);
  return fn();
};

/**
 * 设置阿里云号码认证 SDK 秘钥信息。
 * 建议在 App 启动时调用一次（重复调用以最新 info 为准）。
 *
 * @param info 阿里云控制台获取的秘钥串
 */
export const setAuthSDKInfo = (info: string): Promise<SetAuthSDKInfoResponse> => {
  ensureEmitter();
  const fn = promisifyNativeFunction<SetAuthSDKInfoResponse>(
    NativeModule.setAuthSDKInfo,
  );
  return fn(info).then(res => {
    initialized = true;
    return res;
  });
};

/**
 * 检查当前环境是否支持一键登录 / 本机号码校验。
 * 成功 (code=600000) 之后才能调用 getLoginToken / getVerifyToken。
 */
export const checkEnvAvailable = (
  authType: AuthType = AuthType.LoginToken,
): Promise<CheckEnvResponse> => {
  assertInitialized('checkEnvAvailable');
  const fn = promisifyNativeFunction<CheckEnvResponse>(
    NativeModule.checkEnvAvailable,
  );
  return fn(authType);
};

/**
 * 预取号 / 加速授权页弹起。建议在拉起授权页前一两秒调用。
 */
export const accelerateLoginPage = (
  timeout: number = 3.0,
): Promise<AccelerateResponse> => {
  assertInitialized('accelerateLoginPage');
  const fn = promisifyNativeFunction<AccelerateResponse>(
    NativeModule.accelerateLoginPage,
  );
  return fn(timeout);
};

/**
 * 加速本机号码校验。
 */
export const accelerateVerify = (
  timeout: number = 3.0,
): Promise<AccelerateResponse> => {
  assertInitialized('accelerateVerify');
  const fn = promisifyNativeFunction<AccelerateResponse>(
    NativeModule.accelerateVerify,
  );
  return fn(timeout);
};

/**
 * 拉起一键登录授权页并获取 token。
 * 成功回调 code=600000 时 data.token 有值；
 * 授权页事件（点击返回 / 切换 / 协议等）通过 useAuthPageEvent 或 addAuthPageListener 监听。
 */
export const getLoginToken = (
  options: {timeout?: number; uiConfig?: AuthUIConfig} = {},
): Promise<LoginTokenResponse> => {
  assertInitialized('getLoginToken');
  ensureEmitter();

  const timeout = options.timeout ?? 3.0;
  const uiConfig = options.uiConfig ?? {};

  const fn = promisifyNativeFunction<LoginTokenResponse>(
    NativeModule.getLoginToken,
  );

  return fn(timeout, uiConfig);
};

/**
 * 本机号码校验：获取 verifyToken（业务侧使用该 token 调用服务端验证手机号）。
 */
export const getVerifyToken = (
  timeout: number = 3.0,
): Promise<VerifyTokenResponse> => {
  assertInitialized('getVerifyToken');
  const fn = promisifyNativeFunction<VerifyTokenResponse>(
    NativeModule.getVerifyToken,
  );
  return fn(timeout);
};

/**
 * 注销/关闭授权页。
 * @param animated 是否动画退出
 */
export const quitLoginPage = (animated: boolean = true): Promise<void> => {
  const fn = promisifyNativeFunction<void>(NativeModule.quitLoginPage);
  return fn(animated);
};

/**
 * 手动隐藏一键登录获取 token 后的等待 loading（autoHideLoginLoading=NO 时使用）。
 */
export const hideLoginLoading = (): Promise<void> => {
  const fn = promisifyNativeFunction<void>(NativeModule.hideLoginLoading);
  return fn();
};

/**
 * 修改授权页协议复选框选中状态。
 */
export const setCheckboxIsChecked = (isChecked: boolean): Promise<void> => {
  const fn = promisifyNativeFunction<void>(NativeModule.setCheckboxIsChecked);
  return fn(isChecked);
};

/**
 * 查询授权页协议复选框当前状态。
 */
export const queryCheckBoxIsChecked = (): Promise<boolean> => {
  const fn = promisifyNativeFunction<boolean>(NativeModule.queryCheckBoxIsChecked);
  return fn();
};

/**
 * 设置 SDK 日志开关（仅在 debug 阶段开启，正式发布前请关闭）。
 */
export const setLoggerEnable = (enable: boolean): Promise<void> => {
  const fn = promisifyNativeFunction<void>(NativeModule.setLoggerEnable);
  return fn(enable);
};

/**
 * 监听授权页事件：返回 / 切换 / 复选框 / 协议点击等。
 * 推荐在 React 组件内使用 useAuthPageEvent；这里给非 hook 场景的入口。
 */
export const addAuthPageListener = (
  handler: (response: AuthPageEventResponse) => void,
) => {
  ensureEmitter();
  notification.listen('AuthPageEvent', handler);
};

export const removeAuthPageListener = (
  handler: (response: AuthPageEventResponse) => void,
) => {
  notification.off('AuthPageEvent', handler);
};
