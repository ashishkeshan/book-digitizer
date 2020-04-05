//
//  GoodreadsBookAPIViewController.swift
//  BookApp
//
//  Created by Ashish Keshan on 4/5/20.
//  Copyright © 2020 Ashish Keshan. All rights reserved.
//

import UIKit

class GoodreadsAPIViewController: UIViewController {

    
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    
    var book: GoodreadsAPIBook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.text = book!.title
        authorTextField.text = book!.author
        bookCoverImageView.load(url: URL(string: book!.imageURL)!)
        // Do any additional setup after loading the view.
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
