//
//  ViewController.swift
//  uploadImage
//
//Created by Aryaman Puri on 20/09/21.

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var tmpImageView: UIImageView!
    @IBOutlet weak var uploadActivityIndicator: UIActivityIndicatorView!
    
    var tmpImage : UIImage?
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        uploadImageButton.isEnabled = false
        uploadActivityIndicator.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - IBActions
    
    @IBAction func selectImageTapped(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func uploadImageTapped(_ sender: UIButton) {
        guard let image = tmpImage else { return  }
        
        
        let filename = "avatar.png"
        let boundary = UUID().uuidString
        let fieldName = "reqtype"
        let fieldValue = "fileupload"
        

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: URL(string: "https://catbox.moe/user/api.php")!)
        urlRequest.httpMethod = "POST"
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data in a web browser
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
      
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(fieldValue)".data(using: .utf8)!)
        

        
        // Add the image to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(UIImagePNGRepresentation(image)!)
        
    
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        uploadActivityIndicator.isHidden = false
        uploadActivityIndicator.startAnimating()
        uploadImageButton.isEnabled = false
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            
            DispatchQueue.main.async {
                self.uploadActivityIndicator.stopAnimating()
                self.uploadActivityIndicator.isHidden = true
                self.uploadImageButton.isEnabled = true
            }
            
            if(error != nil){
                print("\(error!.localizedDescription)")
            }
            
            guard let responseData = responseData else {
                print("no response data")
                return
            }
            
            if let responseString = String(data: responseData, encoding: .utf8) {
                print("uploaded to: \(responseString)")
            }
        }).resume()
    }
    
}

extension ViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            print("editedImage")
            // Use editedImage Here
            tmpImage = editedImage
            tmpImageView.image = tmpImage
            uploadImageButton.isEnabled = true
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Use originalImage Here
            print("originalImage")
            tmpImage = originalImage
            tmpImageView.image = tmpImage
            uploadImageButton.isEnabled = true
        }
        picker.dismiss(animated: true)
    }
    
}

extension ViewController : UINavigationControllerDelegate {
    
}
