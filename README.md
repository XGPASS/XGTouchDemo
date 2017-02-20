## 主要内容
手势密码解锁和指纹TouchID解锁的demo，逐步修改中...
使用了pod管理，下载后，pod install一下，就可以运行了;
### 注意
设置TouchID，需要在真机模式下设置，模拟器无法设置;
保存密码解锁类型和状态用的是NSUserDefaults存储，如果设置好解锁类型或状态，立即重新运行会出现保存失败的bug，
经查相关文章，这是Xcode的bug，调试的时候断开Xcode链接，则无此bug;
###效果如图
![image](https://github.com/XGPASS/XGTouchDemo/blob/master/images/develop.gif)

现在略微来讲解一下TouchID的使用
## 1.系统所使用TouchID的SDK
添加引入```LocalAuthentication.framework```
framework主要的内容是这个几个类
```
- LAContext.h
- LAError.h
- LAPublicDefines.h
- LocalAuthentication.h
```
使用的时候直接
```
#import <LocalAuthentication/LocalAuthentication.h>
```
好了，废话少说，下面来讲主要使用的2个类；
## LAError.h
错误类型的枚举类，其实是把```LAPublicDefines```里的kLAError宏放入到了这枚举类中，统一了一下，具体代码注释写的很清晰，在这我加点中文翻译
```objective-c

typedef NS_ENUM(NSInteger, LAError)
{
    LAErrorAuthenticationFailed,     // 验证信息出错，就是说你指纹不对
    LAErrorUserCancel               // 用户取消了验证
    LAErrorUserFallback             // 用户点击了手动输入密码的按钮，所以被取消了
    LAErrorSystemCancel             // 被系统取消，就是说你现在进入别的应用了，不在刚刚那个页面，所以没法验证
    LAErrorPasscodeNotSet           // 用户没有设置TouchID
    LAErrorTouchIDNotAvailable      // 用户设备不支持TouchID
    LAErrorTouchIDNotEnrolled       // 用户没有设置手指指纹
    LAErrorTouchIDLockout           // 用户错误次数太多，现在被锁住了
    LAErrorAppCancel                // 在验证中被其他app中断
    LAErrorInvalidContext           // 请求验证出错
} NS_ENUM_AVAILABLE(10_10, 8_0);

```

## LAContext.h
想要在自己的项目中使用TouchID，就要用到```LAContext.h```这个类，
最上面的一个枚举
```objective-c
typedef NS_ENUM(NSInteger, LAPolicy)
{
    LAPolicyDeviceOwnerAuthenticationWithBiometrics NS_ENUM_AVAILABLE(NA, 8_0) __WATCHOS_AVAILABLE(3.0) __TVOS_AVAILABLE(10.0) = kLAPolicyDeviceOwnerAuthenticationWithBiometrics,
    LAPolicyDeviceOwnerAuthentication NS_ENUM_AVAILABLE(10_11, 9_0) = kLAPolicyDeviceOwnerAuthentication

} NS_ENUM_AVAILABLE(10_10, 8_0) __WATCHOS_AVAILABLE(3.0) __TVOS_AVAILABLE(10.0);
```
```
第一个枚举LAPolicyDeviceOwnerAuthenticationWithBiometrics就是说，用的是手指指纹去验证的；NS_ENUM_AVAILABLE(NA, 8_0)iOS8 可用
第二个枚举LAPolicyDeviceOwnerAuthentication少了WithBiometrics则是使用TouchID或者密码验证,默认是错误两次指纹或者锁定后,弹出输入密码界面;NS_ENUM_AVAILABLE(10_11, 9_0)iOS 9可用
```
接下来是几个实例方法，首先创建```LAContext```实例对象，使用简单的```[LAContext alloc] init]```来创建；

```
canEvaluatePolicy:error:方法用来检查当前设备是否可用touchID，返回一个BOOL值
evaluatePolicy:localizedReason:reply:调用验证方法，注意这里的三个参数：
第一个参数policy是要使用上面那个LAPolicy的枚举
第二个参数localizedReason是NSString类型的验证理由
第三个参数reply则是一个回调Block，block内有一个BOOL类型的success判断是否成功验证，还有一个用于判断错误信息的NSError类型的error
invalidate方法用来废止这个context
```
参数localizedReason的具体讲解：例如使用的TouchID```"XXX"的TouchID 请验证已有指纹```，其中的XXX是你app的name，这黑体字部分无法更改，后面的小字部分```请验证已有指纹```可以通过参数localizedReason自定义；

```LAContext```还有一个```localizedFallbackTitle```，是用来自定义弹出的alert底部右侧的feedback按钮的title，默认是输入密码，如果不想显示 feedback 按钮;可以设置 ```feedBackTitle = @""```，```localizedCancelTitle```则是自定义取消按钮的title，不过```localizedCancelTitle```系统10.0才能使用；

```objective-c
LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = @"验证登录密码";
    // LAPolicyDeviceOwnerAuthentication
    __weak __typeof(self)weakSelf = self;
    [context evaluatePolicy:policy localizedReason:@"通过Home键验证已有手机指纹" reply:^(BOOL success, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = @"";
            if (success) {
                message = @"通过了Touch ID 指纹验证";
                block(YES, NO, message);
            } else {
                //失败操作
                LAError errorCode = error.code;
                BOOL inputPassword = NO;
                switch (errorCode) {
                    case LAErrorAuthenticationFailed: {
                        // -1
                        [SVProgressHUD showErrorWithStatus:@"指纹不匹配"];
                        message = @"连续三次指纹识别错误";
                    }
                        break;

                    case LAErrorUserCancel: {
                        // -2
                        message = @"用户取消验证Touch ID";
                    }
                        break;

                    case LAErrorUserFallback: {
                        // -3
                        inputPassword = YES;
                        message = @"用户选择输入密码";
                    }
                        break;

                    case LAErrorSystemCancel: {
                        // -4 TouchID对话框被系统取消，例如按下Home或者电源键
                        message = @"取消授权，如其他应用切入";
                    }
                        break;

                    case LAErrorPasscodeNotSet: {
                        // -5
                        [SVProgressHUD showErrorWithStatus:@"此设备未设置系统密码"];
                        message = @"设备系统未设置密码";
                    }
                        break;

                    case LAErrorTouchIDNotAvailable: {
                        // -6
                        [SVProgressHUD showErrorWithStatus:@"此设备不支持 Touch ID"];
                        message = @"此设备不支持 Touch ID";
                    }
                        break;

                    case LAErrorTouchIDNotEnrolled: {
                        // -7
                        [SVProgressHUD showErrorWithStatus:@"用户未录入指纹"];
                        message = @"用户未录入指纹";
                    }
                        break;

                    case LAErrorTouchIDLockout: {
                        // -8 连续五次指纹识别错误，TouchID功能被锁定，下一次需要输入系统密码
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
                            [weakSelf openTouchIDWithPolicy:LAPolicyDeviceOwnerAuthentication touchIDBlock:block];
                        }
                        message = @"Touch ID被锁，需要用户输入密码解锁";
                    }
                        break;

                    case LAErrorAppCancel: {
                        // -9 如突然来了电话，电话应用进入前台，APP被挂起啦
                        message = @"用户不能控制情况下APP被挂起";
                    }
                        break;

                    case LAErrorInvalidContext: {
                        // -10
                        message = @"Touch ID 失效";
                    }
                        break;

                    default:
                        // [SVProgressHUD showErrorWithStatus:@"此设备不支持 Touch ID"];
                        break;
                }

            }
        });
    }];
```

## 指纹识别的版本问题

1.iOS 9 之前是没有```LAErrorTouchIDLockout```锁定这个选项的,默认错误5次后;第6次验证是自动弹出输入密码界面;

2.iOS 9 之后锁定指纹识别之后,如果需要立即弹出输入密码界面需要使用```LAPolicyDeviceOwnerAuthentication```这个属性重新发起验证;

## 弹窗显示级别问题

TouchID的弹窗的级别非常之高，高到离谱，经过验证应用程序内部没有比指纹识别的window的级别更高的UIWindowLevel，也就说了他是系统级的弹窗。需要注意的是，如果指纹弹窗显示和消失应用程序会调用：
```
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
  ```
只要你的app进入后台或者打开使用都可以弹出TouchID页面，具体显示逻辑视情况判断；

目前以上代码足可以满足大多数app中TouchID的使用，不足之处敬请指出；

参考文章：1.http://www.jianshu.com/p/d44b7d85e0a6
2.http://zcill.com/2016/02/29/LocalAuthentication%E6%BA%90%E7%A0%81%E5%AD%A6%E4%B9%A0/
