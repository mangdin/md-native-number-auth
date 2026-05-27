# md-native-number-auth

阿里云号码认证（一键登录 / 本机号码校验）React Native 组件，同时支持 Android 与 iOS。

- Android SDK：`numberAuthSDK_APP_Android_v2.14.22_operator_ui_log_static`（AAR）
- iOS SDK：`numberAuthSDK_APP_iOS_v2.14.17_operator_ui_log_static`（静态 XCFramework）

> 选择静态库版本的原因：React Native 默认 Podfile 不开启 `use_frameworks!`，静态 `xcframework` 通过 `vendored_frameworks` + `-ObjC` 链接器选项即可无侵入接入，对宿主工程改动最小。

## 安装

```bash
# 把 md-native-number-auth 目录放到项目根目录或者 node_modules 下
# 然后在 package.json 中以本地路径引用：
"md-native-number-auth": "file:../md-native-number-auth"
```

执行：

```bash
yarn install
cd ios && pod install
```

### iOS

- 最低系统：iOS 11.0
- Podfile 无需额外修改；`pod install` 后会自动以静态 `xcframework` 形式链接 `ATAuthSDK.xcframework`、`YTXOperators.xcframework`、`YTXMonitor.xcframework`。
- 在 `Info.plist` 中无需声明额外权限；如使用日志请在 Release 前关闭。

### Android

- minSdkVersion ≥ 21
- 在 `android/app/build.gradle` 中确认开启了 `multiDexEnabled true`
- 该组件已经在自己的 `AndroidManifest.xml` 中声明了授权页相关的 Activity，无需在宿主 manifest 中重复声明。
- 已自带授权页 SDK 所需的 ProGuard 规则（`android/proguard-rules.pro`），如宿主开启了混淆需要在 `proguardFiles` 中追加。

#### 手动注册（仅在没有 autolinking 的项目中需要）

`MainApplication.java`：

```java
import com.md.numberauth.MdNumberAuthPackage;

@Override
protected List<ReactPackage> getPackages() {
  List<ReactPackage> packages = new PackageList(this).getPackages();
  packages.add(new MdNumberAuthPackage());
  return packages;
}
```

## 快速上手

```ts
import {
  setAuthSDKInfo,
  checkEnvAvailable,
  accelerateLoginPage,
  getLoginToken,
  quitLoginPage,
  setLoggerEnable,
  AuthType,
  useAuthPageEvent,
} from 'md-native-number-auth';

// 1. 启动时调用一次（同时支持 iOS / Android）
await setLoggerEnable(__DEV__);
await setAuthSDKInfo('阿里云控制台获取到的秘钥');

// 2. 检测环境
const env = await checkEnvAvailable(AuthType.LoginToken);
if (env.code !== '600000') {
  // 不支持一键登录，回退到短信登录
}

// 3. 预取号（推荐在登录入口前 1~2s 调用）
await accelerateLoginPage(3.0);

// 4. 拉起授权页 + 获取 token
try {
  const resp = await getLoginToken({
    timeout: 5.0,
    uiConfig: {
      navColor: '#FFFFFF',
      navText: '一键登录',
      navTextColor: '#222222',
      logoImage: 'app_logo',     // Android: drawable 名；iOS: Images.xcassets 名
      sloganText: '认证服务由运营商提供',
      logBtnText: '本机号码一键登录',
      logBtnBackgroundColor: '#3478F6',
      switchAccText: '其他手机号登录',
      privacyOne: ['《用户协议》', 'https://example.com/terms'],
      privacyTwo: ['《隐私政策》', 'https://example.com/privacy'],
      privacyPrefix: '我已阅读并同意',
      privacyColors: ['#999999', '#3478F6'],
      privacySize: 12,
    },
  });
  // resp.code === '600000' 时取到 token
  console.log('loginToken:', resp.data?.token);
} catch (err) {
  // err 是 NumberAuthResponse，含 code / msg
  console.warn('登录失败', err);
} finally {
  await quitLoginPage(true);
}
```

### 监听授权页事件

`getLoginToken` 是一次性的 Promise，授权页用户的交互（点击协议、点击返回、点击切换登录方式等）会以事件形式抛出：

