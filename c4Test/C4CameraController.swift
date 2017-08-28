//
//  C4CameraController.swift
//  c4Test
//
//  Created by Geyi Liu on 2017-08-28.
//  Copyright © 2017 James Park. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation



class C4CameraController:UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    var stillImageOutput: AVCaptureStillImageOutput?
    var assetWriter: AVAssetWriter?
    var currentCamera: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureVideoDataOutput?
    var cameraPosition: AVCaptureDevicePosition?
    var captureSesssion : AVCaptureSession!
    var previewLayer : AVCaptureVideoPreviewLayer!
    init() {
        self.cameraPosition = .front
    
        self.previewLayer = nil
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Initialize
    func initialInputOutputForCamera(_: device){
        if let input = try? AVCaptureDeviceInput(device: self.device) {
            if (captureSesssion.canAddInput(input)) {
                captureSesssion.addInput(input)
                if (captureSesssion.canAddOutput(cameraOutput)) {
                    captureSesssion.addOutput(cameraOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer.frame = self.view.bounds
                    self.view.layer.addSublayer(previewLayer)
                    captureSesssion.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initCaputre(self.cameraPosition.first!);
    }
}
