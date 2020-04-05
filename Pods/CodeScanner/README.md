CodeScanner
====

## Overview
- Generate code
  - QR
  - Code128Barcode
- Detect photo
  - QR
- Detect by camera
  - QR
  - Code128Barcode

## Requirement
- Xcode 8 or later
- Swift 3 or later
- iOS 8.0 or later

## Usage
#### Generate code
- QR
```Swift
self.imageView.image = Code.generateQRCode(text: "message")
```

- Code128Barcode
```Swift
self.imageView.image = Code.generate128Barcode(text: "message")
```

#### Detect photo
- QR
```Swift
// MARK: UINavigationControllerDelegate, UIImagePickerControllerDelegate

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

    if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

        let messages: [String] = Code.detectQRCodes(image: selectedImage)
        if messages.count > 0 {
            self.textView.text = messages.first
        } else {
            self.textView.text = "[Not Found QR Code in Photo]"
        }
    }

    dismiss(animated: true, completion: nil)
}
```

#### Detect by camera
- QR
```Swift
import UIKit
import AVFoundation
import CodeScanner

final class QRCodeDetectForCameraViewController: UIViewController {

    private var scanner: CodeScanner!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.navigationItem.title = "Detect QR code from Camera"
        self.view.backgroundColor = .groupTableViewBackground

        self.scanner = CodeScanner(metadataObjectTypes: [AVMetadataObjectTypeQRCode], preview: self.view)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        CodeScanner.requestCameraPermission { (success) in
            if success {
                self.scanner.scan(resultOutputs: { (outputs) in
                    print(outputs)
                })
            }
        }
    }
}
```

- Code128Barcode
```Swift
import UIKit
import AVFoundation
import CodeScanner

final class BarcodeDetectForCameraViewController: UIViewController {

    private var scanner: CodeScanner!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.navigationItem.title = "Detect Barcode from Camera"
        self.view.backgroundColor = .groupTableViewBackground

        self.scanner = CodeScanner(metadataObjectTypes: [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeCode128Code], preview: self.view)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        CodeScanner.requestCameraPermission { (success) in
            if success {
                self.scanner.scan(resultOutputs: { (outputs) in

                    if let output: String = outputs.first {

                        if output.isJANLowerBarcode() {
                            return
                        }

                        if let isbn = output.convartISBN() {
                            self.scanner.stop()
                            isbn.searchAamazon()
                        }
                    }
                })
            }
        }
    }
}
```

## Installation
#### [CocoaPods](https://cocoapods.org/)
Add the following line to your Podfile:
```ruby
use_frameworks!

target 'YOUR_TARGET_NAME' do
  pod "CodeScanner"
end
```

#### [Carthage](https://github.com/Carthage/Carthage)
Add the following line to your Cartfile:
```ruby
github "masashi-sutou/CodeScanner"
```

## Licence
CodeScanner is available under the MIT license. See the LICENSE file for more info.