```tsx
import {useAuthPageEvent} from 'md-native-number-auth';

function LoginScreen() {
  useAuthPageEvent(event => {
    switch (event.code) {
      case '700000': // 点击返回
        console.log('用户取消');
        break;
      case '700001': // 切换其他登录方式
        navigation.replace('SmsLogin');
        break;
      case '700003': // 点击 checkbox
        console.log('checkbox:', event.data?.isChecked);
        break;
      case '700004': // 点击协议
        navigation.navigate('Web', {url: event.data?.url, title: event.data?.urlName});
        break;
    }
  });

  // ...
}
```

非 React 上下文：

```ts
import {addAuthPageListener, removeAuthPageListener} from 'md-native-number-auth';

const handler = event => { /* ... */ };
addAuthPageListener(handler);
// removeAuthPageListener(handler);
```

### 本机号码校验

```ts
import {checkEnvAvailable, accelerateVerify, getVerifyToken, AuthType} from 'md-native-number-auth';

await setAuthSDKInfo('...');
const env = await checkEnvAvailable(AuthType.VerifyToken);
if (env.code === '600000') {
  await accelerateVerify(3.0);
  const resp = await getVerifyToken(3.0);
  // 把 resp.data.token 发到服务端，服务端调用阿里云接口校验是否为本机号码
}
```

## API

| 方法 | 说明 |
| --- | --- |
| `setAuthSDKInfo(info)` | 设置秘钥，App 启动时调用一次 |
| `checkEnvAvailable(authType)` | 检查环境（1=本机号码校验，2=一键登录） |
| `accelerateLoginPage(timeout?)` | 预取号 / 加速授权页弹起 |
| `accelerateVerify(timeout?)` | 加速本机号码校验 |
| `getLoginToken({timeout, uiConfig})` | 拉起授权页并获取一键登录 token |
| `getVerifyToken(timeout?)` | 获取本机号码校验 token |
| `quitLoginPage(animated?)` | 关闭授权页 |
| `hideLoginLoading()` | 隐藏一键登录获取 token 后的 loading |
| `setCheckboxIsChecked(checked)` | 修改授权页协议勾选状态 |
| `queryCheckBoxIsChecked()` | 查询授权页协议勾选状态（iOS 准确，Android 通过事件维护） |
| `setLoggerEnable(enable)` | 控制日志输出（Release 请关闭） |
| `getVersion()` | 获取打包时的 SDK 版本号 |
| `addAuthPageListener(handler)` / `removeAuthPageListener(handler)` | 监听授权页事件 |
| `useAuthPageEvent(handler)` | React Hook 形式监听授权页事件 |

`AuthUIConfig` 字段详见 `src/typing.ts`，覆盖了导航栏、Logo、Slogan、号码、登录按钮、切换按钮、协议、弹窗模式、二次授权弹窗等常用选项。颜色统一使用 `#RRGGBB` / `#AARRGGBB` 字符串；尺寸 Android 端为 dp，iOS 端为 pt。

## 错误码

返回结构统一为：

```ts
{
  type: string;       // 调用方法名 / authPageEvent
  code: string;       // 600000 = 成功
  msg?: string;
  data?: { token?: string; isChecked?: boolean; url?: string; urlName?: string };
  raw?: string;       // 原始 JSON，便于排查
}
```

常见错误码：

| Code | 含义 |
| --- | --- |
| 600000 | 接口成功 |
| 600001 | 唤起授权页成功 |
| 600002 | 唤起授权页失败 |
| 600007 | 未检测到 SIM 卡 |
| 600008 | 蜂窝网络未开启或不稳定 |
| 600011 | 获取 token 失败 |
| 600015 | 接口超时 |
| 700000 | 用户点击返回 |
| 700001 | 用户点击切换登录方式 |
| 700002 | 用户点击登录按钮 |
| 700003 | 用户点击 checkbox |
| 700004 | 用户点击协议富文本 |

完整列表见 [阿里云号码认证 SDK 错误码](https://help.aliyun.com/zh/pnvs/developer-reference/error-codes-1)。

## 参考

- [Android 客户端接入](https://help.aliyun.com/zh/pnvs/developer-reference/the-android-client-access)
- [iOS 客户端接入](https://help.aliyun.com/zh/pnvs/developer-reference/the-ios-client-access)
