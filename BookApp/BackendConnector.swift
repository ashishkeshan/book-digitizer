//
//  BackendConnector.swift
//  BookApp
//
//  Created by Ashish Keshan on 4/8/20.
//  Copyright © 2020 Ashish Keshan. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftSpinner

let db = Firestore.firestore()
let storage = Storage.storage()

func pushBookData(imageID: String, title: String, author: String, category: String, completion:@escaping (String)->Void) {
   db.collection("Books").addDocument(data: [
        "title": title,
        "author": author,
        "category": category,
        "imageID": imageID
    ]) { err in
        if let err = err {
            completion("failure")
        } else {
            completion("success")
        }
    }
    
}



func uploadImage(imageID: String, image: UIImage, completion:@escaping (String)->Void) {
    let data = image.jpegData(compressionQuality: 0.5)
    let storageRef = storage.reference()
    let imageRef = storageRef.child("BookCovers/\(imageID)" + ".jpeg")
    imageRef.putData(data!, metadata: nil) { metadata, error in
        guard let metadata = metadata else {
            print(error?.localizedDescription)
            completion("failure")
            return
        }
        // Metadata contains file metadata such as size, content-type.
        let size = metadata.size
        print(size)
        completion("success")
    }
}


    // Do any additional setup after loading the view.

func handleUpload(image: UIImage, title: String, author: String, category: String, completion:@escaping (String)->Void) {
    let imageID = UUID().uuidString
    SwiftSpinner.show("Uploading Book...")
    uploadImage(imageID: imageID, image: image, completion: { message in
        if message == "success" {
            SwiftSpinner.hide()
            pushBookData(imageID: imageID + ".jpeg", title: title, author: author, category: category, completion: { message in
                if message == "success" {
                    completion("success")
                } else {
                    completion("failure")
                }
            })
        } else {
            SwiftSpinner.hide()
            completion("failure")
        }
    })
}

func areEqualImages(img1: UIImage, img2: UIImage) -> Bool {
    guard let data1 = img1.pngData() else { return false }
    guard let data2 = img2.pngData() else { return false }
    return data1 == data2
}
