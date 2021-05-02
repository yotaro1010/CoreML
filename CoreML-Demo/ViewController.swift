//
//  ViewController.swift
//  CoreML-Demo
//
//  Created by Yotaro Ito on 2021/05/03.
//

import CoreML
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "select image"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        tap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    @objc func didTapImage(){
        let piker = UIImagePickerController()
        piker.sourceType = .photoLibrary
        piker.delegate = self
        present(piker, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 20, y: view.safeAreaInsets.top, width: view.frame.size.width-40, height: view.frame.size.width-40)
        
        label.frame = CGRect(x: 20, y: view.safeAreaInsets.top+(view.frame.size.width-40)+10, width: view.frame.size.width-40, height: 100)
    }
    
    private func analyzeImage(image: UIImage?){
//    画像をリサイズ
        guard let buffer = image?.resize(size: CGSize(width: 224, height: 224))?.getCVPixelBuffer() else {return}
        do{
//            MLModelを作る
            let config = MLModelConfiguration()
            let mlModel = try GoogLeNetPlaces(configuration: config)
            let input = GoogLeNetPlacesInput(sceneImage: buffer)
            
            let output = try mlModel.prediction(input: input)
            
//            outputされた文字をlabelに反映
            let text = output.sceneLabel
            label.text = text
        }catch{
            print("error:", error)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as?  UIImage else {return}
        imageView.image = image
        analyzeImage(image: image)
    }
    
}

