//
//  WorkSpace.swift
//  c4Test
//
//  Created by James Park on 2017-08-20.
//  Copyright © 2017 James Park. All rights reserved.
//

import UIKit

class WorkSpace: CanvasController {
    var circles = [Circle]()
    var wedges = [Wedge]()

    override func setup() {
       let d = 160.0
        canvas.backgroundColor = white

        let container = View(frame: Rect(0,0,d,d))
        container.backgroundColor = white
        container.center = canvas.center

        canvas.add(container)

        let points = [Point(), Point(d,0), Point(d,d), Point(0,d)]
        for i in 0...3 {
            let circle = Circle(center: points[i], radius: d/2.0 - 5.0)
            circle.fillColor = black
            circle.lineWidth = 0
            circles.append(circle)
            container.add(circle)

            let wedge = Wedge(center: circle.bounds.center, radius: d/2, start: M_PI_2 * Double(i), end: M_PI_2 * (1+Double(i)))
            wedge.fillColor = white
            wedge.lineWidth = 0.0
            wedges.append(wedge)
            circle.add(wedge)
        }

        let mainSquare = View(frame: container.frame)
        mainSquare.backgroundColor = white
        mainSquare.hidden = true
        canvas.add(mainSquare)

        let ϴ = M_PI

        let containerRotateForward = ViewAnimation(duration: 1.25) {
            for circle in self.circles {
                circle.rotation += ϴ * 2.0 //each circle does a full rotation
            }
            container.rotation += ϴ / 2.0 //the container does a quarter rotation
        }
        containerRotateForward.delay = 0.25 //the animation waits 0.25s to start
        containerRotateForward.curve = .EaseInOut


        let containerRotateBackward = ViewAnimation(duration: 1.25) {
            for circle in self.circles {
                circle.rotation -= ϴ * 2.0 //each circle does a full rotation
            }
            container.rotation -= ϴ / 2.0 //the container does a quarter rotation
            mainSquare.rotation += ϴ / 2.0 //the main square does full rotation
        }

        containerRotateBackward.delay = 0.25
        containerRotateBackward.curve = .EaseInOut


        containerRotateForward.addCompletionObserver {
            mainSquare.hidden = false //reveal the main square
            for wedge in self.wedges {
                wedge.hidden = true //hide the wedges
            }
            containerRotateBackward.animate()
        }

        containerRotateBackward.addCompletionObserver {
            mainSquare.hidden = true //hide the main square
            for wedge in self.wedges {
                wedge.hidden = false //reveal the wedges
            }
            containerRotateForward.animate()
        }

        containerRotateForward.animate()


    }
}

