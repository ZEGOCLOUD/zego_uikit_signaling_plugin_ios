//
//  ZegoSignalingPlugin+Invitation.swift
//  ZegoUIKitCallWithInvitation
//
//  Created by zego on 2022/10/14.
//

import Foundation
import ZIM
import ZegoUIKitSDK

enum ZegoCallStatus: Int {
    case free = 0
    case outgoing = 1
    case incoming = 2
    case calling = 3
}

class ZegoCallObject: NSObject {
    var inviterID: String?
    var invitees: [String]?
    var acceptInvitees = [String]()
    var callID: String?
    var callStatus: ZegoCallStatus = .free
    var type: Int = 0
    
    init(_ callID: String, type: Int, callStatus: ZegoCallStatus, inviterID: String?, invitees: [String]?) {
        self.callID = callID
        self.callStatus = callStatus
        self.inviterID = inviterID
        self.invitees = invitees
    }
    
    func resetCall() {
        self.callID = nil
        self.callStatus = .free
        self.inviterID = nil
        self.invitees = nil
    }
}

extension ZegoSignalingPluginCore {
    
    func sendInvitation(_ invitees: [String], timeout: UInt32, type: Int, data: String?, callBack: PluginCallBack?) {
        let callInviteConfig: ZIMCallInviteConfig = ZIMCallInviteConfig()
        let dataDict:[String:AnyObject] = [
            "type": type as AnyObject,
            "inviter_name": ZegoUIKit.shared.localUserInfo?.userName as AnyObject,
            "data": data as AnyObject
        ]
        callInviteConfig.timeout = timeout
        callInviteConfig.extendedData = dataDict.jsonString
        self.zim?.callInvite(with: invitees, config: callInviteConfig, callback: { call_id, info, errorInfo in
            let errorInvitees: [String]? = self.errorInviteesList(info.errorInvitees)
            if errorInfo.code == .success {
                guard let inviter = ZegoUIKit.shared.localUserInfo else { return }
                self.buildInvitatinData(call_id, inviter: inviter,invitees: invitees, type: type)
                self.updateInvitationData(call_id, invitees: errorInvitees ?? [], state: .error)
            }
            guard let callBack = callBack else {
                return
            }
            let callbackParams: [String : AnyObject] = [
                "code": errorInfo.code.rawValue as AnyObject,
                "message": errorInfo.message as AnyObject,
                "callID": call_id as AnyObject,
                "errorInvitees": errorInvitees as AnyObject
            ]
            callBack(callbackParams)
        })
    }

    func cancelInvitation(_ invitees: [String], data: String?, callBack: PluginCallBack?) {
        let cancelList: [String] = self.findCallID(invitees)
        for callID in cancelList {
            self.cancelCall(callID, invitees: invitees, data: data, callBack: callBack)
        }
    }
    
    private func cancelCall(_ callID: String, invitees: [String],data: String?, callBack: PluginCallBack?) {
        let cancelConfig = ZIMCallCancelConfig()
        if let data = data {
            cancelConfig.extendedData = data
        }
        self.zim?.callCancel(with: invitees, callID: callID, config: cancelConfig, callback: { call_id, errorInvitees, errorInfo in
            if errorInfo.code == .success {
                self.invitationDB.removeValue(forKey: callID)
            }
            guard let callBack = callBack else {
                return
            }
            let callbackParams: [String : AnyObject] = [
                "code": errorInfo.code.rawValue as AnyObject,
                "message": errorInfo.message as AnyObject,
                "errorInvitees": errorInvitees as AnyObject
            ]
            callBack(callbackParams)
        })
    }

