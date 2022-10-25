//
//  ZegoSignalCoreDefine.swift
//  ZegoUIKitCallWithInvitation
//
//  Created by zego on 2022/10/17.
//

import UIKit
import ZegoUIKitSDK

enum InvitationState: Int {
    case error
    case accept
    case wating
    case refuse
    case cancel
    case timeout
}

class ZegoInvitationUser: NSObject {
    var user: ZegoUIkitUser?
    var state: InvitationState = .error
    
    init(_ user: ZegoUIkitUser, state: InvitationState) {
        super.init()
        self.user = user
        self.state = state
    }
}

class InvitationData: NSObject {
    var invitationID: String?
    var inviter: ZegoUIkitUser?
    var invitees: [ZegoInvitationUser]?
    var type: ZegoInvitationType = .voiceCall
    var inviteesDict: [String : String] = [:]
    
    init(_ invitationID: String, inviter: ZegoUIkitUser, invitees: [ZegoInvitationUser], type: ZegoInvitationType) {
        super.init()
        self.invitationID = invitationID
        self.invitees = invitees
        self.inviter = inviter
        self.type = type
        for user in invitees {
            guard let userID = user.user?.userID else { continue }
            self.inviteesDict[userID] = invitationID
        }
    }
}

