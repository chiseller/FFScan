//
//  ViewController.swift
//  FFScanDemo
//
//  Created by fingle on 2020/4/30.
//  Copyright © 2020 fingle0618. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos

enum FFScanError: String, Error {
    case empty
}

class FFScanController: UIViewController {
    //设备
    private let device = AVCaptureDevice.default(for: .video)
    //输入流
    private var input: AVCaptureDeviceInput?
    //输出流
    private  lazy var output: AVCaptureMetadataOutput =  {
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.rectOfInterest = UIScreen.main.bounds
        return output
    }()
    //链接对象
    private lazy var session:AVCaptureSession =  {
        let session = AVCaptureSession()
        session.sessionPreset = .inputPriority
        return session
    }()
    //预览layer
    private  lazy var preview: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = UIScreen.main.bounds
        return preview
    }()
    
    open var finished: ((Result<String,FFScanError>) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatDevice()
        let scan = FFScanView(frame: view.bounds)
        view.addSubview(scan)
        var rightItemTitle = NSLocalizedString("SS_OpenAlbum_Key", comment: "")
        if rightItemTitle == "SS_OpenAlbum_Key" {
            rightItemTitle = "Album"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightItemTitle, style: .plain, target: self, action: #selector(openPhotoLibrary))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
        navigationController?.isNavigationBarHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }
    
    private func creatDevice(){
        if !canmeraAvailable() {
            return
        }
        guard let device = self.device else {
            return
        }
        do {
            input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input!) {
                session.addInput(input!)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
                output.metadataObjectTypes = [.qr,.ean13,.ean8,.code128]
            }
            
            view.layer.insertSublayer(preview, at: 0)
            
        } catch {
            FFLog(message: error)
        }
        
    }
    
    @objc private func openPhotoLibrary(){
           let picker = UIImagePickerController()
           picker.sourceType = .photoLibrary
           picker.delegate = self
           present(picker, animated: true, completion: nil)
       }
    
}


extension FFScanController: AVCaptureMetadataOutputObjectsDelegate {
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            return
        }
        session.stopRunning()
        if let metadataObject =  (metadataObjects.first as? AVMetadataMachineReadableCodeObject)  {
            if let string = metadataObject.stringValue, string.count > 0 {
                FFLog(message: string)
                finished?(.success(string))
            }else {
                finished?(.failure(.empty))
            }
            
        }
        
    }
}

extension FFScanController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage){
            let context = CIContext()
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            if let feature = (detector?.features(in: CIImage(cgImage: image.cgImage!)).first as? CIQRCodeFeature){
                if let string = feature.messageString, string.count > 0 {
                    FFLog(message: string)
                    finished?(.success(string))
                }else {
                    finished?(.failure(.empty))
                }
            }
            
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension FFScanController{
    private func photoAlbumAvailable() -> Bool {
        var author = PHPhotoLibrary.authorizationStatus()
        switch author {
        case .denied, .restricted:
            return false
        case .authorized:
            return true
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                author = status
            }
            return author == .authorized
            
            
        @unknown default:
            return false
        }
        
        
    }
    private func canmeraAvailable() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            var author = AVCaptureDevice.authorizationStatus(for: .video)
            switch author {
            case .denied, .restricted:
                return false
            case .authorized:
                return true
            case .notDetermined:
                
                AVCaptureDevice.requestAccess(for: .video) { (status) in
                    author = status ? .authorized : .notDetermined
                }
                return author == .authorized
                
                
            @unknown default:
                return false
            }
            
        }
        return false
    }
    
   
    
    func FFLog(message:Any = "" ,file:String = #file, funcName:String = #function, lineNum:Int = #line){
        #if DEBUG
        print("File:" + NSURL.fileURL(withPath: file).lastPathComponent,"funcName:" +  funcName,"lineNum:" + String(lineNum) + "\(message)")
        #endif
    }
}
