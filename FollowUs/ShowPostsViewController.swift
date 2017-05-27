//
//  ShowPostsViewController.swift
//  FollowUs
//
//  Created by John Bambridge on 28/04/2017.
//  Copyright © 2017 LuBridge. All rights reserved.
//

import UIKit
import AlamofireImage
import MapKit
import SafariServices


class ShowPostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate, MKMapViewDelegate {
    
    var blogURL: String = ""
    var blogTitle: String = ""
    var posts: [Post] = []
    var regionRadius: CLLocationDistance = 5000
    var refreshControl = UIRefreshControl()
    var defaultLocation: CLLocation = CLLocation(latitude: settings.settingsDefaultLat, longitude: settings.settingsDefaultLong)
    
    var polyCoordinates: [CLLocationCoordinate2D] = []
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    
    var tableRatio: CGFloat = 0.4
    
    var pinAnnotationView:MKPinAnnotationView!
    
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    class CustomPointAnnotation: MKPointAnnotation {
        var postIndex: Int!
        var postIcon: String!
    }
    
    @IBAction func updatePostsView(_ sender: Any) {
        loadPosts()
        self.postsTableView.reloadData()
    }
    
    @IBAction func openInSafari(_ sender: Any) {
         UIApplication.shared.open(URL(string: posts[0].link!)!, options: [:], completionHandler: nil)
    }
    
    
    func loadPosts() {
        
        getPosts(blogURL, number: settings.settingsNumberOfPosts)
        activityIndicator.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ShowPostsViewController.handleRefresh), for: UIControlEvents.valueChanged)
        self.postsTableView?.addSubview(refreshControl)
        self.refreshControl.beginRefreshing()
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        activityIndicator.center = view.center;
        activityIndicator.startAnimating()
        self.title = blogTitle
        loadPosts()
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                tableRatio = tableRatio * 1.1
                tableHeightConstraint = tableHeightConstraint.setMultiplier(multiplier: tableRatio)
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                tableRatio = tableRatio * 0.9
                tableHeightConstraint = tableHeightConstraint.setMultiplier(multiplier: tableRatio)
            default:
                break
            }
        }
    }
    
    
    
    func updateMap() {
        for index in 0..<posts.count {
            let post = posts[index]
            print("Locatiopn: \(String(describing: post.locationName)) Titke \(String(describing: post.title))")
            if post.locationName != "" {
                
                localSearchRequest = MKLocalSearchRequest()
                localSearchRequest.naturalLanguageQuery = post.locationName
                localSearch = MKLocalSearch(request: localSearchRequest)
                localSearch.start { (localSearchResponse, error) -> Void in
                    
                    if localSearchResponse == nil{
                        return
                    }
                    
                    let pinID = "Pin"
                    let pointAnnotation = CustomPointAnnotation()
                    
                    pointAnnotation.title = post.title
                    pointAnnotation.subtitle = post.locationName
                    pointAnnotation.postIndex = index
                    pointAnnotation.postIcon = "bike"
                    
                    
                    let coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                    
                    pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                    
                    self.polyCoordinates.append(coordinate)
                    let polyLine = MKPolyline(coordinates: self.polyCoordinates, count: self.polyCoordinates.count)
                    self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)

                    
                    self.posts[index].coordinate = coordinate
                    
                    self.pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: pinID)
                    
                    self.mapView.centerCoordinate = pointAnnotation.coordinate
                    self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
                    
                    self.centerMapOnLocation(location: CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude))
                }
            }else {
                centerMapOnLocation(location: defaultLocation)
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinID = "Pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pinID)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: pinID)
            annotationView?.canShowCallout = true
        }
        else {
            annotationView?.annotation = annotation
        }
        
        let customPointAnnotation = annotation as? CustomPointAnnotation
        
        // Resize image
        let pinImage = UIImage(named: (customPointAnnotation?.postIcon)!)
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        annotationView?.image = resizedImage
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! CustomPointAnnotation
        displayPostInSafari(postURL: posts[annotation.postIndex!].link!)
    }
    
    func handleRefresh(sender:AnyObject) {
        loadPosts()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self) {
            // draw the track
            let polyLine = overlay
            let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
            polyLineRenderer.strokeColor = UIColor.blue
            polyLineRenderer.lineWidth = 2.0
            
            return polyLineRenderer
        }
        
        return MKPolylineRenderer()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        var centre = posts.first?.coordinate
        for index in 1..<posts.count {
            
            let point = posts[index].coordinate
            let tempCentre = posts.first?.coordinate
            let pointCL = CLLocation(latitude: point.latitude, longitude: point.longitude)
            let centreCL = CLLocation(latitude: (tempCentre?.latitude)!, longitude: (tempCentre?.longitude)!)
            let distance = centreCL.distance(from: pointCL)
            print("Distance \(distance)")
            if distance < 5000 { regionRadius = 5000 } else {
                regionRadius = distance
                centre = midPoint(pointA: tempCentre!, pointB: point)
            }
            
        }
        let centreCL: CLLocation? = CLLocation(latitude: centre?.latitude ?? 0.0, longitude: centre?.longitude ?? 0.0)
        if let coord = centreCL?.coordinate {
            
            let mapCoord = MKCoordinateRegionMakeWithDistance(coord, regionRadius * 2.0, regionRadius * 2.0)
            
            mapView.setRegion(mapCoord, animated: true)
        }
    }
    
    
    func midPoint(pointA: CLLocationCoordinate2D, pointB: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let pointALat = toRadians(latlongDegs: pointA.latitude)
        let pointALong = toRadians(latlongDegs: pointA.longitude)
        let pointBLat = toRadians(latlongDegs: pointB.latitude)
        let pointBLong = toRadians(latlongDegs: pointB.longitude)
        
        let dLon = pointBLong - pointALong;
        let bx = cos(pointBLat) * cos(dLon)
        let by = cos(pointBLat) * sin(dLon)
        let centreLat = atan2(sin(pointALat) + sin(pointBLat), sqrt((cos(pointALat) + bx) * (cos(pointALat) + bx) + by*by))
        let centreLong = pointALong + atan2(by, cos(pointALat) + bx)
        
        let centre = CLLocationCoordinate2D(latitude: toDegrees(latlongRads: centreLat), longitude: toDegrees(latlongRads: centreLong))
        
        return centre
    }
    
    func toRadians(latlongDegs: Double) -> Double {
        return (latlongDegs * Double.pi/180)
    }
    
    func toDegrees(latlongRads: Double) -> Double {
        return (latlongRads * 180/Double.pi)
    }
    
    func getPosts(_ blogURL:String, number:Int) {
        
        posts = []
        activityIndicator.startAnimating()
        
        guard let url = buildWordpressURL(blogURL, number: number) else { return }
        print("Posts URL " + blogURL)
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {(data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET for \(blogURL)")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            print(responseData)
            
            // parse the result as JSON, since that's what the API provides
            do {
                guard let jsonArray: [[String: AnyObject]] = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [[String: AnyObject]] else {
                    print("error trying to convert data to JSON")
                    return
                }
                print("Posts found: \(jsonArray.count)")
                
                for counter in 0..<jsonArray.count {
                    print("Post to parse: \(jsonArray[counter])")
                    if let newPost = parsePost(jsonArray[counter]) {
                        self.posts.insert(newPost, at: counter)
                    }
                }
                
                
                DispatchQueue.main.async {
                    if self.refreshControl.isRefreshing
                    {
                        self.refreshControl.endRefreshing()
                    }
                    self.postsTableView.reloadData()
                    self.updateMap()
                    self.activityIndicator.stopAnimating()                }
            }
                
            catch  {
                print("error trying to convert data to JSON")
                DispatchQueue.main.async {
                    self.postsTableView.reloadData()
                    self.activityIndicator.stopAnimating()                }
                return
            }
        }
        task.resume()
    }
    
    
    
    
    // Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        if posts.count > 0 {
            print(posts[indexPath.row].imageURL ?? "Default")
            cell.postTitle?.text = posts[indexPath.row].title
            cell.postContent?.text = posts[indexPath.row].content?.html2String
            cell.postDate?.text = posts[indexPath.row].date
            cell.imageURL = posts[indexPath.row].imageURL!
            print("postVC:" + posts[indexPath.row].imageURL!)
        }
        return cell
    }
    
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // self.performSegue(withIdentifier: "ShowBlog", sender: self)
        let postIndex = postsTableView.indexPathForSelectedRow?.row
        displayPostInSafari(postURL: posts[postIndex!].link!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    func displayPostInSafari(postURL: String) {
        let url = URL(string: postURL)
        let safariVC = SFSafariViewController(url: url!, entersReaderIfAvailable: true)
        safariVC.delegate = self
        present(safariVC, animated: true)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
