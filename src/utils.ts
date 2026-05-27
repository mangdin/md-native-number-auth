import {NumberAuthResponse} from './typing';

/**
 * 把 callback 风格的原生方法包装成 Promise。
 * 原生侧调用 callback(err, res)：err 非空时 reject，否则 resolve。
 */
export const promisifyNativeFunction = <T = NumberAuthResponse>(fn: Function) => {
  return (...args: any[]) => {
    return new Promise<T>((resolve, reject) => {
      fn(...args, (err: any, res: T) => {
        err ? reject(res ?? err) : resolve(res);
      });
    });
  };
};
