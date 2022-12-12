//
//  ZegoSignalingPluginCore.swift
//  ZegoUIKitCallWithInvitation
//
//  Created by zego on 2022/10/11.
//

import UIKit
import ZegoUIKitSDK
import ZIM

class ZegoSignalingPluginCore: NSObject {
    
    static let shared = ZegoSignalingPluginCore()
    
    var zim: ZIM?
    var roomInfo: ZIMRoomInfo = ZIMRoomInfo()
    
    var callObject: ZegoCallObject?
    // InvitationID : InvitationData
    var invitationDB: [String : InvitationData] = [:]

    let signalingPluginDelegates: NSHashTable<ZegoPluginEventHandle> = NSHashTable(options: .weakMemory)
    
    func registerPluginEventHandler(_ object: ZegoPluginEventHandle) {
        signalingPluginDelegates.add(object)
    }
    
    func initWithAppID(appID: UInt32, appSign: String) {
        let zimConfig: ZIMAppConfig = ZIMAppConfig()
        zimConfig.appID = appID
        zimConfig.appSign = appSign
        self.zim = ZIM.shared()
        if self.zim == nil {
            self.zim = ZIM.create(with: zimConfig)
        }
        self.zim?.setEventHandler(self)
    }
    
    func uninit() {
        self.zim?.destroy()
        self.zim = nil
    }
    
    func login(_ userID: String, userName: String, callBack: PluginCallBack?) {
        let userInfo: ZIMUserInfo = ZIMUserInfo()
        userInfo.userID = userID
        userInfo.userName = userName
        self.zim?.login(with: userInfo, token: "", callback: { error in
            guard let callBack = callBack else {
                return
            }
            
            let callbackParams: [String : AnyObject] = [
                "code": error.code.rawValue as AnyObject,
                "message": error.message as AnyObject,
            ]
            callBack(callbackParams)
        })
    }
    
    func loginOut() {
        self.zim?.logout()
    }
}
