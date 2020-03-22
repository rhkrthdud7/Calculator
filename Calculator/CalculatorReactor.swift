//
//  CalculatorReactor.swift
//  Calculator
//
//  Created by Soso on 22/03/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

final class CalculatorReactor: Reactor {
    enum Action {
        case numberAndPoint(String)
        case operation(Operation)
        case reset
    }
    
    enum Mutation {
        case appendCharacter(String)
        case setOperation(Operation)
        case clearResult
    }
    
    class State {
        var result: Double = 0
        var inputText: String = "0"
        var displayText: String = "0"
        var operation: Operation?
        var repeated: (() -> Void)?
        
        var hasInputs: Bool {
            return !inputText.isEmpty
        }
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .numberAndPoint(let number):
            return Observable.just(Mutation.appendCharacter(number))
        case .reset:
            return Observable.just(Mutation.clearResult)
        case .operation(let operation):
            return Observable.just(Mutation.setOperation(operation))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .appendCharacter(let character):
            guard state.inputText.hasNotReachedMaxInputLength else { return state }
            if state.operation == nil {
                state.result = 0
            }
            if state.inputText.isEmpty {
                state.inputText = character
            } else if state.inputText == "0" {
                if character == "." {
                    state.inputText = "0."
                } else {
                    state.inputText = character
                }
            } else {
                if character == "." {
                    guard state.inputText.isNotAFloatingPoint else { return state }
                }
                state.inputText += character
            }
            state.displayText = state.inputText
            
        case .clearResult:
            state.result = 0
            state.inputText = "0"
            state.displayText = "0"
            
        case .setOperation(let operation):
            switch operation {
            case .binaryOperation:
                state.operation = operation
                state.result = state.result + (Double(state.inputText) ?? 0)
                state.inputText = ""
            case .result:
                if let previousOperation = state.operation {
                    switch previousOperation {
                    case .binaryOperation(let binary):
                        if let operand = Double(state.inputText) {
                            state.repeated = {
                                state.result = binary(state.result, operand)
                            }
                        }
                    default:
                        print("")
                    }
                    // reset
                    state.inputText = ""
                    state.operation = nil
                }
                // operate
                state.repeated?()
                
                // display
                if state.result.truncatingRemainder(dividingBy: 1) == 0 {
                    state.displayText = String(format: "%.0f", state.result)
                } else {
                    state.displayText = "\(state.result)"
                }
                
            default:
                break
            }
        }
        
//        print("result: \(state.result)")
//        print("inputText: \(state.inputText)")
//        print("displayText: \(state.displayText)")
//        print("operation: \(state.operation)")
//        print("repeated: \(state.repeated)\n")
        return state
    }
    
}

fileprivate extension String {
    var hasNotReachedMaxInputLength: Bool {
        return self.filter({ "0123456789".contains($0) }).count < 9
    }
    var isNotAFloatingPoint: Bool {
        return !self.contains(".")
    }
}

enum Operation {
    case unaryOperation((Double) -> Double)
    case binaryOperation((Double, Double) -> Double)
    case result
}

/*
 case .plus:         return .binaryOperation({ $0 + $1 })
 case .minus:        return .binaryOperation({ $0 - $1 })
 case .multiply:     return .binaryOperation({ $0 * $1 })
 case .divide:       return .binaryOperation({ $0 / $1 })
 case .percent:      return .unaryOperation({ $0 / 100 })
 case .plusminus:    return .unaryOperation({ -$0 })
 case .ac:           return .constant(0)
 case .equal:        return .result
 */
