/**
 * 一键登录 / 本机号码校验 类型。
 */
export var AuthType;
(function (AuthType) {
    /** 本机号码校验 */
    AuthType[AuthType["VerifyToken"] = 1] = "VerifyToken";
    /** 一键登录 */
    AuthType[AuthType["LoginToken"] = 2] = "LoginToken";
})(AuthType || (AuthType = {}));
