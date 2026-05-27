/**
 * 把 callback 风格的原生方法包装成 Promise。
 * 原生侧调用 callback(err, res)：err 非空时 reject，否则 resolve。
 */
export const promisifyNativeFunction = (fn) => {
    return (...args) => {
        return new Promise((resolve, reject) => {
            fn(...args, (err, res) => {
                err ? reject(res !== null && res !== void 0 ? res : err) : resolve(res);
            });
        });
    };
};
