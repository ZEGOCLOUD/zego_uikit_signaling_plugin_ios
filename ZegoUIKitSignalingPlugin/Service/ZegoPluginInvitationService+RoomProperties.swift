//
//  ZegoPluginInvitationService+RoomProperties.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/22.
//

import Foundation
import ZegoUIKitSDK

extension ZegoPluginInvitationService {
    func updateRoomProperty(_ key: String, value: String , isDeleteAfterOwnerLeft: Bool, isForce: Bool, isUpdateOwner: Bool, callBack: PluginCallBack?) {
        pluginCore.updateRoomProperty(key, value: value, isDeleteAfterOwnerLeft: isDeleteAfterOwnerLeft, isForce: isForce, isUpdateOwner: isUpdateOwner, callBack: callBack)
    }
    
    func deleteRoomProperties(_ keys:[String], isForce: Bool, callBack: PluginCallBack?) {
        pluginCore.deleteRoomProperties(keys, isForce: isForce, callBack: callBack)
    }
    
    func beginRoomPropertiesBatchOperation(_ isDeleteAfterOwnerLeft: Bool, isForce: Bool, isUpdateOwner: Bool) {
        pluginCore.beginRoomPropertiesBatchOperation(isDeleteAfterOwnerLeft, isForce: isForce, isUpdateOwner: isUpdateOwner)
    }
    
    func endRoomPropertiesBatchOperation(_ callBack: PluginCallBack?) {
        pluginCore.endRoomPropertiesBatchOperation(callBack)
    }
    
    func queryRoomProperties(_ callBack: PluginCallBack?) {
        pluginCore.queryRoomProperties(callBack)
    }
}
