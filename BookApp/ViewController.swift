//
//  ViewController.swift
//  BookApp
//
//  Created by Ashish Keshan on 4/4/20.
//  Copyright © 2020 Ashish Keshan. All rights reserved.
//

import UIKit
import AVFoundation
import CodeScanner
import SwiftyJSON
import SwiftyXMLParser

class ViewController: UIViewController {

    private var scanner: CodeScanner!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var scannerView: UIView!
    
    override func viewDidLoad() {

        super.viewDidLoad()

        self.navigationItem.title = "Detect Barcode from Camera"
//        self.view.backgroundColor = .groupTableViewBackground

        self.scanner = CodeScanner(metadataObjectTypes: [AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.code128], preview: self.scannerView)
        self.scannerView.isHidden = true
    }

    @IBAction func scanBookPressed(_ sender: Any) {
        CodeScanner.requestCameraPermission { (success) in
            if success {
                self.scannerView.isHidden = false
                self.authorLabel.isHidden = true
                self.titleLabel.isHidden = true
                self.bookCoverImageView.isHidden = true
                self.scanner.scan(resultOutputs: { (outputs) in

                    if let output: String = outputs.first {

                        if output.isJANLowerBarcode() {
                            return
                        }

                        if let isbn = output.convartISBN() {
                            print(isbn)
                            self.scanner.stop()
                            self.scannerView.removeFromSuperview()
                            self.getBookInfoFromAPI(isbn: isbn) { (book) in
                                DispatchQueue.main.async {
                                    self.authorLabel.isHidden = false
                                    self.titleLabel.isHidden = false
                                    self.bookCoverImageView.isHidden = false
                                    self.authorLabel.text = book.author ?? "no author found"
                                    self.titleLabel.text = book.title ?? "no author found"
                                    self.bookCoverImageView.load(url: URL(string: book.imageURL)!)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
    
    func getBookInfoFromAPI(isbn: String, completionHandler: @escaping (_ result: Book) -> Void) {
        guard let url: URL = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)") else {
            print("Error! try again.")
            let book = Book(author: "null", title: "null", imageURL: "null")
            completionHandler(book)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
                let book = Book(author: "null", title: "null", imageURL: "null")
                completionHandler(book)
                
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                    print("data: \(dataString)")
                    let json = JSON(parseJSON: dataString)
                    let title = json["items"][0]["volumeInfo"]["title"].stringValue
                    let author = json["items"][0]["volumeInfo"]["authors"][0].stringValue
                    var image = json["items"][0]["volumeInfo"]["imageLinks"]["thumbnail"].stringValue
                    print(title)
                    print(author)
                    print(image)
                    let i = image.endIndex(of: "zoom=")?.encodedOffset
                    var chars = Array(image)
                    chars[i!] = "3"
                    image = String(chars)
                    print(image)
//                    let xml = try! XML.parse(dataString)
//                    var bookImageURL = ""
//                    var bookTitle = ""
//                    var bookAuthor = ""
//                    if let imageURL = xml["GoodreadsResponse", "search", "results", "work", "best_book", "image_url"].text {
//                        bookImageURL = imageURL
//                        print(imageURL)
//                    }
//
//                    if let title = xml["GoodreadsResponse", "search", "results", "work", "best_book", "title"].text {
//                        bookTitle = title
//                        print(title)
//                    }
//
//                    if let author = xml["GoodreadsResponse", "search", "results", "work", "best_book", "author", "name"].text {
//                        bookAuthor = author
//                        print(author)
//                    }
                    let book = Book(author: author, title: title, imageURL: image)
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

