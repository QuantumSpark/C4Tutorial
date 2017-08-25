//
//  WorkSpace.swift
//  c4Test
//
//  Created by James Park on 2017-08-20.
//  Copyright © 2017 James Park. All rights reserved.
//

import UIKit

class WorkSpace: CanvasController {
    var player:AudioPlayer!
    var timer:Timer?
    
    var maxPaths=(Path(),Path())
    var avgPaths=(Path(),Path())
    
    var maxShapes=(Shape(),Shape())
    var avgShapes = (Shape(), Shape())
    
    var Θ = 0.0
    
    var maxPeak = (30.981050491333, 31.1506500244141)
    var avgPeak = (63.9939880371094, 63.8977127075195)
    
    func styleShape(_ shape: Shape) {
        shape.lineWidth = 0.5
        shape.fillColor = clear
        shape.strokeColor = black
    }
    
    func setupShapes() {
        //set the paths for each shape
        maxShapes.0.path = maxPaths.0
        maxShapes.1.path = maxPaths.1
        
        avgShapes.0.path = avgPaths.0
        avgShapes.1.path = avgPaths.1
        
        //style all the shapes
        styleShape(maxShapes.0)
        styleShape(maxShapes.1)
        styleShape(avgShapes.0)
        styleShape(avgShapes.1)
        
        //add them all the the canvas
        canvas.add(maxShapes.0)
        canvas.add(maxShapes.1)
        canvas.add(avgShapes.0)
        canvas.add(avgShapes.1)
        
        //rotate the 2nd, 3rd, and 4th shapes
        maxShapes.1.transform.rotate(M_PI)
        avgShapes.0.transform.rotate(M_PI_2)
        avgShapes.1.transform.rotate(M_PI_2 * 3)
    }
    
    func generatePoint(_ radius: Double) -> Point {
        return Point(radius * cos(Θ), radius * sin(Θ))
    }
    
    func normalize(_ val: Double, max: Double) -> Double {
        //Normalizes an incoming value based on a provided max
        var normMax = abs(val)
        //gives us a value between 0 and 1
        normMax /= max
        //map the value so that the shape doesn't overlap with the logo
        return map(normMax, min: 0, max: 1, toMin: 100, toMax: 200)
    }
    
    func resetPaths(){
         maxPaths=(Path(),Path())
         avgPaths=(Path(),Path())
    }
    
    func generateNextPoints() {
        //generates new points for each path
        let max0 = normalize(player.peakPower(0), max: maxPeak.0)
        maxPaths.0.addLineToPoint(generatePoint(max0))
        
        let max1 = normalize(player.peakPower(1), max: maxPeak.1)
        maxPaths.1.addLineToPoint(generatePoint(max1))
        
        let avg0 = normalize(player.averagePower(0), max: avgPeak.0)
        avgPaths.0.addLineToPoint(generatePoint(avg0))
        
        let avg1 = normalize(player.averagePower(1), max: avgPeak.1)
        avgPaths.1.addLineToPoint(generatePoint(avg1))
        
        //increments the current angle
        Θ += M_PI / 180.0
        
        //resets the paths for each full rotation
        if Θ >= 2 * M_PI {
            Θ = 0.0
            resetPaths()
        }
    }
    
    func setupTimer() {
        //create a timer to run at 60fps
        timer = Timer(interval: 1.0/60.0) {
            self.player.updateMeters()
            self.generateNextPoints()
            self.updateShapes()
        }
        timer?.start()
    }
    
    func updateShapes() {
        //set the path for each shape, and recenter it
        maxShapes.0.path = maxPaths.0
        maxShapes.0.center = canvas.center
        
        maxShapes.1.path = maxPaths.1
        maxShapes.1.center = canvas.center
        
        avgShapes.0.path = avgPaths.0
        avgShapes.0.center = canvas.center
        
        avgShapes.1.path = avgPaths.1
        avgShapes.1.center = canvas.center
    }
    
    func setupPlayer() {
        player = AudioPlayer("Loop.aif")
        player?.meteringEnabled = true //needs to be on
        player?.loops = true
        player?.play()
    }

    override func setup() {
        canvas.backgroundColor = Color(red: 0.933, green: 1.0, blue: 0.0, alpha: 1.0)
        setupShapes()
        setupPlayer()
        setupTimer()
    }
}

