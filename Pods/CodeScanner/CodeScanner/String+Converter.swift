//
//  String+Converter.swift
//  CodeScanner
//
//  Created by 須藤 将史 on 2017/02/18.
//  Copyright © 2017年 masashi_sutou. All rights reserved.
//

import Foundation

public extension String {

    // MARK: - public
    
    public func searchAamazon() {
        
        if let url = URL(string: String(format: "https://amazon.co.jp/dp/%@", self)) {
            UIApplication.shared.openURL(url)
        }
    }
    
    public func isJANLowerBarcode() -> Bool {
     
        return self.pregMatche(pattern: "^192[0-9]{10}")
    }
    
    public func convartISBN() -> String? {
                
        if !self.pregMatche(pattern: "^97[8|9][0-9]{10}") {
            return nil
        }
        
        // "978XXXXXXXXX5" → XXXXXXXXX
        let startIdx: String.Index = self.index(self.startIndex, offsetBy: 3)
        let endIdx: String.Index = self.index(self.endIndex, offsetBy: -1)
        let isbn9 = self[startIdx..<endIdx].description
        
        return isbn9 + isbn9.checkDigit()
    }
    
    // MARK: - private
    
    private func checkDigit() -> String {
        
        var sum: Int = 0
        for index in 0...8 {
            if let number = Int(String(self[self.index(self.startIndex, offsetBy: index)])) {
                sum += number * (10 - index)
            }
        }
        let checkdigit = (11 - (sum % 11)) % 11
        
        if checkdigit == 10 {
            return "X"
        } else {
            return String(checkdigit)
        }
    }
    
    private func pregMatche(pattern: String) -> Bool {
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return false }
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
        return matches.count > 0
    }
}
