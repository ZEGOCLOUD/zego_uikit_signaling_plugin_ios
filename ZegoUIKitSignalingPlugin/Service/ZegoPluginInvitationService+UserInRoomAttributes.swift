//
//  ZegoPluginInvitationService+UserInRoomAttributes.swift
//  ZegoUIKitPrebuiltLiveAudio
//
//  Created by zego on 2022/11/22.
//

import Foundation
import ZegoUIKitSDK

extension ZegoPluginInvitationService {
    
    func joinRoom(roomID: String, callBack: PluginCallBack?) {
        pluginCore.joinRoom(roomID: roomID, callBack: callBack)
    }
    
    func leaveRoom(_ callBack: PluginCallBack?) {
        pluginCore.leaveRoom(callBack)
    }
    
    func setUsersInRoomAttributes(_ key: String, value: String, userIDs: [String], roomID: String, callBack: PluginCallBack?) {
        pluginCore.setUsersInRoomAttributes(key, value: value, userIDs: userIDs, roomID: roomID, callBack: callBack)
    }
    
    func queryUsersInRoomAttributes(_ count: Int, nextFlag: String, callBack: PluginCallBack?) {
        pluginCore.queryUsersInRoomAttributes(count, nextFlag: nextFlag, callBack: callBack)
    }
    
}
