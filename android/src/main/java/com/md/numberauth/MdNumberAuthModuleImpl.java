package com.md.numberauth;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import com.mobile.auth.gatewayauth.AuthUIConfig;
import com.mobile.auth.gatewayauth.AuthUIControlClickListener;
import com.mobile.auth.gatewayauth.PhoneNumberAuthHelper;
import com.mobile.auth.gatewayauth.PreLoginResultListener;
import com.mobile.auth.gatewayauth.ResultCode;
import com.mobile.auth.gatewayauth.TokenResultListener;
import com.mobile.auth.gatewayauth.model.TokenRet;

import org.json.JSONObject;

/**
 * 阿里云号码认证 SDK Android 端封装。
 *
 * 类型映射：
 *  - 一键登录：getLoginToken
 *  - 本机号码校验：getVerifyToken
 *  - 事件桥：通过 DeviceEventManagerModule 发送 "MdNumberAuth_Event"
 */
public class MdNumberAuthModuleImpl {

    private static final String TAG = "MdNumberAuth";
    private static final String EVENT_NAME = "MdNumberAuth_Event";

    private final ReactApplicationContext reactContext;
    private PhoneNumberAuthHelper authHelper;

    /** 正在进行中的一键登录回调；用于区分授权页事件与最终 token 结果。 */
    private Callback pendingLoginCallback;
    /** 是否已经把一键登录 callback 调过一次（callback 只能调用一次） */
    private boolean loginCallbackInvoked;
    /** 正在进行中的本机号码校验回调 */
    private Callback pendingVerifyCallback;
    private boolean verifyCallbackInvoked;

    MdNumberAuthModuleImpl(ReactApplicationContext context) {
        this.reactContext = context;
    }

    // -------------------- 基础 --------------------

    private PhoneNumberAuthHelper getHelper(TokenResultListener listener) {
        if (authHelper == null) {
            authHelper = PhoneNumberAuthHelper.getInstance(
                    reactContext.getApplicationContext(),
                    listener);
        } else if (listener != null) {
            authHelper.setAuthListener(listener);
        }
        return authHelper;
    }

    public void getVersion(Callback callback) {
        try {
            callback.invoke(null, PhoneNumberAuthHelper.getVersion());
        } catch (Throwable e) {
            callback.invoke(null, "2.14.22");
        }
    }

    // -------------------- 鉴权 --------------------

    public void setAuthSDKInfo(final String info, final Callback callback) {
        try {
            PhoneNumberAuthHelper helper = getHelper(null);
            helper.setAuthSDKInfo(info);
            // Android 端 setAuthSDKInfo 同步，无 complete 回调；直接返回成功。
            // 真正的鉴权失败会在 checkEnvAvailable / getLoginToken 阶段以 600017 等返回。
            callback.invoke(null,
                    buildSuccessResp("setAuthSDKInfo", ResultCode.CODE_SUCCESS, "set auth info success"));
        } catch (Throwable e) {
            callback.invoke(e.getMessage(), null);
        }
    }

    // -------------------- 环境检测 --------------------

    public void checkEnvAvailable(final int authType, final Callback callback) {
        try {
            TokenResultListener listener = new TokenResultListener() {
                @Override
                public void onTokenSuccess(String s) {
                    invokeCallbackOnce(callback, false,
                            buildResp("checkEnvAvailable", s));
                }

                @Override
                public void onTokenFailed(String s) {
                    invokeCallbackOnce(callback, true,
                            buildResp("checkEnvAvailable", s));
                }
            };
            PhoneNumberAuthHelper helper = getHelper(listener);
            helper.checkEnvAvailable(authType);
        } catch (Throwable e) {
            callback.invoke(e.getMessage(), null);
        }
    }

    // -------------------- 加速 --------------------

    public void accelerateLoginPage(final double timeout, final Callback callback) {
        try {
            final int timeoutMs = (int) (timeout * 1000);
            PhoneNumberAuthHelper helper = getHelper(null);
            helper.accelerateLoginPage(timeoutMs, new PreLoginResultListener() {
                @Override
                public void onTokenSuccess(String vendor) {
                    invokeCallbackOnce(callback, false,
                            buildSuccessResp("accelerateLoginPage",
                                    ResultCode.CODE_SUCCESS, vendor));
                }

                @Override
                public void onTokenFailed(String vendor, String msg) {
                    WritableMap resp = buildSuccessResp("accelerateLoginPage", "600011", msg);
                    invokeCallbackOnce(callback, true, resp);
                }
            });
        } catch (Throwable e) {
            callback.invoke(e.getMessage(), null);
        }
    }

