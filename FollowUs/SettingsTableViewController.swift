//
//  SettingsTableViewController.swift
//  FollowUs
//
//  Created by John Bambridge on 01/05/2017.
//  Copyright © 2017 LuBridge. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var numPosts: UILabel!
    @IBOutlet weak var defLatitude: UITextField!
    @IBOutlet weak var defLongitude: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSettings()
        
        numPosts.text = String(settings.settingsNumberOfPosts)
        defLatitude.text = String(settings.settingsDefaultLat)
        defLongitude.text = String(settings.settingsDefaultLong)
        
        stepper.tintColor = UIColor.red
        stepper.value = Double(settings.settingsNumberOfPosts)
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    
    
    @IBAction func changeNum(_ sender: UIStepper) {
        let num = Int(sender.value)
        numPosts.text = "\(num)"
        settings.settingsNumberOfPosts = num
        FollowUs.saveSettings()
    }
    
    @IBAction func changeLat(_ sender: Any) {
        if let defaultLat =  defLatitude.text  {
            settings.settingsDefaultLat = Double(defaultLat) ?? 51.7527
            FollowUs.saveSettings()
        }
        
    }
    
    @IBAction func changeLong(_ sender: Any) {
        if let defaultLong =  defLongitude.text  {
            settings.settingsDefaultLong = Double(defaultLong) ?? -0.3394
            FollowUs.saveSettings()
        }
    }
    
    @IBAction func resetToDefaults(_ sender: Any) {
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            settings.settingsNumberOfPosts = 2
        case .pad:
            settings.settingsNumberOfPosts = 6
        default:
            settings.settingsNumberOfPosts = 2
        }
        numPosts.text = String(settings.settingsNumberOfPosts)
        defLatitude.text = String(51.7527)
        defLongitude.text = String(-0.3394)
        FollowUs.saveSettings()
        
    }
    
}
