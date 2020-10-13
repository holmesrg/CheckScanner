//
//  ViewController.swift
//  CheckScanner
//
//  Created by Ron Holmes on 25/10/17.
//  Copyright © 2017 Ron Holmes. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, BCBeaconManagerDelegate {
    
    let BCKAppTokenKey = "BCKAppTokenKey"
    
    var beaconManager: BCBeaconManager?
    var allBeacons: [BCBeacon]?
    let appManageRegion = BCBeaconRegion()
    var autoScrollOn = true
    let formatter = DateFormatter()
    var data: [String]?
    var blueCatsRunning = false
    
    @IBOutlet weak var beaconTextView: UITextView!
    @IBOutlet weak var autoScrollButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
    //MARK:- View methods
    
    override func viewDidLoad() {
        print ("Entered Viewcontroller")
        super.viewDidLoad()
        
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        autoScrollButton.layer.cornerRadius = 8
        autoScrollButton.backgroundColor = (autoScrollOn) ? UIColor.red : UIColor.green
        autoScrollButton.setTitle((autoScrollOn) ? "Stop Autoscroll" : "Start Autoscroll", for: .normal)
        autoScrollButton.setTitleColor((autoScrollOn) ? UIColor.white : UIColor.black, for: .normal)
        shareButton.layer.cornerRadius = 8
        
        allBeacons = []
        data = []
        updateTextView("Starting\r--------\r\r")

        self.registerForDeviceLockNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        guard let defaults = UserDefaults(suiteName: "group.com.bluecats.checkscanner") else {
            print("Couldn't read defaults")
            return
        }
        
        guard let appToken = defaults.string(forKey: BCKAppTokenKey) else {
            performSegue(withIdentifier: "SetAppToken", sender: self)
            return
        }
        
        if (!blueCatsRunning) {
            startScanning(withAppToken: appToken)
            beaconManager = BCBeaconManager(delegate: self, queue: nil)
            //        appManageRegion.proximityUUIDString = "61687109-905F-4436-91F8-E602F514C96D"
            //        beaconManager?.startMonitoringBeaconRegion(appManageRegion)
            //
        }
    }
    
    func registerForDeviceLockNotification () {
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
            observer, // observer
            { (_, observer, name, _, _) -> Void in
                // Swift messing about to call C pointers of varying object types.
                let mySelf = Unmanaged<ViewController>.fromOpaque(
                    _:observer!).takeUnretainedValue()
                mySelf.displayStatusChanged(name: "\rScreen Locked\r-------------\r")
            },
            "com.apple.springboard.lockcomplete" as CFString, // event name
            nil, // object
            CFNotificationSuspensionBehavior.deliverImmediately)
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
            observer, // observer
            { (_, observer, name, _, _) -> Void in
                // Swift messing about to call C pointers of varying object types.
                let mySelf = Unmanaged<ViewController>.fromOpaque(
                    _:observer!).takeUnretainedValue()
                mySelf.displayStatusChanged(name: "\rLocked/Unlocked\r---------------\r")
            }, // callback
            "com.apple.springboard.lockstate" as CFString, // event name
            nil, // object
            CFNotificationSuspensionBehavior.deliverImmediately)
    }
    
    func displayStatusChanged (name: String?) {
        let outputString = "\r----------------------\rDisplay Status Changed \(name ?? "__")\r"
        beaconTextView.text.append(outputString)
        data?.append(outputString)
    }
    
    //MARK:- BCBeaconManager methods
    
    func beaconManager(_ monitor: BCBeaconManager!, didRangeBeacons beacons: [BCBeacon]!) {
        guard allBeacons != nil else
        {
            return
        }
        
        let now = Date()
        
        for currentBeacon in beacons {
            if (!allBeacons!.contains(currentBeacon)) {
                allBeacons?.append(currentBeacon)
            }
            let beaconMode:String = currentBeacon.beaconMode?.description ?? "Beacon"
            let beaconSerial = currentBeacon.serialNumber ?? "__"
            let outputString = "Ranged \(beaconMode):\t\(beaconSerial)\t" + formatter.string(from: now) + "\r"
            updateTextView(outputString)
            data?.append(outputString)
        }
        if (autoScrollOn) {
            scrollTextView()
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
        
        for currentBeacon in beacons {
            let beaconMode:String = currentBeacon.beaconMode?.description ?? "Beacon"
            let beaconSerial = currentBeacon.serialNumber ?? "__"
            let outputString = "Exited \(beaconMode):\t\(beaconSerial)\t" + formatter.string(from: now) + "\r"
            updateTextView(outputString)
            data?.append(outputString)
        }
        if (autoScrollOn) {
            scrollTextView()
        }
    }
    
    //MARK:- Button Actions
    @IBAction func startStopAutoScrolling(_ sender: Any) {
        autoScrollOn = !autoScrollOn
        autoScrollButton.setTitle((autoScrollOn) ? "Stop Autoscroll" : "Start Autoscroll", for: .normal)
        autoScrollButton.backgroundColor = (autoScrollOn) ? UIColor.red : UIColor.green
        autoScrollButton.setTitleColor((autoScrollOn) ? UIColor.white : UIColor.black, for: .normal)
    }
    
    @IBAction func shareResults(_ sender: Any) {
        // text to share comes from the data array
        guard let text = data.flatMap({$0})?.joined() else {
            return
        }
        
        // stop scrolling if it's started
        if (autoScrollOn) {
            startStopAutoScrolling(self)
        }
        
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
        
        // restart scrolling
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, errorCode: Error?) in
            if (!self.autoScrollOn) {
                self.startStopAutoScrolling(self)
            }
        }
    }

    //MARK:- Convenience
    func updateTextView (_ text: String) {
        DispatchQueue.main.async(execute: {
            self.beaconTextView.text.append(text)
        })
    }
    
    func scrollTextView () {
        DispatchQueue.main.async(execute: {
            let bottom = NSMakeRange(self.beaconTextView.text.count - 1, 1)
            self.beaconTextView.scrollRangeToVisible(bottom)
        })
    }
    
    //MARK:- BlueCatsSDK
    func startScanning (withAppToken token:String) {
        
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
        
        blueCatsRunning = true
    }

    
    //MARK:- Tidy up
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
}

