//
//  ZegoUIKitSignalingPluginService+CallKit.swift
//  ZegoUIKitSignalingPlugin
//
//  Created by Kael Ding on 2024/1/16.
//

import Foundation

extension ZegoUIKitSignalingPluginService {
    func reportIncomingCall(with uuid: UUID, title: String, hasVideo: Bool) {
        CallKitManager.shared.reportIncomingCall(with: uuid, title: title, hasVideo: hasVideo)
    }
    
    func reportCallEnded(with uuid: UUID, reason: Int) {
        CallKitManager.shared.reportCallEnded(with: uuid, reason: reason)
    }
    
    func endCall(with uuid: UUID) {
        CallKitManager.shared.endCall(with: uuid)
    }
    
    func endAllCalls() {
        CallKitManager.shared.endAllCalls()
    }
}
