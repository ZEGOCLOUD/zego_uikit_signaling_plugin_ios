//
//  ZegoSignalingPlugin+UserInRoomAttributes.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/22.
//

import Foundation
import ZIM
import ZegoUIKitSDK

extension ZegoSignalingPluginCore {
    func joinRoom(roomID: String, callBack: PluginCallBack?) {
        if !roomInfo.roomID.isEmpty  {
            print("[zim] room has login.")
            guard let callBack = callBack else {
                return
            }
            callBack(["code": -1 as AnyObject,
                      "message": "room has login" as AnyObject])
            return
        }
        
        let roomInfo: ZIMRoomInfo = ZIMRoomInfo()
        roomInfo.roomID = roomID
        roomInfo.roomName = roomID
        
        self.roomInfo = roomInfo;
        self.zim?.enterRoom(with: roomInfo, config: ZIMRoomAdvancedConfig(), callback: { roomFullInfo, errorInfo in
            guard let callBack = callBack else {
                return
            }
            
            let callbackParams: [String : AnyObject] = [
                "code": errorInfo.code.rawValue as AnyObject,
                "message": errorInfo.message as AnyObject,
            ]
            callBack(callbackParams)
        })
    }
    
    func setUsersInRoomAttributes(_ key: String, value: String, userIDs: [String], roomID: String, callBack: PluginCallBack?) {
        let attributes: [String : String] = [key: value]
        let setConfig: ZIMRoomMemberAttributesSetConfig = ZIMRoomMemberAttributesSetConfig()
        self.zim?.setRoomMembersAttributes(attributes, userIDs: userIDs, roomID: roomID, config: setConfig, callback: { roomID, infos, errorUserList, errorInfo in
            
            guard let callBack = callBack else {
                return
            }

            var attributeInfos: [AnyObject] = []
            for info in infos {
                var attributeInfo : [String : AnyObject] = [:]
                let userID: String = info.attributesInfo.userID
                let attributes: AnyObject = info.attributesInfo.attributes as AnyObject
                
                attributeInfo["userID"] = userID as AnyObject
                attributeInfo["attributes"] = attributes as AnyObject
                attributeInfos.append(attributeInfo as AnyObject)
            }
            
            let callbackParams: [String : AnyObject] = [
                "code": errorInfo.code.rawValue as AnyObject,
                "message": errorInfo.message as AnyObject,
                "errorUserList": errorUserList as AnyObject,
                "infos": attributeInfos as AnyObject,
                "roomID": roomID as AnyObject
            ]
            callBack(callbackParams)
        })
    }
    
    func queryUsersInRoomAttributes(_ count: Int, nextFlag: String, callBack: PluginCallBack?) {
        if self.roomInfo.roomID.isEmpty {
            print("[zim] query users in-room attribute, room id is empty")
            guard let callBack = callBack else {
                return
            }
            callBack(["code": -2 as AnyObject,
                      "message": "room id is empty" as AnyObject])
            return
        }
        let config: ZIMRoomMemberAttributesQueryConfig = ZIMRoomMemberAttributesQueryConfig()
        config.nextFlag = nextFlag
        config.count = UInt32(count)
        
        self.zim?.queryRoomMemberAttributesList(by: self.roomInfo.roomID, config: config, callback: { roomID, infos, nextFlag, errorInfo in
            guard let callBack = callBack else {
                return
            }
            
            var attributeInfos: [AnyObject] = []
            for info in infos {
                var attributeInfo : [String : AnyObject] = [:]
                let userID: String = info.userID
                let attributes: AnyObject = info.attributes as AnyObject
                
                attributeInfo["userID"] = userID as AnyObject
                attributeInfo["attributes"] = attributes as AnyObject
                attributeInfos.append(attributeInfo as AnyObject)
            }
            
            let callbackParams: [String : AnyObject] = [
                "code": errorInfo.code.rawValue as AnyObject,
                "message": errorInfo.message as AnyObject,
                "nextFlag": nextFlag as AnyObject,
                "infos": attributeInfos as AnyObject,
                "roomID": roomID as AnyObject
            ]
            callBack(callbackParams)
            
        })
    }
    
    func leaveRoom(_ callBack: PluginCallBack?) {
        if roomInfo.roomID.isEmpty  {
            print("[zim] room has login.")
            guard let callBack = callBack else {
                return
            }
            callBack(["code": -1 as AnyObject,
                      "message": "room has login" as AnyObject])
            return
        }
        let roomID: String = self.roomInfo.roomID
        roomInfo.roomID = ""
        roomInfo.roomName = ""
        
        self.zim?.leaveRoom(by: roomID, callback: { roomID, errorInfo in
            guard let callBack = callBack else {
                return
            }
            
            let callbackParams: [String : AnyObject] = [
                "code": errorInfo.code.rawValue as AnyObject,
                "message": errorInfo.message as AnyObject,
                "roomID": roomID as AnyObject
            ]
            callBack(callbackParams)
        })
    }
    
}