    func refuseInvitation(_ inviterID: String, data: String?, callBack: PluginCallBack?) {
        let dataDict: [String : AnyObject]? = data?.convertStringToDictionary()
        let invitationID: String? = dataDict?["invitationID"] as? String
        var refuseInvitationData: InvitationData?
        if let invitationID = invitationID {
            refuseInvitationData = self.invitationDB[invitationID]
        }
        if refuseInvitationData == nil {
            refuseInvitationData = self.findCallIDWithInvitation(inviterID)
        }
        guard let refuseInvitationData = refuseInvitationData,
              let refuseInvitationID = refuseInvitationData.invitationID
        else { return }
        let rejectConfig = ZIMCallRejectConfig()
        if let data = data {
            rejectConfig.extendedData = data
        }
        self.zim?.callReject(with: refuseInvitationID, config: rejectConfig, callback: { call_id, errorInfo in
            if errorInfo.code == .success {
                self.invitationDB.removeValue(forKey: refuseInvitationID)
            }
        })
    }

    func acceptInvitation(_ inviterID: String, data: String?, callBack: PluginCallBack?) {
        let acceptInvitationData: InvitationData? = self.findCallIDWithInvitation(inviterID)
        guard let acceptInvitationData = acceptInvitationData,
              let invitationID = acceptInvitationData.invitationID
        else { return }
        let acceptConfig: ZIMCallAcceptConfig = ZIMCallAcceptConfig()
        if let data = data {
            acceptConfig.extendedData = data
        }
        self.zim?.callAccept(with: invitationID, config: acceptConfig, callback: { call_id, errorInfo in
            if errorInfo.code == .success {
                self.invitationDB.removeValue(forKey: invitationID)
            }
        })
    }
    
    func buildInvitatinData(_ invitationID: String, inviter: ZegoUIKitUser, invitees: [String], type: Int) {
        var newInvitees: [ZegoInvitationUser] = []
        for userID in invitees {
            let user = ZegoUIKitUser.init(userID, "")
            let invitationUser = ZegoInvitationUser.init(user, state: .wating)
            newInvitees.append(invitationUser)
        }
        let invitationData: InvitationData = InvitationData.init(invitationID, inviter: inviter, invitees: newInvitees, type: type)
        self.invitationDB[invitationID] = invitationData
    }
    
    func updateInvitationData(_ invitationID: String, invitees: [String], state: InvitationState) {
        let invitationData: InvitationData? = self.invitationDB[invitationID]
        guard let invitationData = invitationData,
              let invitationInvitees = invitationData.invitees
        else {
            return
        }
        for user in invitationInvitees {
            for userID in invitees {
                if user.user?.userID == userID {
                    user.state = state
                }
            }
        }
    }
    
    func findCallID(_ invitees: [String]) -> [String] {
        var cancelCallList: [String] = []
        for userID in invitees {
            for invitationData in self.invitationDB.values {
                let callID: String? = invitationData.inviteesDict[userID]
                if let callID = callID {
                    cancelCallList.append(callID)
                }
            }
        }
        return cancelCallList
    }
    
    func findCallIDWithInvitation(_ inviterID: String) -> InvitationData? {
        var targetInvitationData: InvitationData?
        for invitationData in self.invitationDB.values {
            if invitationData.inviter?.userID == inviterID {
                targetInvitationData = invitationData
                break
            }
        }
        return targetInvitationData
    }
    
    func clearCall(_ callID: String) {
        guard let invitationData = self.invitationDB[callID],
        let invitationInvitees = invitationData.invitees
        else { return }
        var needClear: Bool = true
        for user in invitationInvitees {
            if user.state == .wating {
                needClear = false
                break
            }
        }
        if needClear {
            self.invitationDB.removeValue(forKey: callID)
        }
    }

    func errorInviteesList(_ invitees: [ZIMCallUserInfo]?) -> [String]? {
        guard let invitees = invitees else {
            return nil
        }
        var errorInviteesList: [String] = []
        for user in invitees {
            errorInviteesList.append(user.userID)
        }
        return errorInviteesList
    }
}

