//
//  Blogs.swift
//  FollowUs
//
//  Created by John Bambridge on 28/04/2017.
//  Copyright © 2017 LuBridge. All rights reserved.
//

import Foundation

struct Blog {
    var blogTitle: String?
    var blogURL: String?
    var blogFavorite: Bool?
}

var blogs : [Blog] = []
let apiIntro = "https://public-api.wordpress.com/wp/v2/sites/"
let apiTail = "/posts"

func resetBlogs() {
    print("Resetting blogs")
    blogs = []
    addBlog("Where's The Pub - John & Jay", URL: "wheresthepub.com", fav: true)
    addBlog("Nomad Russ", URL: "nomadruss.me", fav: false)
    addBlog("Snowmads", URL: "snowmads.blog", fav: false)
    addBlog("The Adventures of Fadr", URL: "theadventuresofadr.com", fav: false)
    
}

func addBlog(_ title: String, URL: String, fav: Bool) {
    print("Adding new blog" + title)
    var newBlog = Blog()
    newBlog.blogTitle = title
    newBlog.blogFavorite = fav
    let fullURL = apiIntro + URL + apiTail
    newBlog.blogURL = fullURL
    blogs.append(contentsOf: [newBlog])
    saveBlogs()
}

func saveBlogs() {
    print("Saving blogs")
    let defaults = UserDefaults.standard
    
    var blogArray: [[String:Any]] = []
    for blog in blogs {
        let blogDict = ["blogTitle": blog.blogTitle ?? "",
                        "blogURL" : blog.blogURL ?? "",
                        "blogFavorite" : blog.blogFavorite!] as [String : Any]
        blogArray.append(blogDict)
    }
    defaults.set(blogArray, forKey: "Blogs")
}

func loadBlogs() {
    
    blogs = []
    let defaults = UserDefaults.standard
    if let blogArray: [[String:Any]] = (defaults.object(forKey: "Blogs") as? [[String:Any]]) {
    print("Loading blogs from store")
        for blogDict in blogArray {
            var newBlog = Blog()
            
            newBlog.blogTitle = blogDict["blogTitle"] as? String
            newBlog.blogFavorite = blogDict["blogFavorite"] as? Bool
            newBlog.blogURL = blogDict["blogURL"] as? String
            blogs.append(contentsOf: [newBlog])
        }
    } else {
        print("Loading blogs as reset")
        resetBlogs()
    }
    
    
}
