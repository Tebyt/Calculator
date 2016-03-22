//
//  ViewController.swift
//  Calculator
//
//  Created by Pan Chen on 3/14/15.
//  Copyright (c) 2015 Pan Chen. All rights reserved.
//

import UIKit

//struct A{
//    var name: String
//}
//

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingNumber: Bool = false
    
    var error = false
    
    var brain = CalculatorBrain()
    
    var displayValue : Double? {
        get {
            if let text = display.text {
                return NSNumberFormatter().numberFromString(text)!.doubleValue
                }
            return nil
        }
        set {
            userIsInTheMiddleOfTypingNumber = false
            if let newText = newValue {
                if newText.isNormal{
                    let intValue = Int(newText)
                    if abs(newText - Double(intValue)) < 10e-8{
                        display.text = "\(intValue)"
                    }
                    else{
                        display.text = "\(newText)"
                    }
                    return
                }
            }
            display.text = nil
            error = true
        }
    }
    
    @IBAction func enter() {
        if error{
            return
        }
        removeEqualSign()
        userIsInTheMiddleOfTypingNumber = false
        displayValue = brain.pushOperand(displayValue!)
        history.text = brain.description
    }
    
    
    @IBAction func appendDigit(sender: UIButton) {
        if error{
            return
        }
        removeEqualSign()
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingNumber {
            if digit == "."{
                if display.text!.rangeOfString(".") != nil{
                    return
                }
            }
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingNumber = true
        }
    }
    
    @IBAction func addConstant(sender: UIButton) {
        if error{
            return
        }

        if userIsInTheMiddleOfTypingNumber{
            enter()
        }
        removeEqualSign()
        let constant = sender.currentTitle!
        displayValue = brain.pushOperand(constant)
        history.text = brain.description
    }
    
    
    @IBAction func operate(sender: UIButton) {
        if error{
            return
        }

        if userIsInTheMiddleOfTypingNumber {
            enter()
        }
        removeEqualSign()
        let operation = sender.currentTitle!
        let (result, completed) = brain.pushOperation(operation)
        displayValue = result
        history.text = brain.description
        if completed{
            if !history.text!.hasSuffix("="){
                history.text = history.text! + "="
            }
        }
    }

    @IBAction func negative() {
        if error{
            return
        }

        if let currentValue = displayValue{
            if currentValue < 0 {
                display.text = display.text!.substringFromIndex(display.text!.startIndex.advancedBy(1))
            } else if currentValue > 0 {
                display.text = "-" + display.text!
            }
        }
    }
    
    @IBAction func clear() {
        brain.reset()
        display.text = "0"
        userIsInTheMiddleOfTypingNumber = false
        history.text = ""
        error = false
    }
    
    @IBAction func delete() {
        if userIsInTheMiddleOfTypingNumber{
            if countElements(display.text!) == 1{
                display.text = "0"
                userIsInTheMiddleOfTypingNumber = false
            } else {
                display.text = String((display.text!).characters.dropLast())
            }
        }
    }
    
    func removeEqualSign(){
        if history.text!.hasSuffix("=") {
            history.text = brain.description
        }
    }
   
  
    
    
//    func multiply(op1: Double, op2: Double) -> Double {
//        return op1 * op2
//    }
//
    
    
    
    
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
    
}