    public void accelerateVerify(final double timeout, final Callback callback) {
        try {
            final int timeoutMs = (int) (timeout * 1000);
            PhoneNumberAuthHelper helper = getHelper(null);
            helper.accelerateVerify(timeoutMs, new PreLoginResultListener() {
                @Override
                public void onTokenSuccess(String vendor) {
                    invokeCallbackOnce(callback, false,
                            buildSuccessResp("accelerateVerify",
                                    ResultCode.CODE_SUCCESS, vendor));
                }

                @Override
                public void onTokenFailed(String vendor, String msg) {
                    invokeCallbackOnce(callback, true,
                            buildSuccessResp("accelerateVerify", "600011", msg));
                }
            });
        } catch (Throwable e) {
            callback.invoke(e.getMessage(), null);
        }
    }

    // -------------------- 一键登录 --------------------

    public void getLoginToken(final double timeout, final ReadableMap uiConfig, final Callback callback) {
        try {
            this.pendingLoginCallback = callback;
            this.loginCallbackInvoked = false;

            TokenResultListener listener = new TokenResultListener() {
                @Override
                public void onTokenSuccess(String s) {
                    TokenRet ret = parseRet(s);
                    String code = ret != null ? ret.getCode() : "";

                    if (ResultCode.CODE_START_AUTHPAGE_SUCCESS.equals(code)) {
                        // 授权页拉起成功 - 发事件
                        sendEvent(buildAuthPageEventResp("authPageEvent", s));
                        return;
                    }

                    if (ResultCode.CODE_SUCCESS.equals(code)) {
                        // 真实拿到 token
                        WritableMap resp = buildLoginTokenResp(s, ret);
                        invokeLoginCallbackOnce(false, resp);
                        return;
                    }

                    // 其他点击事件（700000 等）
                    sendEvent(buildAuthPageEventResp("authPageEvent", s));
                }

                @Override
                public void onTokenFailed(String s) {
                    TokenRet ret = parseRet(s);
                    String code = ret != null ? ret.getCode() : "";
                    // 用户取消等点击事件作为授权页事件抛出，但同时也回调失败
                    if (ResultCode.CODE_ERROR_USER_CANCEL.equals(code)
                            || ResultCode.CODE_ERROR_USER_SWITCH.equals(code)) {
                        sendEvent(buildAuthPageEventResp("authPageEvent", s));
                    }
                    WritableMap resp = buildLoginTokenResp(s, ret);
                    invokeLoginCallbackOnce(true, resp);
                }
            };

            PhoneNumberAuthHelper helper = getHelper(listener);

            // 应用 UI 配置
            if (uiConfig != null) {
                helper.setAuthUIConfig(buildAuthUIConfig(uiConfig));
            }

            // 授权页 UI 控件点击监听 (协议、复选框等)
            helper.setUIClickListener(new AuthUIControlClickListener() {
                @Override
                public void onClick(String code, android.content.Context context, String jsonString) {
                    WritableMap resp = Arguments.createMap();
                    resp.putString("type", "authPageEvent");
                    resp.putString("code", code != null ? code : "");
                    resp.putString("raw", jsonString != null ? jsonString : "");
                    resp.putMap("data", parseJsonToMap(jsonString));
                    sendEvent(resp);
                }
            });

            helper.getLoginToken(reactContext.getApplicationContext(), (int) (timeout * 1000));
        } catch (Throwable e) {
            this.pendingLoginCallback = null;
            callback.invoke(e.getMessage(), null);
        }
    }

    // -------------------- 本机号码校验 --------------------

