//
//  RestaurantDetailViewController.swift
//  LetsEat
//
//  Created by Craig Clayton on 11/15/16.
//  Copyright © 2016 Craig Clayton. All rights reserved.
//

import UIKit
import MapKit
import LetsEatDataKit

class RestaurantDetailViewController: UITableViewController {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblCuisine: UILabel!
    @IBOutlet var lblHeaderAddress: UILabel!
    @IBOutlet var lblTableDetails: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var reviewsContainer: UIView!
    @IBOutlet var lblUser: UILabel!
    @IBOutlet var txtReview: UITextView!
    @IBOutlet var imgRating: UIImageView!
    @IBOutlet var btnHeart: UIBarButtonItem!
    @IBOutlet var noReviewsContainer: UIView!
    
    var selectedRestaurant:RestaurantItem?
    let manager = ReviewDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkReviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Segue.showReview.rawValue:
                showReview(segue: segue)
            case Segue.showAllReviews.rawValue:
                showAllReviews(segue: segue)
            default:
                print("Segue not added \(segue.identifier)")
            }
        }
    }
    
    
    func initialize() {
        setupLabels()
        setupMap()
    }
    
    func setupLabels() {
        guard let restaurant = selectedRestaurant else {
            return
        }
        
        if let name = restaurant.name {  lblName.text = name }
        if let cuisine = restaurant.cuisine {  lblCuisine.text = cuisine }
        if let address = restaurant.address {
            lblAddress.text = address
            lblHeaderAddress.text = address
        }
        
        lblTableDetails.text = "Table for 7, tonight at 10:00 PM"
    }
    
    func setupMap() {
        mapView.delegate = self
        guard let annotation = selectedRestaurant?.annotation, let long = annotation.longitude, let lat = annotation.latitude else { return }
        
        let location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotations([annotation])
    }
    
    func checkReviews() {
        if let id = selectedRestaurant?.restaurantID {
            manager.fetchReview(by: id)
        }
        
        let count = manager.numberOfItems()
        
        if count > 0 {
            noReviewsContainer.isHidden = true
        }
        
        let item = manager.getLatestReview()
        lblUser.text = item.name
        txtReview.text = item.customerReview
        if let rating = item.rating { imgRating.image = UIImage(named: Rating.image(rating: rating)) }
    }
    
    func showReview(segue:UIStoryboardSegue) {
        if let viewController = segue.destination as? CreateReviewViewController {
            
            viewController.selectedRestaurantID = selectedRestaurant?.restaurantID 
        }
    }
    
    func showAllReviews(segue:UIStoryboardSegue) {
        if let viewController = segue.destination as? ReviewListViewController {
            
            viewController.selectedRestaurantID = selectedRestaurant?.restaurantID
        }
    }
}


extension RestaurantDetailViewController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "custompin"
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        var annotationView:MKAnnotationView?
        
        if let customAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView = customAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "custom-annotation")
        }
        
        return annotationView
    }
}




















