import { AuthPageEventResponse } from './typing';
/**
 * 监听授权页生命周期事件（点击返回、点击切换、点击复选框、点击协议等）。
 * 仅在一键登录授权页展示期间触发；自动在卸载时移除监听。
 */
export declare const useAuthPageEvent: (handler: (response: AuthPageEventResponse) => void) => void;
