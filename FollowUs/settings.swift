//
//  settings.swift
//  FollowUs
//
//  Created by John Bambridge on 30/04/2017.
//  Copyright © 2017 LuBridge. All rights reserved.
//

import Foundation

struct Settings {
    var settingsNumberOfPosts: Int = 2
    var settingsDefaultLat: Double = 51.7527
    var settingsDefaultLong: Double = -0.3394
}

var settings = Settings()

func loadSettings() {
    let defaults = UserDefaults.standard
    if let settingsNumberOfPosts = defaults.object(forKey: "Blogs.Number") as? Int {
        settings.settingsNumberOfPosts = settingsNumberOfPosts
    }
    if let settingsDefaultLat = defaults.object(forKey: "Blogs.Lat") as? Double {
        settings.settingsDefaultLat = settingsDefaultLat
    }
    if let settingsDefaultLong = defaults.object(forKey: "Blogs.Long") as? Double {
        settings.settingsDefaultLong = settingsDefaultLong
    }
}

func saveSettings() {
    let defaults = UserDefaults.standard
    defaults.set(settings.settingsNumberOfPosts, forKey: "Blogs.Number")
    defaults.set(settings.settingsDefaultLat, forKey: "Blog.Lat")
    defaults.set(settings.settingsDefaultLong, forKey: "Blog.Long")
}
