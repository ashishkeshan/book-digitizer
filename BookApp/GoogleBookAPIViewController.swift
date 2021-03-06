//
//  GoogleBookAPIViewController.swift
//  BookApp
//
//  Created by Ashish Keshan on 4/5/20.
//  Copyright © 2020 Ashish Keshan. All rights reserved.
//

import UIKit

class GoogleBookAPIViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var genrePickerView: UIPickerView!
    
    var book: GoogleAPIBook?
    var selectedCategory: String = ""
    @IBAction func uploadPressed(_ sender: Any) {
        
        if areEqualImages(img1: bookCoverImageView.image!, img2: UIImage(named: "noCover")!) {
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
        titleTextField.text = book!.title
        authorTextField.text = book!.author
        bookCoverImageView.load(url: URL(string: book!.imageURL)!)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
