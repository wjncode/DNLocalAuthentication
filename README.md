# DNLocalAuthentication
指纹解锁/面部解锁
> 指纹识别是从iPhone 5s开始支持的,在日常使用中,可以用来解锁手机和软件内部验证等用途,这里介绍的是在软件内部的使用,现在市面上应用的指纹解锁的应用还是很多的,尤其以金钱交易类的应用作为快捷登录和支付来使用,例如支付宝,招商银行等.

> Face ID是从iPhone X开始取代Touch ID的,实现代码与指纹识别一直,并不用需要修改原有代码

>这里具体讲解一下如何使用指纹/面部识别技术解锁应用

### 添加依赖库 引用头文件

``` swift
LocalAuthentication.framework

import LocalAuthentication

在使用Face ID的时候需要在info.plist 添加访问权限NSFaceIDUsageDescription
```

### 实现指纹/面部识别方法

``` swift

func LocalAuthenticationLogin() {
    // 本地认证上下文联系对象
    let context = LAContext()
    var error: NSError?

    // 判断设备是否具备指纹认证功能
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        print("可以指纹/面部识别了")
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "验证指纹/面部以确认您的身份", reply: { (success, error) in
            if success {
                print("验证成功")
                DispatchQueue.main.async {
                //更新UI 必须在主线程中更新,否则天知道要到猴年马月能执行
            }
            } else {
                print("验证失败 错误原因:\(String(describing: error))")
                let errorMessage = self.errorMessageForError(aerror: error)
                print(errorMessage)
            }
        })
    } else {
        let errorMessage = self.errorMessageForError(aerror: error)
        print(errorMessage)
    }
}

```

### 归纳验证错误原因

``` swift
func errorMessageForError(aerror: Error?) -> String {
    var errorMessage = ""
    if let error = aerror as NSError? {
        switch error.code {
        case LAError.authenticationFailed.rawValue:
        errorMessage = "身份验证不成功"
        case LAError.userCancel.rawValue:
        errorMessage = "手动取消验证"
        case LAError.userFallback.rawValue:
        errorMessage = "使用密码登录"
        case LAError.systemCancel.rawValue:
        errorMessage = "身份验证被系统取消"
        case LAError.passcodeNotSet.rawValue:
        errorMessage = "没有设置密码"
        case LAError.touchIDNotAvailable.rawValue:
        errorMessage = "设备不支持指纹"
        case LAError.touchIDNotEnrolled.rawValue:
        errorMessage = "没有登记的手指触摸ID"
        default:
            errorMessage = ""
        }
        if #available(iOS 9.0, *){
            if error.code == LAError.touchIDLockout.rawValue {
                errorMessage = "TouchID被锁"
            } else if error.code == LAError.appCancel.rawValue {
                errorMessage = "认证被取消应用程序"
            } else if error.code == LAError.invalidContext.rawValue {
                errorMessage = "调用之前已经失效"
            }
        }
    }
    return errorMessage
}
```

### 当TouchID被锁
> 5次验证失败之后TouchID会被锁死,无法再调起指纹识别,这时候我们需要调起系统密码输入界面输入密码来重现验证指纹功能

``` swift
@available(iOS 9.0, *)
func alertSystemPasswordView() {
    // 本地认证上下文联系对象
    let context = LAContext()
    var error: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "通过Home键验证已有手机指纹", reply: { (success, error) in
            if success {
                print("重设成功")
            } else {
                print("重设失败")
            }
        })
    }
}

```