    public void getVerifyToken(final double timeout, final Callback callback) {
        try {
            this.pendingVerifyCallback = callback;
            this.verifyCallbackInvoked = false;

            TokenResultListener listener = new TokenResultListener() {
                @Override
                public void onTokenSuccess(String s) {
                    WritableMap resp = buildResp("getVerifyToken", s);
                    invokeVerifyCallbackOnce(false, resp);
                }

                @Override
                public void onTokenFailed(String s) {
                    WritableMap resp = buildResp("getVerifyToken", s);
                    invokeVerifyCallbackOnce(true, resp);
                }
            };
            PhoneNumberAuthHelper helper = getHelper(listener);
            helper.getVerifyToken((int) (timeout * 1000));
        } catch (Throwable e) {
            this.pendingVerifyCallback = null;
            callback.invoke(e.getMessage(), null);
        }
    }

    // -------------------- 其他控制 API --------------------

    public void quitLoginPage(boolean animated, Callback callback) {
        try {
            if (authHelper != null) {
                authHelper.quitLoginPage();
                authHelper.setAuthListener(null);
            }
            callback.invoke(null, null);
        } catch (Throwable e) {
            callback.invoke(e.getMessage(), null);
        }
    }

    public void hideLoginLoading(Callback callback) {
        try {
            if (authHelper != null) {
                authHelper.hideLoginLoading();
            }
            callback.invoke(null, null);
        } catch (Throwable e) {
            callback.invoke(e.getMessage(), null);
        }
    }

    public void setCheckboxIsChecked(boolean isChecked, Callback callback) {
        try {
            if (authHelper != null) {
                authHelper.setProtocolChecked(isChecked);
            }
            callback.invoke(null, null);
        } catch (Throwable e) {
            callback.invoke(e.getMessage(), null);
        }
    }

    public void queryCheckBoxIsChecked(Callback callback) {
        try {
            boolean checked = authHelper != null && authHelper.queryCheckBoxIsChecked();
            callback.invoke(null, checked);
        } catch (Throwable e) {
            callback.invoke(e.getMessage(), null);
        }
    }

    public void setLoggerEnable(boolean enable, Callback callback) {
        try {
            PhoneNumberAuthHelper helper = getHelper(null);
            helper.getReporter().setLoggerEnable(enable);
            callback.invoke(null, null);
        } catch (Throwable e) {
            callback.invoke(e.getMessage(), null);
        }
    }

    // -------------------- helpers --------------------

    private TokenRet parseRet(String s) {
        try {
            return TokenRet.fromJson(s);
        } catch (Throwable e) {
            return null;
        }
    }

    private WritableMap buildResp(String type, String json) {
        TokenRet ret = parseRet(json);
        WritableMap map = Arguments.createMap();
        map.putString("type", type);
        map.putString("code", ret != null && ret.getCode() != null ? ret.getCode() : "");
        map.putString("msg", ret != null && ret.getMsg() != null ? ret.getMsg() : "");
        map.putString("raw", json != null ? json : "");
        WritableMap data = Arguments.createMap();
        if (ret != null && !TextUtils.isEmpty(ret.getToken())) {
            data.putString("token", ret.getToken());
        }
        map.putMap("data", data);
        return map;
    }

    private WritableMap buildLoginTokenResp(String json, @Nullable TokenRet ret) {
        WritableMap map = Arguments.createMap();
        map.putString("type", "getLoginToken");
        if (ret == null) {
            map.putString("code", "");
            map.putString("msg", "");
            map.putString("raw", json != null ? json : "");
            map.putMap("data", Arguments.createMap());
            return map;
        }
        map.putString("code", ret.getCode() != null ? ret.getCode() : "");
        map.putString("msg", ret.getMsg() != null ? ret.getMsg() : "");
        map.putString("raw", json != null ? json : "");
        WritableMap data = Arguments.createMap();
        if (!TextUtils.isEmpty(ret.getToken())) {
            data.putString("token", ret.getToken());
        }
        map.putMap("data", data);
        return map;
    }

    private WritableMap buildAuthPageEventResp(String type, String json) {
        TokenRet ret = parseRet(json);
        WritableMap map = Arguments.createMap();
        map.putString("type", type);
        map.putString("code", ret != null && ret.getCode() != null ? ret.getCode() : "");
        map.putString("msg", ret != null && ret.getMsg() != null ? ret.getMsg() : "");
        map.putString("raw", json != null ? json : "");
        map.putMap("data", parseJsonToMap(json));
        return map;
    }

