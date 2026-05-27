# 阿里云号码认证 SDK 混淆规则
-keep class com.mobile.auth.**{*;}
-keep class com.cmic.**{*;}
-keep class cn.com.chinatelecom.account.api.**{*;}
-keep class com.nirvana.tools.logger.**{*;}
-keep class com.ucweb.union.base.**{*;}
-keep class com.alibaba.fastjson.**{*;}
-keep class com.aliyun.sdk.**{*;}

-dontwarn com.mobile.auth.**
-dontwarn com.cmic.**
-dontwarn cn.com.chinatelecom.account.**
-dontwarn com.nirvana.tools.logger.**

# md-native-number-auth 自身
-keep class com.md.numberauth.**{*;}
