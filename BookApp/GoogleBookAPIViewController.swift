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
    var genreData: [String] = []
    var selectedCategory: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        genreData = ["American Literature","Bangla" ,"Contemporary Fiction","Contemporary Non-Fiction" , "Cooking and Baking","Dictionaries 1" ,"Dictionaries 2","Encyclopedias","Health","Hindi Classics","Hindi Contemporary" ,"Hindi Encyclopedias" ,"Marathi","Music and Arts","Nature","Other World Literature" ,"Politics and Economics" ,"Pop Fiction" ,"Progressivism" ,"Russian","Science","Spiritualism","Travel","Young Fiction"]
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
