//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Pan Chen on 3/17/15.
//  Copyright (c) 2015 Pan Chen. All rights reserved.
//

import Foundation

class CalculatorBrain: CustomStringConvertible{
    
    var description: String{
        return getDescription()
    }
    
    func getDescription() -> String {
        var stackCopy = operandStack
        var result = ""
        while (!stackCopy.isEmpty){
            let nextPart = getDescription(&stackCopy)
            if !result.isEmpty{
                result = nextPart + "," + result
            }else{
                result = nextPart
            }
        }
        return result
    }
    
    private func getDescription(inout operandStack: [Op]) ->  String{
        if operandStack.isEmpty{
            return "?"
        }
        switch (operandStack.removeLast()){
        case .Operand(let operand):
            let intValue = Int(operand)
            if abs(operand - Double(intValue)) < 10e-8{
                return "\(intValue)"
            }
            else{
                return "\(operand)"
            }
        case .UnaryOperation(let symbol, _):
            return symbol + "(" + getDescription(&operandStack) + ")"
        case .BinaryOperation(let symbol, _):
            let op2 = getDescription(&operandStack)
            return "(" + getDescription(&operandStack) + symbol + op2 + ")"
        case .Variable(let symbol):
            return symbol
        }
    }
    
    private enum Op: CustomStringConvertible{
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Variable(String)
//        case FakeOperation(String, Double)
        
        var description: String{
            switch self{
            case Operand(let operand):
                return "\(operand)"
            case UnaryOperation(let symbol, _):
                return symbol
            case BinaryOperation(let symbol, _):
                return symbol
            case Variable(let variable):
                return variable
                
//            case .FakeOperation(let symbol, _):
//                return symbol
            }
        }
    }
    
    private var operandStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    private var variableValues = Dictionary<String,Double>()
    
    
    typealias PropertyList = AnyObject
    var program: PropertyList{
        get{
            return operandStack.map { $0.description }
        }
        
        set{
            if let ops = newValue as? [String]{
                var newStack = [Op]()
                for op in ops{
                    if let operation = knownOps[op]{
                        newStack.append(operation)
                    } else if let operand = NSNumberFormatter().numberFromString(op)?.doubleValue{
                        newStack.append(Op.Operand(operand))
                    } else{
                        return
                    }
                }
                operandStack = newStack
            }
        }
    }
    

    init(){
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷", { $1/$0 }))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−", { $1-$0 }))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("Sin", sin))
        learnOp(Op.UnaryOperation("Cos", cos))
//        learnOp(Op.FakeOperation("π", M_PI))
        
        variableValues["π"] = M_PI
        
    }
    
    
    func evaluate() -> (result: Double?, completed: Bool) {
        let (result, remainingStack) = evaluate(operandStack)
//        println("\(operandStack) evaluated as \(result) with \(remainingStack) left")
//        println(description)
        return (result, remainingStack.isEmpty)
    }
    
    
    private func evaluate(operandStack: [Op]) -> (result: Double?, remainingStack: [Op]){
        if !operandStack.isEmpty{
            var remaningStack = operandStack
            let nextOp = remaningStack.removeLast()
            switch nextOp{
            case let .Operand(operand):
                return (operand, remaningStack)
//            case Op.FakeOperation(_, let constant):
//                return (constant, remaningStack)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remaningStack)
                if let operand = operandEvaluation.result{
                    return (operation(operand), operandEvaluation.remainingStack)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remaningStack)
                if let op1 = op1Evaluation.result{
                    let op2Evaluation = evaluate(op1Evaluation.remainingStack)
                    if let op2 = op2Evaluation.result{
                        return (operation(op1, op2), op2Evaluation.remainingStack)
                    }
                }
            case .Variable(let variable):
                if let value = variableValues[variable]{
                    return (value, remaningStack)
                }
            }
        }
        return (nil, operandStack)
    }
    
    func pushOperand(operand: Double) -> Double? {
        operandStack.append(Op.Operand(operand))
        return evaluate().result
    }
    
    func pushOperand(symbol: String) -> Double? {
        operandStack.append(Op.Variable(symbol))
        return evaluate().result
    }
    
    
    
    
    func pushOperation(symbol: String) -> (result: Double?, completed: Bool){
        if let operation = knownOps[symbol]{
            operandStack.append(operation)
        }
        return evaluate()
    }
    
    func reset(){
        operandStack.removeAll()
    }
}
