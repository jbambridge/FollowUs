//
//  Posts.swift
//  FollowUs
//
//  Created by John Bambridge on 27/04/2017.
//  Copyright © 2017 LuBridge. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Post: MKPointAnnotation {
    
//    var title: String? = ""
    var content: String?  = ""
    var fullContent: String? = ""
    var link: String?  = ""
    var imageURL: String?  = ""
    var date: String?  = ""
    var author: String?  = ""
    var locationName: String? = ""
//    var coordinate: CLLocationCoordinate2D?
    
}

func buildWordpressURL(_ baseURL:String, number:Int)  -> URL?{
    let requestURL = baseURL + "?per_page=\(number)"
    if let url = URL(string: requestURL) {
        return url
    } else {
        print("Error: cannot create blog URL")
        return nil
    }
}

func parsePost(_ postData:[String:Any]) -> Post?{
    
    let post = Post()
    
//    guard let postLink = postData["link"] as? String else {
//        print("Could not get post link from JSON")
//        return nil
//    }

    guard let postLinkSection = postData["guid"] as? [String:Any] else {
        print("Could not find guid section")
        return nil
    }
    
    guard let postLink = postLinkSection["rendered"] as? String else {
        print("Could not find guid/rendered")
        return nil
    }
    
    post.link = postLink
    print("The link is: " + post.link!)
    
    guard let postTitle = postData["slug"] as? String else {
        print("Could not get post title from JSON")
        return nil
    }
    
    post.title = postTitle.stringByDecodingHTMLEntities.replacingOccurrences(of: "-", with: " ").capitalized
    print("The Post Title is:" + post.title!)
    
    guard let postContentDict = postData["excerpt"] as? [String:Any] else {
        print("Could not get post content dict from JSON")
        return nil
    }
    guard let postContent = postContentDict["rendered"] as? String else {
        print("Could not get post content from JSON")
        return nil
    }
    
    post.content = postContent.stringByDecodingHTMLEntities
//    print("The Post Content is:" + post.content!)
    
    guard let postFullContentDict = postData["content"] as? [String:Any] else {
        print("Could not get post full content dict from JSON")
        return nil
    }
    guard let postFullContent = postFullContentDict["rendered"] as? String else {
        print("Could not get post full content from JSON")
        return nil
    }
    
    post.fullContent = postFullContent.stringByDecodingHTMLEntities
//    print("The Post Full Content is:" + post.fullContent!)
    
    let contents = post.fullContent!
    
    post.locationName = searchString(contents, startString: "Location: ", endString: ".")
    post.imageURL = searchString(contents, startString: "src=\"", endString: "\"")
    
    
    guard let dateStringFull = postData["date"] as? String else {
        print("Unable to extact date")
        return nil
    }
    // date is in the format "2016-01-29T01:45:33+02:00",
    let dateString = dateStringFull.substring(to: dateStringFull.characters.index(dateStringFull.startIndex, offsetBy: 10))  // keep only the date part
    
    let parsingDateFormatter = DateFormatter()        // TODO: a static var
    parsingDateFormatter.dateFormat = "yyyy-MM-dd"
    let date = parsingDateFormatter.date(from: dateString)
    
    let printingDateFormatter = DateFormatter()       // TODO: a static var
    printingDateFormatter.dateStyle = .medium
    printingDateFormatter.timeStyle = .none
    
    post.date = printingDateFormatter.string(from: date!)
    print ("Date: " + post.date!)
    
    return post
}

func searchString(_ contents: String, startString: String, endString:String) -> String {
    var foundString = ""
    if let start = contents.range(of: startString)?.upperBound {
        if let end = contents.range(of: endString,
                                    options: NSString.CompareOptions.literal,
                                    range: start..<contents.endIndex,
                                    locale: nil)?.lowerBound{
            foundString = contents.substring(with: start..<end)
//            print("String found: " + foundString)
            
        }
    }
    return foundString
}
