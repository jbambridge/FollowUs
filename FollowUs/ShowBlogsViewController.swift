//
//  ShowBlogsViewController.swift
//  FollowUs
//
//  Created by John Bambridge on 28/04/2017.
//  Copyright © 2017 LuBridge. All rights reserved.
//

import UIKit

class ShowBlogsViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var blogTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        blogTableView.delegate = self
        blogTableView.dataSource = self
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ShowBlogsViewController.longPress(_:)))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.blogTableView.addGestureRecognizer(longPressGesture)
        blogTableView.isEditing = false
        editButton.title = "Edit"
        loadBlogs()
        loadSettings()
        updateUI()
        
        self.performSegue(withIdentifier: "ShowFavorite", sender: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        print("Gesture recognised")
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.ended {
            
            print("Starting wipe")
            let touchPoint = longPressGestureRecognizer.location(in: self.blogTableView)
            var counter = 0
            for _ in blogs {
                blogs[counter].blogFavorite = false
                counter = counter + 1
            }
            print("Adding fav")
            if let indexPath = blogTableView.indexPathForRow(at: touchPoint) {
                blogs[indexPath.row].blogFavorite = true
                print("Fav updated for row \(indexPath.row)")
            }
            saveBlogs()
            updateUI()
        }
        
    }
    
    
    // Table Delegate Methods
    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        blogTableView.isEditing = !blogTableView.isEditing
        if !blogTableView.isEditing {
            editButton.title = "Edit"
        } else {
            editButton.title = "Done"
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath)
        cell.textLabel?.text = blogs[indexPath.row].blogTitle
        
        if blogs[indexPath.row].blogFavorite! {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell number: \(indexPath.row)!")
        self.performSegue(withIdentifier: "ShowPost", sender: self)
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            blogs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    
    // Override to support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedObject = blogs[fromIndexPath.row]
        blogs.remove(at: fromIndexPath.row)
        blogs.insert(movedObject, at: to.row)
    }
    
    
    
    //     // Override to support conditional rearranging of the table view.
    //      func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    //     // Return false if you do not want the item to be re-orderable.
    //     return true
    //     }
    //
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPost" {
            let showPostsViewController: ShowPostsViewController = segue.destination as! ShowPostsViewController
            let blogIndex = blogTableView.indexPathForSelectedRow?.row
            showPostsViewController.blogURL = blogs[blogIndex!].blogURL!
            showPostsViewController.blogTitle = blogs[blogIndex!].blogTitle!
            print("Segue to:" + blogs[blogIndex!].blogURL!)
        } else if segue.identifier == "ShowFavorite" {
            let showPostsViewController: ShowPostsViewController = segue.destination as! ShowPostsViewController
            for blog in blogs {
                if blog.blogFavorite! {
                    showPostsViewController.blogURL = blog.blogURL!
                    showPostsViewController.blogTitle = blog.blogTitle!
                }
            }
        } else if segue.identifier == "ShowSettings" {
            
        }
    }
    
    // UI
    
    @IBAction func resetButton(_ sender: Any) {
        let alert = UIAlertController(title: "About to reset to default list of blogs", message: "Any blogs you have added will be deleted.  Are you sure?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { action in
            resetBlogs()
            self.updateUI()
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .default) { action in})
        alert.modalPresentationStyle = .popover
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        self.present(alert, animated: true)
        
    
}

func updateUI() {
    print("UPdateing UI")
    self.blogTableView.reloadData()
    
}
}

