//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Denis Bokov on 20.10.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
    
    @IBAction func idTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
}
