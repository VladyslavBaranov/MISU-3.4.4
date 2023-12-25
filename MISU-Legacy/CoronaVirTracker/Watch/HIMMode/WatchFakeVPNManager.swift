//
//  WatchFakeVPNManager.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 25.01.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation
import NetworkExtension
import TrusangBluetooth

typealias SuccessBoolCompletion = (Bool)->Void
typealias ConnectWatchCompletion = (_ success: Bool, _ error: String?)->Void
protocol WatchFakeVPNManagerDelegate {
    func gotVPNManager(manager: NETunnelProviderManager)
}

class WatchFakeVPNManager {
    static let shared = WatchFakeVPNManager()
    private init() {
        loadFromPrefs()
    }
    
    var delegate: WatchFakeVPNManagerDelegate? = nil
    var manager: NETunnelProviderManager? = nil
    
    func startFakeWPN(completion: ConnectWatchCompletion? = nil) {
        //print("### \(WatchSinglManager.shared.connectedDeviceZHJ?.name)")
        guard let deviceName = WatchSinglManager.shared.connectedDeviceZHJ?.name,
           KeychainUtils.saveToSharedDeviceName(deviceName), !deviceName.isEmpty else {
            completion?(false, NSLocalizedString("Reconnect MISUWatch", comment: ""))
            return
        }
        
        guard let token = KeychainUtils.getCurrentUserToken(),
           KeychainUtils.saveToSharedCurrentUserToken(token), !token.isEmpty else {
            completion?(false, NSLocalizedString("Try login again", comment: ""))
            return
        }
        //print("$$$ start")
        loadFromPrefs { prfSuccess, prfError in
            if prfSuccess {
                //print("$$$ prfSuccess")
                self.removeVPNFromPrefs { remSucces, rmError in
                    if remSucces {
                        //print("$$$ remSucces")
                        self.createNew { crSuc, crErr in
                            if crSuc {
                                //print("$$$ crSuc")
                                self.loadFromPrefs { sc, er in
                                    if sc {
                                        //print("$$$ sc")
                                        self.startVPN(completion: completion)
                                    } else {
                                        //print("$$$ sc Error")
                                        completion?(sc, er)
                                    }
                                }
                            } else {
                                //print("$$$ crSuc Error")
                                completion?(crSuc, crErr)
                            }
                        }
                    } else {
                        //print("$$$ remSucces Error")
                        completion?(remSucces, rmError)
                    }
                }
            } else {
                //print("$$$ prfSuccess Error")
                self.createNew { crSuccess, crError in
                    if crSuccess {
                        //print("$$$ crSuccess")
                        self.loadFromPrefs { sc, er in
                            if sc {
                                //print("$$$ sc")
                                self.startVPN(completion: completion)
                            } else {
                                //print("$$$ sc error")
                                completion?(sc, er)
                            }
                        }
                    } else {
                        //print("$$$ crSuccess Error")
                        completion?(crSuccess, crError)
                    }
                }
            }
        }
        
        /*loadFromPrefs { success, error in
            if success {
                self.removeVPNFromPrefs { scs, rr in
                    print("Success \(scs), ERROR \(rr ?? "nil")")
                    if !scs {
                        completion?(scs, error)
                        return
                    }
                    
                    self.createNew { success_, error_ in
                        if success_ {
                            self.loadFromPrefs { suc_, er_ in
                                if !suc_ {
                                    completion?(suc_, er_)
                                    return
                                }
                                self.startVPN(completion: completion)
                                return
                            }
                            return
                        }
                        completion?(success_, error)
                        return
                    }
                }
            } else {
            
                self.createNew { success, error in
                    //print("### \(success) \(String(describing: error))")
                    if success {
                        self.loadFromPrefs { suc_, er_ in
                            if !suc_ {
                                completion?(suc_, er_)
                                return
                            }
                            self.startVPN(completion: completion)
                            return
                        }
                        return
                    }
                    
                    completion?(success, error)
                }
            }
        }*/
    }
    
    private func createNew(completion: ConnectWatchCompletion? = nil) {
        let manager_ = makeManager()
        manager_.saveToPreferences { [self] error in
            print("### VPN create error \(String(describing: error))")
            if error == nil {
                manager = manager_
                print("### VPN Created new")
                //startVPN()
                completion?(true, nil)
                delegate?.gotVPNManager(manager: manager_)
            } else {
                print("### VPN save error \(String(describing: error))")
                completion?(false, error?.localizedDescription)
            }
        }
    }
    
    func loadFromPrefs(completion: ConnectWatchCompletion? = nil) {
        NETunnelProviderManager.loadAllFromPreferences { [self] managers, error in
            //print("### VPN managers: \(String(describing: managers?.count)) error \(String(describing: error))")
            if let m = managers?.first {
                manager = m
                //print("### VPN Got existing")
                completion?(true, error?.localizedDescription)
                delegate?.gotVPNManager(manager: m)
                //startVPN()
            } else {
                completion?(false, error?.localizedDescription)
//                let manager_ = makeManager()
//                manager_.saveToPreferences { [self] error in
//                    print("### VPN create error \(String(describing: error))")
//                    if error == nil {
//                        manager = manager_
//                        print("### VPN Created new")
//                        startVPN()
//                    }
//                }
            }
            
            
        }
    }
    
    func stopVPN() {
        manager?.connection.stopVPNTunnel()
    }
    
    func removeVPNFromPrefs(completion: ConnectWatchCompletion? = nil) {
        manager?.removeFromPreferences(completionHandler: { error in
            completion?(error == nil, error?.localizedDescription)
        })
    }
    
    private func startVPN(completion: ConnectWatchCompletion? = nil) {
        do {
            let optionsTest = [NEVPNConnectionStartOptionUsername: "MISU",
                               NEVPNConnectionStartOptionPassword: "password"
            ] as [String : NSObject]
            try manager?.connection.startVPNTunnel(options: optionsTest)
            print("### Started VPN tunnel message ...")
            completion?(true, nil)
        } catch {
            print("### Failed to start VPN tunnel message: \(error.localizedDescription)")
            completion?(false, error.localizedDescription)
        }
    }
    
    private func makeManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "Secure VPN connection for MISUWatch"

        // Configure a VPN protocol to use a Packet Tunnel Provider
        let proto = NETunnelProviderProtocol()
        
        // This must match an app extension bundle identifier
        proto.providerBundleIdentifier = "com.WH.MISU.WatchVPN"
        
        // Replace with an actual VPN server address
        proto.serverAddress = "MISUWatch VPN"
        
        // Pass additional information to the tunnel
        proto.providerConfiguration = [:]
        
        manager.protocolConfiguration = proto

        // Enable the manager by default
        manager.isEnabled = true

        return manager
    }
}


//class NEPacketTunnelProviderTest: NEPacketTunnelProvider {
//    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
//        print("### VPN IT IS ALIVE !!! ...")
//    }
//}
