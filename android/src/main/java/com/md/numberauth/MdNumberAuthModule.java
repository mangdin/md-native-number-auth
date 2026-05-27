package com.md.numberauth;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

public class MdNumberAuthModule extends ReactContextBaseJavaModule {

    public static final String NAME = "MdNumberAuth";

    private final MdNumberAuthModuleImpl impl;

    MdNumberAuthModule(ReactApplicationContext context) {
        super(context);
        impl = new MdNumberAuthModuleImpl(context);
    }

    @Override
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void getVersion(Callback callback) {
        impl.getVersion(callback);
    }

    @ReactMethod
    public void setAuthSDKInfo(String info, Callback callback) {
        impl.setAuthSDKInfo(info, callback);
    }

    @ReactMethod
    public void checkEnvAvailable(int authType, Callback callback) {
        impl.checkEnvAvailable(authType, callback);
    }

    @ReactMethod
    public void accelerateLoginPage(double timeout, Callback callback) {
        impl.accelerateLoginPage(timeout, callback);
    }

    @ReactMethod
    public void accelerateVerify(double timeout, Callback callback) {
        impl.accelerateVerify(timeout, callback);
    }

    @ReactMethod
    public void getLoginToken(double timeout, ReadableMap uiConfig, Callback callback) {
        impl.getLoginToken(timeout, uiConfig, callback);
    }

    @ReactMethod
    public void getVerifyToken(double timeout, Callback callback) {
        impl.getVerifyToken(timeout, callback);
    }

    @ReactMethod
    public void quitLoginPage(boolean animated, Callback callback) {
        impl.quitLoginPage(animated, callback);
    }

    @ReactMethod
    public void hideLoginLoading(Callback callback) {
        impl.hideLoginLoading(callback);
    }

    @ReactMethod
    public void setCheckboxIsChecked(boolean isChecked, Callback callback) {
        impl.setCheckboxIsChecked(isChecked, callback);
    }

    @ReactMethod
    public void queryCheckBoxIsChecked(Callback callback) {
        impl.queryCheckBoxIsChecked(callback);
    }

    @ReactMethod
    public void setLoggerEnable(boolean enable, Callback callback) {
        impl.setLoggerEnable(enable, callback);
    }

    @ReactMethod
    public void addListener(String eventName) {
        // NativeEventEmitter requires these to be defined.
    }

    @ReactMethod
    public void removeListeners(Integer count) {
        // NativeEventEmitter requires these to be defined.
    }
}