    private WritableMap buildSuccessResp(String type, String code, String msg) {
        WritableMap map = Arguments.createMap();
        map.putString("type", type);
        map.putString("code", code != null ? code : "");
        map.putString("msg", msg != null ? msg : "");
        map.putString("raw", "");
        map.putMap("data", Arguments.createMap());
        return map;
    }

    private WritableMap parseJsonToMap(String s) {
        WritableMap map = Arguments.createMap();
        if (TextUtils.isEmpty(s)) {
            return map;
        }
        try {
            JSONObject obj = new JSONObject(s);
            java.util.Iterator<String> it = obj.keys();
            while (it.hasNext()) {
                String key = it.next();
                Object val = obj.opt(key);
                if (val == null) continue;
                if (val instanceof Boolean) {
                    map.putBoolean(key, (Boolean) val);
                } else if (val instanceof Integer) {
                    map.putInt(key, (Integer) val);
                } else if (val instanceof Double) {
                    map.putDouble(key, (Double) val);
                } else if (val instanceof Long) {
                    map.putDouble(key, ((Long) val).doubleValue());
                } else {
                    map.putString(key, val.toString());
                }
            }
        } catch (Throwable ignore) {
        }
        return map;
    }

    private void sendEvent(WritableMap body) {
        try {
            reactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(EVENT_NAME, body);
        } catch (Throwable e) {
            Log.w(TAG, "sendEvent failed: " + e.getMessage());
        }
    }

    private synchronized void invokeLoginCallbackOnce(boolean error, WritableMap resp) {
        if (loginCallbackInvoked || pendingLoginCallback == null) {
            return;
        }
        loginCallbackInvoked = true;
        Callback cb = pendingLoginCallback;
        pendingLoginCallback = null;
        if (error) {
            cb.invoke(resp, null);
        } else {
            cb.invoke(null, resp);
        }
    }

    private synchronized void invokeVerifyCallbackOnce(boolean error, WritableMap resp) {
        if (verifyCallbackInvoked || pendingVerifyCallback == null) {
            return;
        }
        verifyCallbackInvoked = true;
        Callback cb = pendingVerifyCallback;
        pendingVerifyCallback = null;
        if (error) {
            cb.invoke(resp, null);
        } else {
            cb.invoke(null, resp);
        }
    }

    private void invokeCallbackOnce(Callback cb, boolean error, WritableMap resp) {
        if (cb == null) return;
        try {
            if (error) {
                cb.invoke(resp, null);
            } else {
                cb.invoke(null, resp);
            }
        } catch (RuntimeException ignored) {
            // callback 已被调用过；忽略
        }
    }

    // -------------------- AuthUIConfig 构造 --------------------

    private int parseColor(String color, int fallback) {
        if (TextUtils.isEmpty(color)) return fallback;
        try {
            return Color.parseColor(color);
        } catch (Throwable e) {
            return fallback;
        }
    }

