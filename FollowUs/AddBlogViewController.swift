//
//  AddBlogViewController.swift
//  FollowUs
//
//  Created by John Bambridge on 28/04/2017.
//  Copyright © 2017 LuBridge. All rights reserved.
//

import UIKit

class AddBlogViewController: UIViewController {
    
    @IBOutlet weak var blogNameTF: UITextField!
    @IBOutlet weak var blogURLTF: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveBlog(_ sender: Any) {
        if let name = blogNameTF.text, let url = blogURLTF.text {
            let fullURL = url+"/wp-json/wp/v2"
            if validateURL(fullURL) {
                addBlog(name, URL: url, fav: false)
                errorMessage.text = "Saved"
                _ = navigationController?.popViewController(animated: true)
            } else {
                errorMessage.text = "Invalid URL.  Not saved"
            }
            
        }
    }
    
    func validateURL(_ url: String) -> Bool {
        guard NSURL(string: url) != nil else {return false}
//        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let regEx = "((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: url)
    }
}
