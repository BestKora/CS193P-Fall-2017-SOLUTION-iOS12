//
//  GalleryTableViewCell.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 01/08/2018.
//  Copyright © 2018 Stanford University. All rights reserved.
//

import UIKit

class GalleryTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!{
        didSet {
            let tap = UITapGestureRecognizer(target: self,
                                             action: #selector(beginEditing))
            tap.numberOfTapsRequired = 2
            addGestureRecognizer(tap)
            nameTextField.delegate = self
        }
    }
    
    @objc func beginEditing() {
        nameTextField.isEnabled = true
        nameTextField.becomeFirstResponder()
    }
    
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isEnabled = false
        textField.resignFirstResponder()
        return true
    }
    
    var resignationHandler:  (() -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
}
