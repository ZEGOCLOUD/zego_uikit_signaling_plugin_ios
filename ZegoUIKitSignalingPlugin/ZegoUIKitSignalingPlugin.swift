//
//  ZegoUIKitSignalingPlugin.swift
//  ZegoUIKitCallWithInvitation
//
//  Created by zego on 2022/10/14.
//

import UIKit
import ZegoUIKitSDK

public class ZegoUIKitSignalingPlugin: ZegoUIKitPlugin {
    
    let invitationService = ZegoPluginInvitationService.shared
    
    public override init() {
        super.init()
    }

    public override func invoke(_ method: String, params: Dictionary<String, AnyObject>?, callBack: PluginCallBack?) {
        let methodName: ZegoPluginMethodName? = ZegoPluginMethodName.init(rawValue: method)
        guard let methodName = methodName else {
            return
        }
        switch methodName {
        case .init_method:
            guard let params = params else { return }
            let appID: UInt32 = params["appID"] as! UInt32
            let appSign: String = params["appSign"] as! String
            invitationService.initWithAppID(appID: appID, appSign: appSign)
        case .uinit_method:
            invitationService.uninit()
        case .login_method:
            guard let params = params else { return }
            let userID: String? = params["userID"] as? String
            let userName: String? = params["userName"] as? String
            guard let userID = userID,
                  let userName = userName
            else {
                return
            }
            invitationService.login(userID, userName: userName)
        case .logout_method:
            invitationService.loginOut()
        case .sendInvitation_method:
            guard let params = params else { return }
            let invitees: [String]? = params["invitees"] as? [String]
            let timeout: UInt32 = params["timeout"] as! UInt32
            let type: Int = params["type"] as! Int
            let data: String? = params["data"] as? String
            guard let invitees = invitees else { return }
            invitationService.sendInvitation(invitees, timeout: timeout, type: type, data: data, callBack: callBack)
        case .cancelInvitation_method:
            guard let params = params else { return }
            let invitees: [String]? = params["invitees"] as? [String]
            let data: String? = params["data"] as? String
            guard let invitees = invitees else { return }
            invitationService.cancelInvitation(invitees, data: data, callBack: callBack)
        case .refuseInvitation_method:
            guard let params = params else { return }
            let inviterID: String? = params["inviterID"] as? String
            let data: String? = params["data"] as? String
            guard let inviterID = inviterID else { return }
            invitationService.refuseInvitation(inviterID, data: data, callBack: callBack)
        case .acceptInvitation_method:
            guard let params = params else { return }
            let inviterID: String? = params["inviterID"] as? String
            let data: String? = params["data"] as? String
            guard let inviterID = inviterID else { return }
            invitationService.acceptInvitation(inviterID, data: data, callBack: callBack)
        default:
            break
        }
    }
    
    public override func registerPluginEventHandler(_ object: ZegoPluginEventHandle) {
        invitationService.registerPluginEventHandler(object)
    }
    
    public override func getVersion() -> String {
        return "1.0.0"
    }
    
    public override func getPluginType() -> ZegoUIKitPluginType {
        return .signaling
    }
    
}
