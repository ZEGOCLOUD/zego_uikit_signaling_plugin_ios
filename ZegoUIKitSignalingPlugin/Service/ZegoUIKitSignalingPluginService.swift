//
//  ZegoPluginInvitationService.swift
//  ZegoUIKitCallWithInvitation
//
//  Created by zego on 2022/10/14.
//

import UIKit
import ZIM
import ZegoPluginAdapter
import ZPNs

class ZegoUIKitSignalingPluginService: NSObject, ZPNsNotificationCenterDelegate {
    
    static let shared = ZegoUIKitSignalingPluginService()
    
    private var notifyWhenAppRunningInBackgroundOrQuit: Bool = false
    private var isSandboxEnvironment: Bool = false
        
    let pluginEventHandlers: NSHashTable<ZegoSignalingPluginEventHandler> = NSHashTable(options: .weakMemory)
    let zimEventHandlers: NSHashTable<ZIMEventHandler> = NSHashTable(options: .weakMemory)
    
    override init() {
        super.init()
    }
    
    var zim: ZIM? = nil
    var userInfo: ZIMUserInfo? = nil
    
    public func initWith(appID: UInt32, appSign: String?) {
        let zimConfig: ZIMAppConfig = ZIMAppConfig()
        zimConfig.appID = appID
        zimConfig.appSign = appSign ?? ""
        self.zim = ZIM.shared()
        if self.zim == nil {
            self.zim = ZIM.create(with: zimConfig)
        }
        self.zim?.setEventHandler(self)
    }
    
    public func setVoipToken(_ token: Data, isSandboxEnvironment: Bool) {
        ZPNs.shared().setVoipToken(token, isProduct: !isSandboxEnvironment)
    }
    
    public func connectUser(userID: String, userName: String, token: String?, callback: ConnectUserCallback?) {
        let user = ZIMUserInfo()
        user.userID = userID
        user.userName = userName
        userInfo = user
        zim?.login(with: user, token: token ?? "") { error in
            var code = error.code.rawValue
            var message = error.message
            if error.code == .networkModuleUserHasAlreadyLogged {
                code = 0
                message = ""
            }
            callback?(code, message)
        }
    }
    
    public func disconnectUser() {
        zim?.logout()
    }
    
    public func renewToken(_ token: String, callback: RenewTokenCallback?) {
        zim?.renewToken(token) { token, error in
            callback?(error.code.rawValue, error.message)
        }
    }
    
    public func sendInvitation(with invitees: [String], timeout: UInt32, data: String?, notificationConfig: ZegoSignalingPluginNotificationConfig?,callback: InvitationCallback?) {
        let config = ZIMCallInviteConfig()
        config.timeout = timeout
        config.extendedData = data ?? ""
        if notifyWhenAppRunningInBackgroundOrQuit, let notificationConfig = notificationConfig {
            let pushConfig: ZIMPushConfig = ZIMPushConfig()
            pushConfig.resourcesID =  notificationConfig.resourceID
            pushConfig.title = notificationConfig.title
            pushConfig.content = notificationConfig.message
            pushConfig.payload = data ?? ""
            config.pushConfig = pushConfig
        }
        zim?.callInvite(with: invitees, config: config, callback: { callID, info, error in
            let code = error.code.rawValue
            let message = error.message
            let errorInvitees = info.errorUserList.compactMap({ $0.userID })
            callback?(code, message, callID, errorInvitees)
        })
    }
    
    public func cancelInvitation(with invitees: [String], invitationID: String, data: String?, callback: CancelInvitationCallback?) {
        let config = ZIMCallCancelConfig()
        config.extendedData = data ?? ""
        zim?.callCancel(with: invitees, callID: invitationID, config: config, callback: { callID, errorInvitees, error in
            let code = error.code.rawValue
            let message = error.message
            callback?(code, message, errorInvitees)
        })
    }
    
    public func refuseInvitation(with invitationID: String, data: String?, callback: ResponseInvitationCallback?) {
        let config = ZIMCallRejectConfig()
        config.extendedData = data ?? ""
        zim?.callReject(with: invitationID, config: config, callback: { callID, error in
            callback?(error.code.rawValue, error.message)
        })
    }
    
    func acceptInvitation(with invitationID: String, data: String?, callback: ResponseInvitationCallback?) {
        let config = ZIMCallAcceptConfig()
        config.extendedData = data ?? ""
        zim?.callAccept(with: invitationID, config: config, callback: { callID, error in
            callback?(error.code.rawValue, error.message)
        })
    }
    
    public func enableNotifyWhenAppRunningInBackgroundOrQuit(_ enable: Bool,
                                                             isSandboxEnvironment: Bool,
                                                             certificateIndex: ZegoSignalingPluginMultiCertificate) {
        self.notifyWhenAppRunningInBackgroundOrQuit = enable
        self.isSandboxEnvironment = isSandboxEnvironment
        if enable == true {
            let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert,.badge,.sound,.criticalAlert]) { (granted: Bool, error: Error?) in
                  if granted {
                      DispatchQueue.main.sync {
                          let config = ZPNsConfig()
                          config.appType = certificateIndex.rawValue
                          ZPNs.shared().setPush(config)
                          ZPNs.shared().registerAPNs()
                          ZPNs.shared().setZPNsNotificationCenterDelegate(self)
                          UIApplication.shared.registerForRemoteNotifications()
                      }
                  }
            }
//            CallKitManager.shared.delegate = self
//            CallKitManager.shared.enableVoIP(isSandboxEnvironment)
        }
    }
        
    public func setRemoteNotificationsDeviceToken(_ deviceToken: Data) {
        ZPNs.shared().setDeviceToken(deviceToken, isProduct: !self.isSandboxEnvironment)
    }
    
    public func registerPluginEventHandler(_ delegate: ZegoSignalingPluginEventHandler) {
        pluginEventHandlers.add(delegate)
    }
    
    func registerZIMEventHandler(_ handler: ZIMEventHandler) {
        zimEventHandlers.add(handler)
    }

    func onRegistered(_ Pushid: String) {
        debugPrint("onRegistered, push id: \(Pushid)")
    }
}
