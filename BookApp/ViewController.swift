//
//  ViewController.swift
//  BookApp
//
//  Created by Ashish Keshan on 4/4/20.
//  Copyright © 2020 Ashish Keshan. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import SwiftyXMLParser

class ViewController: UIViewController {
        
    
    
    var countAPICallComplete: Int = 0
    
    @IBAction func handleScannerPush(_ sender: Any, forEvent event: UIEvent) {
      performSegue(withIdentifier: "scanBookSegue", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanBookSegue" {
             let vc = segue.destination as! BarcodeScannerViewController
             vc.codeDelegate = self
             vc.errorDelegate = self
             vc.dismissalDelegate = self
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()

        self.navigationItem.title = "Detect Barcode from Camera"
    }

    override func viewDidAppear(_ animated: Bool) {
        countAPICallComplete = 0
        super.viewDidAppear(animated)

        
    }
    
    
    func getBookInfoFromGoogleAPI(isbn: String, completionHandler: @escaping (_ result: GoogleAPIBook) -> Void) {
        guard let url: URL = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)") else {
            print("Error! try again.")
            let book = GoogleAPIBook(author: "null", title: "null", imageURL: "null")
            completionHandler(book)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
                let book = GoogleAPIBook(author: "null", title: "null", imageURL: "null")
                completionHandler(book)
                
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                    let json = JSON(parseJSON: dataString)
                    let title = json["items"][0]["volumeInfo"]["title"].stringValue
                    let author = json["items"][0]["volumeInfo"]["authors"][0].stringValue
                    var image = json["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"].stringValue
                    if image != "" {
                        let i = image.endIndex(of: "zoom=")?.encodedOffset
                        var chars = Array(image)
                        chars[i!] = "3"
                        image = String(chars)
                    } else {
                        image = "null"
                    }
                    let book = GoogleAPIBook(author: author, title: title, imageURL: image)
                    completionHandler(book)
                }
            }
        }
        task.resume()
    }
    
    
    func getBookInfoFromGoodreadsAPI(isbn: String, completionHandler: @escaping (_ result: GoodreadsAPIBook) -> Void) {
            guard let url: URL = URL(string: "https://www.goodreads.com/search/index.xml?q=\(isbn)&key=jNNmr3rVtd1y6ZZn3IZ8eg") else {
                print("Error! try again.")
                let book = GoodreadsAPIBook(author: "null", title: "null", imageURL: "null")
                completionHandler(book)
                return
            }
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("error: \(error)")
                    let book = GoodreadsAPIBook(author: "null", title: "null", imageURL: "null")
                    completionHandler(book)
                    
                } else {
                    if let response = response as? HTTPURLResponse {
                        print("statusCode: \(response.statusCode)")
                    }
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        let xml = try! XML.parse(dataString)
                        var bookImageURL = "null"
                        var bookTitle = ""
                        var bookAuthor = ""
                        if let imageURL = xml["GoodreadsResponse", "search", "results", "work", "best_book", "image_url"].text {
                            bookImageURL = imageURL
//                            print(imageURL)
                        }

                        if let title = xml["GoodreadsResponse", "search", "results", "work", "best_book", "title"].text {
                            bookTitle = title
//                            print(title)
                        }

                        if let author = xml["GoodreadsResponse", "search", "results", "work", "best_book", "author", "name"].text {
                            bookAuthor = author
//                            print(author)
                        }
                        let book = GoodreadsAPIBook(author: bookAuthor, title: bookTitle, imageURL: bookImageURL)
                        completionHandler(book)
                    }
                }
            }
            task.resume()
        }
    
    func getBookInfoFromOpenLibraryAPI(isbn: String, completionHandler: @escaping (_ result: OpenLibraryAPIBook) -> Void) {
        guard let url: URL = URL(string: "https://openlibrary.org/api/books?bibkeys=ISBN:\(isbn)&jscmd=details&format=json") else {
            print("Error! try again.")
            let book = OpenLibraryAPIBook(author: "null", title: "null", imageURL: "null")
            completionHandler(book)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
                let book = OpenLibraryAPIBook(author: "null", title: "null", imageURL: "null")
                completionHandler(book)
                
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                    let json = JSON(parseJSON: dataString)
                    let title = json["ISBN:\(isbn)"]["details"]["title"].stringValue
                    let author = json["ISBN:\(isbn)"]["details"]["authors"][0]["name"].stringValue
                    var image = json["ISBN:\(isbn)"]["thumbnail_url"].stringValue
                    if image != "" {
                        let i = image.index(of: ".jpg")!.encodedOffset
                        var chars = Array(image)
                        chars[i - 1] = "L"
                        image = String(chars)
                    } else {
                        image = "null"
                    }
                    let book = OpenLibraryAPIBook(author: author, title: title, imageURL: image)
                    completionHandler(book)
                }
            }
        }
        task.resume()
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension ViewController: BarcodeScannerCodeDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
    print("Barcode Data: \(code)")
    print("Symbology Type: \(type)")
    
    getBookInfoFromGoogleAPI(isbn: code) { (book) in
        print(book)
        controller.googleBook = book
        self.countAPICallComplete += 1
        if self.countAPICallComplete == 3 {
            DispatchQueue.main.async {
                controller.performSegue(withIdentifier: "segueWithResults", sender: self)
                print("done")
            }
        }
    }
    
    getBookInfoFromGoodreadsAPI(isbn: code) { (book) in
        print(book)
        controller.goodreadsBook = book
        self.countAPICallComplete += 1
        if self.countAPICallComplete == 3 {
            DispatchQueue.main.async {
                controller.performSegue(withIdentifier: "segueWithResults", sender: self)
                print("done")
            }
        }
    }
    
    getBookInfoFromOpenLibraryAPI(isbn: code) { (book) in
        print(book)
        controller.openLibraryBook = book
        self.countAPICallComplete += 1
        if self.countAPICallComplete == 3 {
            DispatchQueue.main.async {
                controller.performSegue(withIdentifier: "segueWithResults", sender: self)
                print("done")
            }
        }
    }

//    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//      controller.resetWithError()
//    }
  }
}

// MARK: - BarcodeScannerErrorDelegate

extension ViewController: BarcodeScannerErrorDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
    print(error)
  }
}

// MARK: - BarcodeScannerDismissalDelegate

extension ViewController: BarcodeScannerDismissalDelegate {
  func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
    controller.dismiss(animated: true, completion: nil)
  }
}


//extension UIImageView {
//    func load(url: URL) {
//        DispatchQueue.global().async { [weak self] in
//            if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self?.image = image
//                    }
//                }
//            }
//        }
//    }
//}
