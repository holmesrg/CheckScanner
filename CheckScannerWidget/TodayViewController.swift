//
//  TodayViewController.swift
//  CheckScannerWidget
//
//  Created by Ron Holmes on 22/11/17.
//  Copyright © 2017 Ron Holmes. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, BCBeaconManagerDelegate {
    
    let BCKAppTokenKey = "BCKAppTokenKey"
    
    var beaconManager: BCBeaconManager?
    var allBeacons: [BCBeacon]?
    let appManageRegion = BCBeaconRegion()
    var autoScrollOn = true
    let formatter = DateFormatter()
    var data: [String]?
    var counter = 0
    var blueCatsRunning = false
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var stampImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("Widget loaded")
        
        // Do any additional setup after loading the view from its nib.
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        allBeacons = []
        data = []
        
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func startScanners() {
        print ("Starting scanners for widget")
      
//        guard let defaults = UserDefaults(suiteName: "group.com.bluecats.checkscanner") else {
//            textLabel.text = "Ummmm, defaults read was bad"
//            return
//        }

        if (!blueCatsRunning) {
//            guard let appToken = defaults.string(forKey: "BCKAppTokenKey") else {
//                startScanningOffline()
//                beaconManager = BCBeaconManager(delegate: self, queue: nil)
//                return
//            }
            
//            startScanning(withAppToken: appToken)
            startScanning(withAppToken: "e7c0a406-a6d1-457f-b529-c1572f8a9ece")
            beaconManager = BCBeaconManager(delegate: self, queue: nil)
            textLabel.text = "Scanning"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.startScanners()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    //MARK:- BlueCatsSDK
    func startScanning (withAppToken token:String) {
        print ("Starting bluecatssdk for widget")

        BlueCatsSDK.setOptions([BCOptionScanInBackground:true, BCOptionUseEnergySaverScanStrategy: false])

        BlueCatsSDK.startPurring(withAppToken: token, completion: { (BCStatus) -> Void in
            let appTokenVerificationStatus: BCAppTokenVerificationStatus = BlueCatsSDK.appTokenVerificationStatus()
            
            if appTokenVerificationStatus == .notProvided || appTokenVerificationStatus == .invalid {
            }
            
            if !BlueCatsSDK.isLocationAuthorized() {
                BlueCatsSDK.requestAlwaysLocationAuthorization()
            }
            
            if !BlueCatsSDK.isNetworkReachable() {
            }
            
            if !BlueCatsSDK.isBluetoothEnabled() {
            }
        })
        
        blueCatsRunning = BlueCatsSDK.status().rawValue == 1
    }
   
    func startScanningOffline () {
        
        BlueCatsSDK.setOptions([BCOptionScanInBackground:false, BCOptionUseEnergySaverScanStrategy: false])
        
        BlueCatsSDK.startPurring ({ (BCStatus) -> Void in
          
            if !BlueCatsSDK.isLocationAuthorized() {
                BlueCatsSDK.requestAlwaysLocationAuthorization()
            }
            
            if !BlueCatsSDK.isNetworkReachable() {
            }
            
            if !BlueCatsSDK.isBluetoothEnabled() {
            }
        })
        
        textLabel.text = "BlueCatsSDK Status: \(BlueCatsSDK.status().rawValue)"

        blueCatsRunning = true
    }
    
    //MARK:- BCBeaconManager methods
    
    func beaconManager(_ monitor: BCBeaconManager!, didRangeBeacons beacons: [BCBeacon]!) {
        guard allBeacons != nil else
        {
            return
        }
        
        for currentBeacon in beacons {
            let beaconAccuracy: Double = currentBeacon.accuracy
            
            var outputString = ""
            
            if beaconAccuracy <= 0.5 && beaconAccuracy > 0 {
                stamp(currentBeacon)
                outputString = "Stamped!"
            }
            else {
                self.stampImage.isHidden = true
//                outputString = currentBeacon.serialNumber ?? "000"
                outputString = beaconAccuracy < 100  && beaconAccuracy > 0 ? "\(currentBeacon.serialNumber ?? "__") is too far away" : "Scanning"
            }
            
            updateTextView(outputString)

        }
    }
    
    func beaconManager(_ monitor: BCBeaconManager!, didRangeIBeacons iBeacons: [BCBeacon]!) {
    }
    
    func beaconManager(_ monitor: BCBeaconManager!, didExitBeacons beacons: [BCBeacon]!) {
        guard allBeacons != nil else
        {
            return
        }
        
        let now = Date()
        
        print ("Beacons: \(String(describing: beacons))")
        
        for currentBeacon in beacons {
            let beaconMode:String = currentBeacon.beaconMode?.description ?? "Beacon"
            let beaconSerial = currentBeacon.serialNumber ?? "__"
            let outputString = "Exited \(beaconMode):\t\(beaconSerial)\t" + formatter.string(from: now) + "\r"
            updateTextView(outputString)
        }
        if (autoScrollOn) {
            scrollTextView()
        }
    }
    
    //MARK:- Text updates
    //MARK:- Convenience
    func updateTextView (_ text: String) {
        textLabel.text = text
//        DispatchQueue.main.async(execute: {
//            self.beaconTextView.text.append(text)
//        })
    }
    
    func scrollTextView () {
        DispatchQueue.main.async(execute: {
//            let bottom = NSMakeRange(self.beaconTextView.text.count - 1, 1)
//            self.beaconTextView.scrollRangeToVisible(bottom)
        })
    }

    //MARK:- Stamp Animation
    func stamp(_ beacon: BCBeacon) {
        let originalSize = stampImage.frame.size
        let originalOrigin = stampImage.frame.origin
        
        stampImage.frame.size = CGSize(width: 400.0, height: 400.0)
        stampImage.frame.origin = CGPoint(x:  self.view.frame.width / 2.0 - 50.0, y:  self.view.frame.height / 2.0 - 50.0)
        stampImage.isHidden = false

        UIView.animate(withDuration: 0.2, delay: 0.1, options: [.curveEaseIn],
                       animations: {
                        self.stampImage.frame.size = originalSize
                        self.stampImage.frame.origin = originalOrigin
        },
                       completion: nil
        )
    }
}
