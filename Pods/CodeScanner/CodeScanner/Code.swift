//
//  Code.swift
//  CodeScanner
//
//  Created by 須藤 将史 on 2017/02/15.
//  Copyright © 2017年 masashi_sutou. All rights reserved.
//

import UIKit

public struct Code {
    
    // MARK: QR code detect
    /*
     * accuracy
     *  - CIDetectorAccuracyLow
     *  - CIDetectorAccuracyHigh
     */
    
    public static func detectQRCodes(image: UIImage, context: CIContext? = nil, accuracy: String = CIDetectorAccuracyHigh) -> [String] {
        
        var messages: [String] = []
        guard let ciDetector = CIDetector(ofType:CIDetectorTypeQRCode, context:context, options:[CIDetectorAccuracy: accuracy]) else { return messages }
        guard let cgImage = image.cgImage else { return messages }
        guard let features = ciDetector.features(in: CIImage(cgImage: cgImage)) as? [CIQRCodeFeature] else { return messages }
        
        for feature in features {
            if let messageString: String = feature.messageString {
                messages.append(messageString)
            }
        }
        
        return messages
    }
    
    // MARK: QR code generate
    /*
     * inputCorrectionLevel
     *  - L: 7%
     *  - M: 15%
     *  - Q: 25%
     *  - H: 30%
     *
     * https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIQRCodeGenerator
     */
    
    public static func generateQRCode(text: String, inputCorrectionLevel level: String = "M") -> UIImage? {
        
        guard let data = text.data(using: String.Encoding.utf8),
            let filter = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": level]),
            let outputImage = filter.outputImage
            else { return nil }
        
        return UIImage(ciImage: outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10)))
    }
    
    // MARK: Barcode generate
    /*
     * https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CICode128BarcodeGenerator
     */
    
    public static func generate128Barcode(text: String) -> UIImage? {
        
        guard let data = text.data(using: String.Encoding.utf8),
            let filter = CIFilter(name: "CICode128BarcodeGenerator", parameters: ["inputMessage": data]),
            let outputImage = filter.outputImage
            else { return nil }
        
        return UIImage(ciImage: outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10)))
    }
}
