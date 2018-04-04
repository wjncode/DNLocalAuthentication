//
//  LocalAuthentication.swift
//  DNLocalAuthentication
//
//  Created by mainone on 2018/4/4.
//  Copyright © 2018年 wjn. All rights reserved.
//

import UIKit
import LocalAuthentication

public typealias reply = ((_ success: Bool, _ error: Error?, _ errorMessage: String?) -> Void)
public typealias reset = ((_ success: Bool, _ error: Error?) -> Void)

private let localAuthenticationShareInstance = DNLocalAuthentication()

class DNLocalAuthentication: NSObject {
    open class var share: DNLocalAuthentication {
        return localAuthenticationShareInstance
    }
    
    private var onReset: reset?
    
    /// 指纹/面部识别
    ///
    /// - Parameters:
    ///   - reply: 验证结果
    ///   - reset: 验证失败后重置结果
    open func authenticationLogin(reply: @escaping reply, _ reset: @escaping reset) {
        onReset = reset
        // 本地认证上下文联系对象
        let context = LAContext()
        var error: NSError?
        
        // 判断设备是否具备指纹认证功能
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            print("可以指纹识别了")
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "验证指纹以确认您的身份", reply: { (success, error) in
                if success {
                    print("指纹验证成功")
                    DispatchQueue.main.async {
                        reply(true, error, "")
                    }
                } else {
                    print("指纹验证失败 错误原因:\(String(describing: error))")
                    let errorMessage = self.errorMessageForError(aerror: error)
                    print(errorMessage)
                    DispatchQueue.main.async {
                        reply(false, error, errorMessage)
                    }
                }
            })
        } else {
            let errorMessage = self.errorMessageForError(aerror: error)
            print(errorMessage)
            DispatchQueue.main.async {
                reply(false, error, errorMessage)
            }
        }
    }
    
    
    func errorMessageForError(aerror: Error?) -> String {
        var errorMessage = ""
        if let error = aerror as NSError? {
            switch error.code {
            case LAError.authenticationFailed.rawValue:
                errorMessage = "身份验证不成功" // 连续三次指纹识别错误
            case LAError.userCancel.rawValue:
                errorMessage = "手动取消验证"
            case LAError.userFallback.rawValue:
                errorMessage = "使用密码登录"
            case LAError.systemCancel.rawValue:
                errorMessage = "身份验证被系统取消" // 如按下Home或者电源键
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
                    errorMessage = "TouchID被锁" // 连续五次指纹识别错误
                    alertSystemPasswordView()
                } else if error.code == LAError.appCancel.rawValue {
                    errorMessage = "认证被取消应用程序"
                } else if error.code == LAError.invalidContext.rawValue {
                    errorMessage = "调用之前已经失效"
                }
            }
            
        }
        return errorMessage
    }
    
    @available(iOS 9.0, *)
    func alertSystemPasswordView() {
        // 本地认证上下文联系对象
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "通过Home键验证已有手机指纹", reply: { (success, error) in
                // 5次验证失败后,数字键盘重置结果
                DispatchQueue.main.async {
                    if self.onReset != nil {
                        self.onReset!(success, error)
                    }
                }
            })
        }
    }
}
