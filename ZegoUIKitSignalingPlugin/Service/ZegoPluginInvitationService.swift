//
//  ZegoPluginInvitationService.swift
//  ZegoUIKitCallWithInvitation
//
//  Created by zego on 2022/10/14.
//

import UIKit
import ZegoUIKitSDK

class ZegoPluginInvitationService: NSObject {
    
    static let shared = ZegoPluginInvitationService()
    
    let pluginCore = ZegoSignalingPluginCore.shared
    
    override init() {
        super.init()
    }
    
    func registerPluginEventHandler(_ object: ZegoPluginEventHandle) {
        pluginCore.registerPluginEventHandler(object)
    }
    
    func initWithAppID(appID: UInt32, appSign: String) {
        pluginCore.initWithAppID(appID: appID, appSign: appSign)
    }
    
    func uninit() {
        pluginCore.uninit()
    }
    
    func login(_ userID: String, userName: String, callBack: PluginCallBack?) {
        pluginCore.login(userID, userName: userName, callBack: callBack)
    }
    
    func loginOut() {
        pluginCore.loginOut()
    }

    func sendInvitation(_ invitees: [String], timeout: UInt32, type: Int, data: String?, notificationConfig: ZegoSignalingPluginNotificationConfig?, callBack: PluginCallBack?) {
        pluginCore.sendInvitation(invitees, timeout: timeout, type: type, data: data, notificationConfig: notificationConfig, callBack: callBack)
    }

    func cancelInvitation(_ invitees: [String], data: String?, callBack: PluginCallBack?) {
        pluginCore.cancelInvitation(invitees, data: data, callBack: callBack)
    }

    func refuseInvitation(_ inviterID: String, data: String?, callBack: PluginCallBack?) {
        pluginCore.refuseInvitation(inviterID, data: data, callBack: callBack)
    }

    func acceptInvitation(_ inviterID: String, data: String?, callBack: PluginCallBack?) {
        pluginCore.acceptInvitation(inviterID, data: data, callBack: callBack)
    }
    
    func enableNotifyWhenAppRunningInBackgroundOrQuit(_ enable: Bool, isSandboxEnvironment: Bool) {
        pluginCore.enableNotifyWhenAppRunningInBackgroundOrQuit(enable, isSandboxEnvironment: isSandboxEnvironment)
    }
    
    func setRemoteNotificationsDeviceToken(_ deviceToken: Data) {
        pluginCore.setRemoteNotificationsDeviceToken(deviceToken)
    }

}
