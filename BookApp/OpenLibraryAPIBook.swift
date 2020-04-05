//
//  OpenLibraryAPIBook.swift
//  BookApp
//
//  Created by Ashish Keshan on 4/4/20.
//  Copyright © 2020 Ashish Keshan. All rights reserved.
//

import Foundation

public class OpenLibraryAPIBook {

    var author: String!
    var title: String!
    var imageURL: String!

    init(author: String!, title: String!, imageURL: String!) {
        self.author = author
        self.title = title
        self.imageURL = imageURL
    }

}
