//
//  CallKitManager.swift
//  Pods-ZegoUIKitCallWithInvitationDemo
//
//  Created by Kael Ding on 2024/1/12.
//

import Foundation
import CallKit
import PushKit
import ZPNs
import AVFoundation
import ZegoPluginAdapter

class CallKitManager: NSObject {
    static let shared = CallKitManager()
    
    weak var delegate: CallKitManagerDelegate?
    
    private var isSandboxEnvironment = false
    private var pkPushRegistry: PKPushRegistry?
    
    private lazy var providerConfiguration: CXProviderConfiguration = {
        let providerConfiguration = CXProviderConfiguration(localizedName: "")
        providerConfiguration.supportsVideo = true
        providerConfiguration.includesCallsInRecents = true
        return providerConfiguration
    }()
    
    private lazy var cxProvider: CXProvider = {
        let provider = CXProvider(configuration: providerConfiguration)
        provider.setDelegate(self, queue: .main)
        return provider
    }()
    
    private lazy var cxCallController: CXCallController = {
        let controller = CXCallController(queue: .main)
        return controller
    }()
    
    func enableVoIP(_ isSandboxEnvironment: Bool) {
        self.isSandboxEnvironment = isSandboxEnvironment
        
        if pkPushRegistry == nil {
            pkPushRegistry = PKPushRegistry(queue: .main)
            pkPushRegistry?.delegate = self
            pkPushRegistry?.desiredPushTypes = Set([PKPushType.voIP])
        }
    }
    
    func reportIncomingCall(with uuid: UUID, title: String, hasVideo: Bool, completion: ((_ error: Error?) -> Void)? = nil) {
        // busy.
        if cxCallController.callObserver.calls.count > 0 {
            return
        }
        let update = CXCallUpdate()
        update.localizedCallerName = title
        update.hasVideo = hasVideo
        update.remoteHandle = .init(type: .generic, value: "")

        cxProvider.reportNewIncomingCall(with: uuid, update: update, completion: { error in
            completion?(error)
        })
        
    }
    
    func reportCallEnded(with uuid: UUID, reason: Int) {
        let reason = CXCallEndedReason(rawValue: reason) ?? .failed
        cxProvider.reportCall(with: uuid, endedAt: nil, reason: reason)
    }
    
    func endCall(with uuid: UUID) {        
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        requestTransaction(transaction)
    }
    
    func endAllCalls() {
        for call in cxCallController.callObserver.calls {
            let endCallAction = CXEndCallAction(call: call.uuid)
            let transaction = CXTransaction(action: endCallAction)
            requestTransaction(transaction)
        }
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
        cxCallController.request(transaction) { error in
            if error == nil {
                print("[CallKitManager][requestTransaction] Requested transaction successfully")
            } else {
                print("[CallKitManager][requestTransaction] Error requesting transaction (\(transaction.actions): (\(String(describing: error))")
            }
        }
    }
}

extension CallKitManager: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        ZPNs.shared().setVoipToken(pushCredentials.token, isProduct: !isSandboxEnvironment)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
                
        var title = ""
        if let aps = payload.dictionaryPayload["aps"] as? [String: Any] {
            if let alert = aps["alert"] as? [String: String] {
                title = alert["title"] ?? ""
            }
            if let alert = aps["alert"] as? String {
                title = alert
            }
        }
        
        let dict = payload.dictionaryPayload
        let callID = dict["call_id"] as? String ?? ""
        let data = dict["payload"] as? String ?? ""
        var hasVideo = false
        if let dataDict = jsonToDict(data) {
            hasVideo = dataDict["type"] as? Int == 1
        }
        // busy.
        // maybe too many offline calls
        if cxCallController.callObserver.calls.count > 0 {
            return
        }
        
        let uuid = UUID()
        self.delegate?.didReceiveIncomingPush(uuid, invitationID: callID, data: data)
        reportIncomingCall(with: uuid, title: title, hasVideo: hasVideo) { error in
            completion()
        }
        
    }
    
    private func jsonToDict(_ json: String?) -> [String : Any]? {
        if let json = json?.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: json, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String : Any]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}

extension CallKitManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print(#function)
    }
    
    func providerDidBegin(_ provider: CXProvider) {
        print(#function)
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print(#function)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        } catch {
            print(error)
        }
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print(#function)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        } catch {
            print(error)
        }
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print(#function)
        
        let callAction = CallKitAction {
            action.fulfill()
        } failAction: {
            action.fail()
        }
        delegate?.onCallKitTimeOutPerforming(callAction)
    }
    
    func provider(_ provider: CXProvider, execute transaction: CXTransaction) -> Bool {
        print(#function)
        return false
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print(#function)
        
        let callAction = CallKitAction {
            action.fulfill()
        } failAction: {
            action.fail()
        }
        delegate?.onCallKitStartCall(callAction)
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print(#function)
        let callAction = CallKitAction {
            action.fulfill()
        } failAction: {
            action.fail()
        }
        delegate?.onCallKitAnswerCall(callAction)
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print(#function)
        let callAction = CallKitAction {
            action.fulfill()
        } failAction: {
            action.fail()
        }
        delegate?.onCallKitEndCall(callAction)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print(#function)
        
        let callAction = CallKitAction {
            action.fulfill()
        } failAction: {
            action.fail()
        }
        delegate?.onCallKitSetHeldCall(callAction)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        print(#function)
        
        let callAction = CallKitAction {
            action.fulfill()
        } failAction: {
            action.fail()
        }
        delegate?.onCallKitSetMutedCall(callAction)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
        print(#function)
        
        let callAction = CallKitAction {
            action.fulfill()
        } failAction: {
            action.fail()
        }
        delegate?.onCallKitSetGroupCall(callAction)
    }
    
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        print(#function)
        
        let callAction = CallKitAction {
            action.fulfill()
        } failAction: {
            action.fail()
        }
        delegate?.onCallKitPlayDTMFCall(callAction)
    }
}