extension ZegoSignalingPluginCore: ZIMEventHandler {
    func zim(_ zim: ZIM, callInvitationReceived info: ZIMCallInvitationReceivedInfo, callID: String) {
        let dataDic: Dictionary? = info.extendedData.convertStringToDictionary()
        let type: Int = dataDic?["type"] as! Int
        let data: String? = dataDic?["data"] as? String
        var newData: [String : AnyObject]? = data?.convertStringToDictionary()
        newData?["invitationID"] = callID as AnyObject
        let user: ZegoUIKitUser = ZegoUIKitUser.init(info.inviter, dataDic?["inviter_name"] as? String ?? "")
        self.buildInvitatinData(callID, inviter: user,invitees: [], type: type)
        let pluginData: [String : AnyObject] = [
            "inviter": user,
            "type": type as AnyObject,
            "data": newData?.jsonString as AnyObject
        ]
        for delegate in self.signalingPluginDelegates.allObjects {
            delegate.onPluginEvent?("onCallInvitationReceived_method", data: pluginData)
        }
    }

    func zim(_ zim: ZIM, callInvitationAccepted info: ZIMCallInvitationAcceptedInfo, callID: String) {
        self.invitationDB.removeValue(forKey: callID)
        let user: ZegoUIKitUser = ZegoUIKitUser.init(info.invitee, "")
        let pluginData: [String : AnyObject] = [
            "invitee": user,
            "data": info.extendedData as AnyObject
        ]
        for delegate in self.signalingPluginDelegates.allObjects {
            delegate.onPluginEvent?("onCallInvitationAccepted_method", data: pluginData)
        }
    }

    func zim(_ zim: ZIM, callInvitationRejected info: ZIMCallInvitationRejectedInfo, callID: String) {
        let invitationData: InvitationData? = self.invitationDB[callID]
        if let invitationData = invitationData {
            let dataDic: Dictionary? = info.extendedData.convertStringToDictionary()
            let user: ZegoUIKitUser = ZegoUIKitUser.init(info.invitee, dataDic?["inviter_name"] as? String ?? "")
            if let invitees = invitationData.invitees {
                for invitationUser in invitees {
                    if invitationUser.user?.userID == user.userID {
                        invitationUser.state = .refuse
                    }
                }
            }
            self.clearCall(callID)
            let data: String? = dataDic?["data"] as? String
            let pluginData: [String : AnyObject] = [
                "invitee": user,
                "data": data as AnyObject
            ]
            for delegate in self.signalingPluginDelegates.allObjects {
                delegate.onPluginEvent?("onCallInvitationRejected_method", data: pluginData)
            }
        }
    }

    func zim(_ zim: ZIM, callInvitationCancelled info: ZIMCallInvitationCancelledInfo, callID: String) {
        self.invitationDB.removeValue(forKey: callID)
        let dataDic: Dictionary? = info.extendedData.convertStringToDictionary()
        let data: String? = dataDic?["data"] as? String
        let user: ZegoUIKitUser = ZegoUIKitUser.init(info.inviter, dataDic?["inviter_name"] as? String ?? "")
        let pluginData: [String : AnyObject] = [
            "inviter": user,
            "data": data as AnyObject
        ]
        for delegate in self.signalingPluginDelegates.allObjects {
            delegate.onPluginEvent?("onCallInvitationCancelled_method", data: pluginData)
        }
    }

    func zim(_ zim: ZIM, callInviteesAnsweredTimeout invitees: [String], callID: String) {
        var userList = [ZegoUIKitUser]()
        for userID in invitees {
            let user = ZegoUIKitUser.init(userID, "")
            userList.append(user)
        }
        let pluginData: [String : AnyObject] = [
            "invitees": userList as AnyObject
        ]
        for delegate in self.signalingPluginDelegates.allObjects {
            delegate.onPluginEvent?("onCallInviteesAnsweredTimeout_method", data: pluginData)
        }
        
        let invitationData: InvitationData? = self.invitationDB[callID]
        guard let invitationData = invitationData,
              let invitationInvitees = invitationData.invitees
        else { return }
        for user in invitationInvitees {
            for userID in invitees {
                if userID == user.user?.userID {
                    user.state = .timeout
                }
            }
        }
        self.clearCall(callID)
    }

