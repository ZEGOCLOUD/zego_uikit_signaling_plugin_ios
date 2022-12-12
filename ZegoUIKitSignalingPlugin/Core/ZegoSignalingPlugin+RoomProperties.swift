//
//  ZegoSignalingPlugin+RoomProperties.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/23.
//

import Foundation
import ZIM
import ZegoUIKitSDK

extension ZegoSignalingPluginCore {
    func updateRoomProperty(_ key: String, value: String , isDeleteAfterOwnerLeft: Bool, isForce: Bool, isUpdateOwner: Bool, callBack: PluginCallBack?) {
        let roomAttributes: [String : String] = [key: value]
        let config: ZIMRoomAttributesSetConfig = ZIMRoomAttributesSetConfig()
        config.isDeleteAfterOwnerLeft = isDeleteAfterOwnerLeft
        config.isForce = isForce
        config.isUpdateOwner = isUpdateOwner
        
        self.zim?.setRoomAttributes(roomAttributes, roomID: self.roomInfo.roomID, config: config, callback: { roomID, errorKeys, errorInfo in
            guard let callBack = callBack else {
                return
            }
            
            let callbackParams: [String : AnyObject] = [
                "code": errorInfo.code.rawValue as AnyObject,
                "message": errorInfo.message as AnyObject,
                "errorKeys": errorKeys as AnyObject
            ]
            callBack(callbackParams)
        })
        
    }
    
    func deleteRoomProperties(_ keys: [String], isForce: Bool, callBack: PluginCallBack?) {
        let config: ZIMRoomAttributesDeleteConfig = ZIMRoomAttributesDeleteConfig()
        config.isForce = isForce
        
        self.zim?.deleteRoomAttributes(by: keys, roomID: self.roomInfo.roomID, config: config, callback: { roomID, errorKeys, errorInfo in
            
            guard let callBack = callBack else {
                return
            }
            
            let callbackParams: [String : AnyObject] = [
                "code": errorInfo.code.rawValue as AnyObject,
                "message": errorInfo.message as AnyObject,
                "errorKeys": errorKeys as AnyObject
            ]
            callBack(callbackParams)
        })
    }
    
    func beginRoomPropertiesBatchOperation(_ isDeleteAfterOwnerLeft: Bool, isForce: Bool, isUpdateOwner: Bool) {
        let config: ZIMRoomAttributesBatchOperationConfig = ZIMRoomAttributesBatchOperationConfig()
        config.isForce = isForce
        config.isDeleteAfterOwnerLeft = isDeleteAfterOwnerLeft
        config.isUpdateOwner = isUpdateOwner
        self.zim?.beginRoomAttributesBatchOperation(with: self.roomInfo.roomID, config: config)
    }
    
    func endRoomPropertiesBatchOperation(_ callBack: PluginCallBack?) {
        self.zim?.endRoomAttributesBatchOperation(with: self.roomInfo.roomID, callback: { roomID, errorInfo in
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
    
    func queryRoomProperties(_ callBack: PluginCallBack?) {
        
        self.zim?.queryRoomAllAttributes(by: self.roomInfo.roomID, callback: { roomID, roomAttributes, errorInfo in
            guard let callBack = callBack else {
                return
            }
            
            let callbackParams: [String : AnyObject] = [
                "code": errorInfo.code.rawValue as AnyObject,
                "message": errorInfo.message as AnyObject,
                "roomAttributes": roomAttributes as AnyObject
            ]
            callBack(callbackParams)
        })
    }
}
