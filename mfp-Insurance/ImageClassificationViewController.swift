/**
 
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit
import CoreML
import Vision
import ImageIO
import IBMMobileFirstPlatformFoundation


class ImageClassificationViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var classificationLabel: UILabel!
    
    
    override func viewDidLoad() {
         super.viewDidLoad()
    }
    
    // MARK: - Image Classification
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // Initialize Vision Core ML model from base Watson Visual Recognition model
            
            //  Uncomment this line to use the tools model.
            //let model = try VNCoreMLModel(for: watson_tools().model)
            
            //  Uncomment this line to use the plants model.
            var model = try VNCoreMLModel(for: insurance().model)
            
            
            
            let fileManager = FileManager.default
            
            let itemsArray = fileManager.listFiles(path: HomeViewController.path);
            var filterdItemsArray = [URL]()
            func filterContentForSearchText(searchText: String) {
                filterdItemsArray = itemsArray.filter { item in
                    //  NSLog("Vittal ======" + item.absoluteString)
                    return item.absoluteString.lowercased().contains(searchText.lowercased())
                }
            }
            filterContentForSearchText(searchText: "insurance.mlmodel")
            if(!filterdItemsArray.isEmpty) {
                let compiledUrl = try MLModel.compileModel(at: filterdItemsArray[0])
                let mlModel = try MLModel(contentsOf: compiledUrl)
                model = try VNCoreMLModel(for: mlModel)
            } 
            // Create visual recognition request using Core ML model
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            }
            request.imageCropAndScaleOption = .scaleFit
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            DispatchQueue.main.async {
                do {
                    try handler.perform([self.classificationRequest])
                } catch {
                    print("Failed to perform classification.\n\(error.localizedDescription)")
                }
             }
        }
    }
    
    /// Updates the UI with the results of the classification.
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                // Display top classification ranked by confidence in the UI.
                //self.classificationLabel.text = "Classification: " + classifications[0].identifier
                var message = ""
                if ( classifications[0].identifier != "Negative" && self.fetchDamageAmount(damageType: classifications[0].identifier) != 0 ) {
                    message = "Damage Type : " + classifications[0].identifier + "\n" + "Approximate Cost : " + String(self.fetchDamageAmount(damageType: classifications[0].identifier));
                    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
                        var carDamage = Damage.init(type: classifications[0].identifier, cost:  self.fetchDamageAmount(damageType: classifications[0].identifier))
                        AnalyzerViewController.damagelist.append(carDamage)
                        self.navigationController?.popViewController(animated: true)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in
                        self.classificationLabel.text = "Choose a car pic to analyze a damage"
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    message = "Looks like there is no damage"
                    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in
                        self.classificationLabel.text = "Choose a car pic to analyze a damage"
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
//                self.classificationLabel.text = "Classification: \(classifications[0].identifier) \nConfidence Level : \(classifications[0].confidence*100) %"
              
            }
        }
    }
    
    func fetchDamageAmount(damageType: String) -> Int {
        if (damageType.lowercased() == "vandalism") {
           return 800
        } else if (damageType.lowercased() == "broken windshield") {
            return 1000
        } else if (damageType.lowercased() == "flat tyre") {
            return 200
        } else if (damageType.lowercased() == "motorcycle accident") {
            return 3000
        }
        return 0;
    }
    
    // MARK: - Photo Actions
    
    @IBAction func takePicture() {
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    
}

extension ImageClassificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Handling Image Picker Selection
    
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true)
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        let image =     info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = image
        
        updateClassifications(for: image!)
    }
}

extension FileManager {
    func listFiles(path: String) -> [URL] {
        let baseurl: URL = URL(fileURLWithPath: path)
        var urls = [URL]()
        enumerator(atPath: path)?.forEach({ (e) in
            guard let s = e as? String else { return }
            let relativeURL = URL(fileURLWithPath: s, relativeTo: baseurl)
            let url = relativeURL.absoluteURL
            urls.append(url)
        })
        return urls
    }
}



