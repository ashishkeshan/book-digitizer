//
//  ManualSelectViewController.swift
//  BookApp
//
//  Created by Ashish Keshan on 4/5/20.
//  Copyright © 2020 Ashish Keshan. All rights reserved.
//

import UIKit
import MobileCoreServices

class ManualSelectViewController: UIViewController, UIImagePickerControllerDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIPickerViewDelegate {

    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var takePictureLabel: UILabel!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var genrePickerView: UIPickerView!
    var genreData: [String] = []
    var selectedCategory: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        genreData = ["American Literature","Bangla" ,"Contemporary Fiction","Contemporary Non-Fiction" , "Cooking and Baking","Dictionaries 1" ,"Dictionaries 2","Encyclopedias","Health","Hindi Classics","Hindi Contemporary" ,"Hindi Encyclopedias" ,"Marathi","Music and Arts","Nature","Other World Literature" ,"Politics and Economics" ,"Pop Fiction" ,"Progressivism" ,"Russian","Science","Spiritualism","Travel","Young Fiction"]
        genrePickerView.dataSource = self
        genrePickerView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        bookCoverImageView.isUserInteractionEnabled = true
        bookCoverImageView.addGestureRecognizer(tapGestureRecognizer)
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genreData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genreData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = genreData[row]
    }
    
    
    @IBAction func nextPressed(_ sender: Any) {
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // make sure there is an image before seguing
        if let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            bookCoverImageView.image = pickedImage
            cameraImageView.isHidden = true
            takePictureLabel.isHidden = true
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let myAlert = UIAlertController(title: "Select Image From", message: "Please select an option.", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a Photo", style: .default) { (alert) in
            if UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerController.SourceType.camera) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerController.SourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                
                self.present(imagePicker, animated: true,
                             completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        myAlert.addAction(cameraAction)
        myAlert.addAction(cancelAction)
        myAlert.popoverPresentationController?.sourceView = self.view
        myAlert.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        myAlert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        self.present(myAlert, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
