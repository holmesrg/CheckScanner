//
//  DoNothingViewController.swift
//  CheckScanner
//
//  Created by Ron Holmes on 23/11/17.
//  Copyright © 2017 Ron Holmes. All rights reserved.
//

import UIKit

class DoNothingViewController: UIViewController, BCBeaconManagerDelegate {

    let BCKAppTokenKey = "BCKAppTokenKey"
    var tokenKey = ""
    
    var beaconManager = BCBeaconManager()
    
    @IBOutlet weak var appToken: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        guard let defaults = UserDefaults(suiteName: "group.com.bluecats.checkscanner") else {
//            print("Couldn't read defaults")
//            return
//        }
//
//        guard let appTokenKey = defaults.string(forKey: "BCKAppTokenKey") else {
//            performSegue(withIdentifier: "SetAppToken", sender: self)
//            return
//        }
        
        if BlueCatsSDK.status().rawValue != 1 {
            self.startScanning(withAppToken: "e7c0a406-a6d1-457f-b529-c1572f8a9ece")
        }
        
        beaconManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        guard let defaults = UserDefaults(suiteName: "group.com.bluecats.checkscanner") else {
//            print("Couldn't read defaults")
//            return
//        }
//
//        guard let appTokenKey = defaults.string(forKey: BCKAppTokenKey) else {
//            performSegue(withIdentifier: "SetAppToken", sender: self)
//            return
//        }
//
//        appToken.text = appTokenKey

        if BlueCatsSDK.status().rawValue != 1 {
            self.startScanning(withAppToken: "e7c0a406-a6d1-457f-b529-c1572f8a9ece")
        }
        
        if !BlueCatsSDK.isLocationAuthorized() {
            BlueCatsSDK.requestAlwaysLocationAuthorization()
        }
        
        print ("Beacon Scanning status \(BlueCatsSDK.status().rawValue)")
    }

    //MARK:- BlueCatsSDK
    func startScanning (withAppToken token:String) {
        
        BlueCatsSDK.setOptions([BCOptionScanInBackground:true, BCOptionUseEnergySaverScanStrategy: false])
        
        BlueCatsSDK.startPurring(withAppToken: token, completion: { (BCStatus) -> Void in
            let appTokenVerificationStatus: BCAppTokenVerificationStatus = BlueCatsSDK.appTokenVerificationStatus()
            
            if appTokenVerificationStatus == .notProvided || appTokenVerificationStatus == .invalid {
                print ("App token issue")
            }
            
            if !BlueCatsSDK.isLocationAuthorized() {
                BlueCatsSDK.requestAlwaysLocationAuthorization()
                print ("Location authorised reachable")
            }
            
            if !BlueCatsSDK.isNetworkReachable() {
                print ("Network reachable")
            }
            
            if !BlueCatsSDK.isBluetoothEnabled() {
                print ("Bluetooth Enabled")
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func beaconManager(_ monitor: BCBeaconManager!, didRangeBeacons beacons: [BCBeacon]!) {
        for currentBeacon in beacons {
            print ("\(currentBeacon.serialNumber ?? "__")")
        }
    }


}
