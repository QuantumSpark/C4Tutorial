//
//  WorkSpace.swift
//  c4Test
//
//  Created by James Park on 2017-08-20.
//  Copyright © 2017 James Park. All rights reserved.
//

import UIKit

class WorkSpace: CanvasController {
    override func setup() {
        let camera = Camera(frame: Rect(0,0,500,500))
        canvas.add(camera)
    }
}

