//
//  PopVC.swift
//  CamCity
//
//  Created by Vartan on 8/7/17.
//  Copyright © 2017 Vartan. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

        // Outlets
    
    @IBOutlet weak var popImageView: UIImageView!
    
     
    
    var passedImage: UIImage!
    
    // A function that pass in an image until its initialize it.
    func initData(forImage image: UIImage) {
        // we will pass in an image, then set it as image
        self.passedImage = image
      }
    
     override func viewDidLoad() {
        super.viewDidLoad()
        //when view loads, we can pass the image to our popVC.
        popImageView.image = passedImage
       addDoubleTap()
    }

    
    // A function where the user double taps on the image and it closes the image.
    func addDoubleTap() {
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        // our double taps.
        doubleTap.numberOfTapsRequired = 2
        //set the delegate
        doubleTap.delegate = self
        //add the gesture to the view.
        view.addGestureRecognizer(doubleTap)
        
        
    }
   
    @objc func screenWasDoubleTapped() {
        
        dismiss(animated: true, completion: nil)
        
        
    }
    

}
