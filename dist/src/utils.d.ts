import { NumberAuthResponse } from './typing';
/**
 * 把 callback 风格的原生方法包装成 Promise。
 * 原生侧调用 callback(err, res)：err 非空时 reject，否则 resolve。
 */
export declare const promisifyNativeFunction: <T = NumberAuthResponse<import("./typing").Recordable<any>>>(fn: Function) => (...args: any[]) => Promise<T>;
