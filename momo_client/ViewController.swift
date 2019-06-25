//
//  ViewController.swift
//  momo_client
//
//  Created by 小久保 翔平 on 2019/06/25.
//  Copyright © 2019 kkb. All rights reserved.
//

import UIKit

import Starscream
import WebRTC
import SwiftyJSON

class ViewController: UIViewController, WebSocketDelegate, RTCPeerConnectionDelegate {
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        <#code#>
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        <#code#>
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        <#code#>
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        <#code#>
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        <#code#>
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        <#code#>
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        <#code#>
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        <#code#>
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        <#code#>
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("CONNECT")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("DISCONNECT")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("RECEIVE")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        <#code#>
    }
    
    private var webSocket: WebSocket?
    
    
    private let factory = RTCPeerConnectionFactory()

    private var config: RTCConfiguration {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer.init(urlStrings: ["stun:stun.l.google.com:19302"])]
        return config
    }
    private let mediaConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
    
    private var peerConnection: RTCPeerConnection?
    private var peerConnectionOption: RTCConfiguration?
    override func viewDidLoad() {
        super.viewDidLoad()

        peerConnection = factory.peerConnection(with: config, constraints: mediaConstraints, delegate: self)
        webSocket = WebSocket(url: URL(string: "ws://hoge")!)
        webSocket?.delegate = self
        webSocket?.connect()
    }


}

extension ViewController {
    func sendSDP(sessionDescription: RTCSessionDescription) {
        print("SEND SDP")
        let jsonSDP: JSON = [
            "sdp": sessionDescription.sdp,
            "type": RTCSessionDescription.string(for: sessionDescription.type)
        ]
        print("SDP = " + jsonSDP.rawString()!)
        webSocket?.write(string: jsonSDP.rawString()!)
    }

    func makeOffer() {
        let mediaConstraints = RTCMediaConstraints(
            mandatoryConstraints: ["OfferToReceiveVideo": "true", "OfferToReceiveAudio": "true"], optionalConstraints: nil)
        self.peerConnection?.offer(for: mediaConstraints, completionHandler: {(offer: RTCSessionDescription?, error: Error?) -> Void in
            if error != nil {
                return
            }
            print("SUCCESS OFFER")
            self.peerConnection?.setLocalDescription(offer!, completionHandler: {(error: Error?) -> Void in
                if error != nil {
                    return
                }
                print("SUCCESS SET SDP")
                self.sendSDP(sessionDescription: offer!)
            })
        })
    }
}