    func zim(_ zim: ZIM, callInvitationTimeout callID: String) {
        guard let invitationData: InvitationData = self.invitationDB[callID],
              let userID = invitationData.inviter?.userID
        else { return }
        let user = ZegoUIKitUser.init(userID, "")
        let pluginData: [String : AnyObject] = [
            "inviter": user
        ]
        for delegate in self.signalingPluginDelegates.allObjects {
            delegate.onPluginEvent?("onCallInvitationTimeout_method", data: pluginData)
        }
        self.invitationDB.removeValue(forKey: callID)
    }
    
    func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
        let pluginData: [String : AnyObject] = [
            "state": state.rawValue as AnyObject
        ]
        if state == .disconnected {
            self.loginOut()
        }
        for delegate in self.signalingPluginDelegates.allObjects {
            delegate.onPluginEvent?("onConnectionStateChanged_method", data: pluginData)
        }
    }
    
    //---UserInRoomAttributes
    func zim(_ zim: ZIM, roomMemberAttributesUpdated infos: [ZIMRoomMemberAttributesUpdateInfo], operatedInfo: ZIMRoomOperatedInfo, roomID: String) {
        var params: [String : AnyObject] = [:]
        
        var temInfos: [AnyObject] = []
        for roomMemberAttri in infos {
            var attributesInfo: [String : AnyObject] = [:]
            let userID: String = roomMemberAttri.attributesInfo.userID
            let attributes: [String: String] = roomMemberAttri.attributesInfo.attributes
            attributesInfo["userID"] = userID as AnyObject
            attributesInfo["attributes"] = attributes as AnyObject
            temInfos.append(attributesInfo as AnyObject)
        }
        params["infos"] = temInfos as AnyObject
        params["editor"] = operatedInfo.userID as AnyObject
        
        for delegate in self.signalingPluginDelegates.allObjects {
            delegate.onPluginEvent?("onUsersInRoomAttributesUpdated_method", data: params)
        }
    }
    
    func zim(_ zim: ZIM, roomAttributesUpdated updateInfo: ZIMRoomAttributesUpdateInfo, roomID: String) {
        var updateInfos: [AnyObject] = []
        var param: [String : AnyObject] = [:]
        param["isSet"] = (updateInfo.action == .set) as AnyObject
        param["properties"] = updateInfo.roomAttributes as AnyObject
        
        updateInfos.append(param as AnyObject)
        
        var params: [String : AnyObject] = [:]
        params["updateInfo"] = updateInfos as AnyObject

        for delegate in self.signalingPluginDelegates.allObjects {
            delegate.onPluginEvent?("onRoomPropertiesUpdated_method", data: params)
        }
    }
    
    func zim(_ zim: ZIM, roomAttributesBatchUpdated updateInfo: [ZIMRoomAttributesUpdateInfo], roomID: String) {
        var updateInfos: [AnyObject] = []
        for info in updateInfo {
            var param: [String : AnyObject] = [:]
            param["isSet"] = (info.action == .set) as AnyObject
            param["properties"] = info.roomAttributes as AnyObject
            updateInfos.append(param as AnyObject)
        }
        var params: [String : AnyObject] = [:]
        params["updateInfo"] = updateInfos as AnyObject
        
        for delegate in self.signalingPluginDelegates.allObjects {
            delegate.onPluginEvent?("onRoomPropertiesUpdated_method", data: params)
        }
    }
    
    func zim(_ zim: ZIM, roomMemberLeft memberList: [ZIMUserInfo], roomID: String) {
        var params: [String : AnyObject] = [:]
        var userIDList: [String] = []
        for mem in memberList {
            if mem.userID.count > 0 {
                userIDList.append(mem.userID)
            }
        }
        params["userIDList"] = userIDList as AnyObject
        params["roomID"] = roomID as AnyObject
        
        for delegate in self.signalingPluginDelegates.allObjects {
            delegate.onPluginEvent?("onRoomMemberLeft_method", data: params)
        }
    }
}
