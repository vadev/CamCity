//
//  ViewController.swift
//  CamCity
//
//  Created by Vartan on 8/7/17.
//  Copyright © 2017 Vartan. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    //Outlets
     
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var pullUpView: UIView!
    
    
    // CLLocation Manager
    var locationManger = CLLocationManager()
    
    let autorizationStatus = CLLocationManager.authorizationStatus()
    
    //map region
    let regionRadius: Double = 1000
    
    //property for our screen sizes.
    
    var screenSize = UIScreen.main.bounds
    
    
    //our spinner
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    // -----------------------------------------------
    //                ******* TIP *****
    // To Create Collection View Programmatically, you need:
    //  var flowLayout = UICollectionViewFlowLayout()
   // -----------------------------------------------
    
    
    // The collection view.
    var flowLayout = UICollectionViewFlowLayout()
     var collectionView: UICollectionView?
    
    
    // An image array
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //enable to use our map on view controller.
        mapView.delegate = self
        locationManger.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        // the collection view instantated
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        //Register the cell.
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        
        pullUpView.addSubview(collectionView!) //unwrap
        
    }
    
    // Function for double tapping
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    // Swipe down the view Function
    func addSwipe() {
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        //settings for swipe.
        swipe.direction = .down
        
        pullUpView.addGestureRecognizer(swipe)
        
    }
    
    // Nice animation animate the pull up for our view.
    func animateViewUp() {
        
        mapViewBottomConstraint.constant = 300
        //animates our view up.
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    // Nice animation animate the pull down for our view.
    @objc func animateViewDown() {
       cancelAllSessions()
        mapViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            
       self.view.layoutIfNeeded()
        }
        
    }
    
    //Function to add our spinner, for users to know that images are loading.
    func addSpinner() {
        //Instantite the spinner
        spinner = UIActivityIndicatorView()
        //position spinner on the view.
        // order of operation comes in with our CGPOINT X-Value, and Y-Value.
        
        // so, for our y-axis: the middle is 300 so half of it is 150.
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2) , y: 150)
        // our spinner style
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
        
    }
    
    // A function to remove our spinner.
    func removeSpinner() {
        var flowLayout = UICollectionViewFlowLayout()
        //check the spinner.
        if spinner != nil {
            //if theres an spinner, then it will remove.
            spinner?.removeFromSuperview()
            
        }
    
    }
    
    // A function for our UI-Label
    func addProgressLbl() {
        //our label called as ui label.
        progressLbl = UILabel()
        // Label size.
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        //font name
        progressLbl?.font =  UIFont(name: "Avenir Next", size: 14)
        //font color
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        // text alignement
        progressLbl?.textAlignment = .center
       //add to pullupVIew
        collectionView?.addSubview(progressLbl!)
    
    }
    
    // Now, a function to remove the progress Label.
    func removeProgressLbl() {
        
        if progressLbl != nil {
            
            progressLbl?.removeFromSuperview()
            
        }
        
        
    }
    
    
  
    // Action for our Center button, to go to current location.
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    
    
        //check authorization status.
        if autorizationStatus == .authorizedAlways || autorizationStatus == .authorizedWhenInUse {
            
            centerMapOnUserLocation()
            
        }
        
        
    }
    

}
extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Dont drop a pin on USers Current location.
        if annotation is MKUserLocation {
            return nil
        }
        // Customize our pin
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier:"droppablePin")
        //set the pin color to orange
        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
        
        
        
    }
    // A Function to taking the user to its Current Location.
    func centerMapOnUserLocation() {
        
        // coordinating the users location a little close.
        guard let coordinate = locationManger.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    // Function, by double tapping to put a pin on the map.
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancelAllSessions()
        
        imageUrlArray = []
        imageArray = []
        collectionView?.reloadData()
        
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
      
        //creating a touch point for our pin.
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // instance of our droppablePin
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
       //now, center the pin on userlocation.
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            //print(self.imageUrlArray)
            if finished {
            // to know we are done downloading the images.
                self.retrieveImages(handler: { (finished) in
                    if finished {
                    // then hide the spinner,
                    //hide the label and
                    //reload the collection view.
                    self.removeSpinner()
                    self.removeProgressLbl()
                   self.collectionView?.reloadData()
                }
            })
        }
    }
        
}
 
    // Function that removes the pin after it drops the new pin.
    func removePin() {
        
        //show one pin at a time
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    // Getting the URLs
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping
        (_ status: Bool) -> ()) {
        //this makes the image empty. lets say if you drop a new pin, we want to clear the images
        // and add a new images.
        imageUrlArray = []
        //make request and do something with that request.
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            // parsing out our data in json arrays to get in photos dictionary
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            //gets the photo dictionary
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray {
                //the post url for our image url
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            //our handler to escape telling us that we have downloaded all urls.
            handler(true)
         }
      }
  
   // Getting The Images
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
    
        // to get notified that the images has been downloaded.
        imageArray = []
        
        for url in imageUrlArray {
            // Using AlamofireImage to download those images.
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                // everytime that progress label will update, of how many images downloaded.
                self.progressLbl?.text = "\(self.imageArray.count)_/40 IMAGES DOWNLOADED"
                
                //check if our amount of images matches the urls downloading.
                if self.imageArray.count == self.imageUrlArray.count {
                    
                    //then use our handler, if the images are downloaded and done.
                    handler(true)
                    
                    
                }
                
                
            })
            
        }
    }
        // Function when user swipe down, it will cancel the downloading of the images.
        func cancelAllSessions() {
            
            //access a singelton from Alamofire.
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
                
                //Cancel every instance of download Data and Session Data task.
                // its all stored in arrays **
                
                sessionDataTask.forEach({ $0.cancel() })
                downloadData.forEach({ $0.cancel() })
                
                
            }
       
            
        }
    
    }
 

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        //checking if our app is authorize.
        if autorizationStatus == .notDetermined {
            locationManger.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
       centerMapOnUserLocation()
        
    }
        
}

// Extensions

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //  number of items in an array.
        
        // we are counting the image we want to show in collection view.
        return imageArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // this will crash. because it will return an empty collection view cell.
        //return UICollectionViewCell()
        
        
        // if its fails to load the images, then show an empty cell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
       
        // find the image from our image array.
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
       
        return cell
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // getting the storyboard View Controller and cast it as PopVC.
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
        // calling popVC to bring out that image path of the selected image.
       popVC.initData(forImage: imageArray[indexPath.row])
        //present the view controller.
        present(popVC, animated: true, completion: nil)
        
        
        
    }
    
    
}











