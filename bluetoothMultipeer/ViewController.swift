//
//  ViewController.swift
//  bluetoothMultipeer
//
//  Created by Nisha Pant on 10/21/17.
//  Copyright © 2017 Nisha Pant. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate{
    let serviceType = "LCOC-Chat"
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var browser : MCBrowserViewController!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var chatView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        self.browser = MCBrowserViewController(serviceType: serviceType, session: mcSession)
        self.browser.delegate = self;
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType:serviceType, discoveryInfo:nil, session:self.mcSession)
        self.mcAdvertiserAssistant.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        let message = self.messageTextField.text
        self.sendMessageFunction(msg: message!)
        self.updateChat(text: self.messageTextField.text!, fromPeer: self.peerID)
        self.messageTextField.text = ""
    }
    
    @IBAction func findConnections(_ sender: UIButton) {
        self.present(self.browser, animated: true, completion: nil)
    }
    
    
    func updateChat(text : String, fromPeer peerID: MCPeerID) {
        var name : String
        
        switch peerID {
        case self.peerID:
            name = "Me"
        default:
            name = peerID.displayName
        }
        
        let message = "\(name): \(text)\n"
        DispatchQueue.main.async {
            self.chatView.text = self.chatView.text + message
        }
        
    }
    
    func sendMessageFunction(msg: String){
        if mcSession.connectedPeers.count > 0 {
            let msgData = msg.data(using: String.Encoding.utf8, allowLossyConversion: false)
                do {
                    try mcSession.send(msgData!, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
        }
    }
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            DispatchQueue.main.async { [unowned self] in
                self.updateChat(text: message as String, fromPeer: peerID)
            }
        }
       
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

}