    private AuthUIConfig buildAuthUIConfig(ReadableMap c) {
        AuthUIConfig.Builder b = new AuthUIConfig.Builder();

        if (c.hasKey("navColor")) b.setNavColor(parseColor(c.getString("navColor"), Color.BLUE));
        if (c.hasKey("navText")) b.setNavText(c.getString("navText"));
        if (c.hasKey("navTextColor"))
            b.setNavTextColor(parseColor(c.getString("navTextColor"), Color.WHITE));
        if (c.hasKey("navHidden")) b.setNavHidden(c.getBoolean("navHidden"));
        if (c.hasKey("navReturnHidden")) b.setNavReturnHidden(c.getBoolean("navReturnHidden"));
        if (c.hasKey("lightColor")) b.setLightColor(c.getBoolean("lightColor"));

        if (c.hasKey("logoImage") && !TextUtils.isEmpty(c.getString("logoImage")))
            b.setLogoImgPath(c.getString("logoImage"));
        if (c.hasKey("logoHidden")) b.setLogoHidden(c.getBoolean("logoHidden"));

        if (c.hasKey("sloganText")) b.setSloganText(c.getString("sloganText"));
        if (c.hasKey("sloganTextColor"))
            b.setSloganTextColor(parseColor(c.getString("sloganTextColor"), Color.GRAY));
        if (c.hasKey("sloganHidden")) b.setSloganHidden(c.getBoolean("sloganHidden"));

        if (c.hasKey("numberColor"))
            b.setNumberColor(parseColor(c.getString("numberColor"), Color.BLACK));
        if (c.hasKey("numberSize")) b.setNumberSizeDp((int) c.getDouble("numberSize"));

        if (c.hasKey("logBtnText")) b.setLogBtnText(c.getString("logBtnText"));
        if (c.hasKey("logBtnTextColor"))
            b.setLogBtnTextColor(parseColor(c.getString("logBtnTextColor"), Color.WHITE));
        if (c.hasKey("logBtnBackgroundImage")
                && !TextUtils.isEmpty(c.getString("logBtnBackgroundImage"))) {
            b.setLogBtnBackgroundPath(c.getString("logBtnBackgroundImage"));
        } else if (c.hasKey("logBtnBackgroundColor")
                && !TextUtils.isEmpty(c.getString("logBtnBackgroundColor"))) {
            b.setLogBtnBackgroundDrawable(
                    new ColorDrawable(parseColor(c.getString("logBtnBackgroundColor"), Color.BLUE)));
        }

        if (c.hasKey("switchAccText")) b.setSwitchAccText(c.getString("switchAccText"));
        if (c.hasKey("switchAccTextColor"))
            b.setSwitchAccTextColor(parseColor(c.getString("switchAccTextColor"), Color.GRAY));
        if (c.hasKey("switchAccHidden")) b.setSwitchAccHidden(c.getBoolean("switchAccHidden"));

        if (c.hasKey("checkboxIsChecked")) b.setPrivacyState(c.getBoolean("checkboxIsChecked"));
        if (c.hasKey("privacyState")) b.setCheckboxHidden(c.getBoolean("privacyState"));

        if (c.hasKey("privacyOne")) {
            String[] pair = readPair(c, "privacyOne");
            if (pair != null) b.setAppPrivacyOne(pair[0], pair[1]);
        }
        if (c.hasKey("privacyTwo")) {
            String[] pair = readPair(c, "privacyTwo");
            if (pair != null) b.setAppPrivacyTwo(pair[0], pair[1]);
        }
        if (c.hasKey("privacyThree")) {
            String[] pair = readPair(c, "privacyThree");
            if (pair != null) b.setAppPrivacyThree(pair[0], pair[1]);
        }

        if (c.hasKey("privacyPrefix")) b.setPrivacyBefore(c.getString("privacyPrefix"));
        if (c.hasKey("privacyEnd")) b.setPrivacyEnd(c.getString("privacyEnd"));
        if (c.hasKey("privacyColors")) {
            String[] colors = readPair(c, "privacyColors");
            if (colors != null) {
                b.setAppPrivacyColor(
                        parseColor(colors[0], Color.GRAY),
                        parseColor(colors[1], Color.BLUE));
            }
        }
        if (c.hasKey("privacySize")) b.setPrivacyTextSize((int) c.getDouble("privacySize"));

        if (c.hasKey("dialogMode") && c.getBoolean("dialogMode")) {
            if (c.hasKey("dialogWidth")) b.setDialogWidth((int) c.getDouble("dialogWidth"));
            if (c.hasKey("dialogHeight")) b.setDialogHeight((int) c.getDouble("dialogHeight"));
            if (c.hasKey("dialogOffsetX")) b.setDialogOffsetX((int) c.getDouble("dialogOffsetX"));
            if (c.hasKey("dialogOffsetY")) b.setDialogOffsetY((int) c.getDouble("dialogOffsetY"));
            if (c.hasKey("dialogBottom")) b.setDialogBottom(c.getBoolean("dialogBottom"));
        }

        if (c.hasKey("privacyAlertIsNeed"))
            b.setPrivacyAlertIsNeedShow(c.getBoolean("privacyAlertIsNeed"));

        return b.create();
    }

    private String[] readPair(ReadableMap c, String key) {
        try {
            com.facebook.react.bridge.ReadableArray arr = c.getArray(key);
            if (arr == null || arr.size() < 2) return null;
            return new String[]{arr.getString(0), arr.getString(1)};
        } catch (Throwable e) {
            return null;
        }
    }
}
