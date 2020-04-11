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
    var selectedCategory: String = ""
    
    @IBAction func uploadPressed(_ sender: Any) {
        if bookCoverImageView.image == nil {
            pushBookData(imageID: "", title: titleTextField.text!, author: authorTextField.text!, category: selectedCategory) { (message) in
                if message == "success" {
                    let alert = UIAlertController(title: "Success!", message: "The book was successfully uploaded.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error!", message: "The book was not uploaded. Please check your connection.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            handleUpload(image: bookCoverImageView.image!, title: titleTextField.text!, author: authorTextField.text!, category: selectedCategory) { (message) in
                if message == "success" {
                    let alert = UIAlertController(title: "Success!", message: "The book was successfully uploaded.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error!", message: "The book could not be uploaded. Please check your connection.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedCategory = genreData[0]
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
