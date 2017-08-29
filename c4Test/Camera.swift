//
//  Camera.swift
//  c4Test
//
//  Created by James Park on 2017-08-28.
//  Copyright © 2017 James Park. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraView: UIView {
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    func setUpPreviewLayer(with session: AVCaptureSession) {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.layer.addSublayer(cameraPreviewLayer)
    }

    func getPreviewLayer() -> CALayer {
        return cameraPreviewLayer// swiftlint:disable:this force_cast
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}


class Camera: View, AVCapturePhotoCaptureDelegate {

    var cameraPreviewLayer: AVCaptureVideoPreviewLayer {
        get {
            return self.cameraView.cameraPreviewLayer
        }
    }

    var cameraView: CameraView {
        return self.view as! CameraView // swiftlint:disable:this force_cast
    }


    public var constrainsProportions: Bool = true

    public override var width: Double {
        get {
            return Double(view.frame.size.width)
        } set(val) {
            var newSize = Size(val, height)
            if constrainsProportions {
                newSize.height = val * height / width
            }
            var rect = self.frame
            rect.size = newSize
            self.frame = rect
        }
    }

    public override var height: Double {
        get {
            return Double(view.frame.size.height)
        } set(val) {
            var newSize = Size(Double(view.frame.size.width), val)
            if constrainsProportions {
                let ratio = Double(self.size.width / self.size.height)
                newSize.width = val * ratio
            }
            var rect = self.frame
            rect.size = newSize
            self.frame = rect
        }
    }
    var captureSesssion : AVCaptureSession!
    var cameraOutput : AVCapturePhotoOutput!

    public override init(frame: Rect) {
        super.init()
        self.view = CameraView(frame: CGRect(frame))
        captureSesssion = AVCaptureSession()
        captureSesssion.sessionPreset = AVCaptureSessionPresetPhoto
        cameraOutput = AVCapturePhotoOutput()
        let device = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            .map { $0 as! AVCaptureDevice }
            .filter { $0.position == .front}
            .first!

        if let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSesssion.canAddInput(input)) {
                captureSesssion.addInput(input)
                if (captureSesssion.canAddOutput(cameraOutput)) {
                    captureSesssion.addOutput(cameraOutput)
                    self.cameraView.setUpPreviewLayer(with: captureSesssion)
                    self.cameraView.getPreviewLayer().frame = self.cameraView.bounds
                    captureSesssion.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }


        self.addTapGestureRecognizer { (_, _, _) in
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                kCVPixelBufferWidthKey as String: 160,
                kCVPixelBufferHeightKey as String: 160
            ]
            settings.previewPhotoFormat = previewFormat
            self.cameraOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }

        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)

            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        } else {
            print("some error here")
        }
           }


    // This method you can use somewhere you need to know camera permission   state
//    func askPermission() {
//        print("here")
//        let cameraPermissionStatus =  AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
//
//        switch cameraPermissionStatus {
//        case .authorized:
//            print("Already Authorized")
//        case .denied:
//            print("denied")
//
//            let alert = UIAlertController(title: "Sorry :(" , message: "But  could you please grant permission for camera within device settings",  preferredStyle: .alert)
//            let action = UIAlertAction(title: "Ok", style: .cancel,  handler: nil)
//            alert.addAction(action)
//            present(alert, animated: true, completion: nil)
//
//        case .restricted:
//            print("restricted")
//        default:
//            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {
//                [weak self]
//                (granted :Bool) -> Void in
//
//                if granted == true {
//                    // User granted
//                    print("User granted")
//                    DispatchQueue.main.async(){
//                        //Do smth that you need in main thread
//                    }
//                }
//                else {
//                    // User Rejected
//                    print("User Rejected")
//
//                    DispatchQueue.main.async(){
//                        let alert = UIAlertController(title: "WHY?" , message:  "Camera it is the main feature of our application", preferredStyle: .alert)
//                        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
//                        alert.addAction(action)
//                        self?.present(alert, animated: true, completion: nil)
//                    }
//                }
//            });
//        }
//    }


   }
