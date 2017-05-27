//
//  PostTableViewCell.swift
//  FollowUs
//
//  Created by John Bambridge on 29/04/2017.
//  Copyright © 2017 LuBridge. All rights reserved.
//

import UIKit
import AlamofireImage

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var postDate: UILabel!
    
    var imageURL:String = "" {
        didSet {
            updateUI()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        updateUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func updateUI() {
        if let url = URL(string: imageURL) {
            let placeholderImage = UIImage(named: "placeholder")!
            print("Image URL in cell \(url)")
            postImageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
        }
        
    }
    
}
