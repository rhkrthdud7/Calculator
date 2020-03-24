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
        case clear
    }
    
    enum Mutation {
        case appendCharacter(String)
        case setOperation(Operation)
        case clearResult
    }
    
    class State {
        var resultValue: Decimal = 0
        var inputText: String = "0"
        var displayText: String = "0"
        var operation: Operation?
        var repeated: (() -> Void)?
        
        var inputValue: Decimal {
            if let value = Decimal(string: inputText) {
                if value != 0 {
                    return value
                }
            }
            return resultValue
        }
        
        var hasInputs: Bool {
            return !inputText.isEmpty
        }
        
        func removeLeadingZeros() {
            if inputText.isFloatingPoint == false,
                inputText.count > 1,
                inputText.hasPrefix("0") {
                inputText.removeFirst()
            }
        }
        
        func removeDuplicatePoints() {
            if inputText.filter({ $0 == "." }).count > 1,
                let index = inputText.lastIndex(of: ".") {
                inputText.remove(at: index)
            }
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
        case .clear:
            return Observable.just(Mutation.clearResult)
        case .operation(let operation):
            return Observable.just(Mutation.setOperation(operation))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .appendCharacter(let character):
            state.inputText.append(character)
            state.removeLeadingZeros()
            state.removeDuplicatePoints()
            state.displayText = state.inputText
        case .clearResult:
            state.resultValue = 0
            state.inputText = "0"
            state.displayText = "0"
            state.operation = nil
            state.repeated = nil
        case .setOperation(let operation):
            switch operation {
            case .binary:
                state.operation = operation
                state.resultValue = state.inputValue
                state.inputText = "0"
            case .unary(let unary):
                if var operand =  Decimal(string: state.inputText) {
                    operand += state.resultValue
                    state.resultValue = 0
                    state.inputText = unary(operand).text
                }
                state.displayText = state.inputText
            case .result:
                if case let .binary(binary) = state.operation {
                    let value = state.inputValue
                    state.repeated = {
                        state.resultValue = binary(state.resultValue, value)
                    }
                    // reset
                    state.inputText = "0"
                    state.operation = nil
                }
                // operate
                state.repeated?()
                state.displayText = state.resultValue.text
            }
        }
        
        return state
    }
    
}

fileprivate extension String {
    var isFloatingPoint: Bool {
        return self.contains(".")
    }
}

fileprivate extension Decimal {
    var text: String {
        if isNaN || isInfinite {
            return "오류"
        }
        let string = "\(self)"
        if string.filter({ "0123456789".contains($0) }).count > 9 {
            let formatter = NumberFormatter()
            formatter.maximumSignificantDigits = 7
            formatter.numberStyle = .scientific
            formatter.exponentSymbol = "e"
            if let string = formatter.string(from: self as NSNumber) {
                return string
            }
        }
        return string
    }
}

enum Operation {
    case unary((Decimal) -> Decimal)
    case binary((Decimal, Decimal) -> Decimal)
    case result
}
