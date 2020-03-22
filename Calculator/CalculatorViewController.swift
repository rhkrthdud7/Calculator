//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Soso on 22/03/2020.
//  Copyright © 2020 Soso. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class CalculatorViewController: UIViewController, View {
    var disposeBag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var labelResult: UILabel!
    
    @IBOutlet weak var buttonZero: UIButton!
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonFour: UIButton!
    @IBOutlet weak var buttonFive: UIButton!
    @IBOutlet weak var buttonSix: UIButton!
    @IBOutlet weak var buttonSeven: UIButton!
    @IBOutlet weak var buttonEight: UIButton!
    @IBOutlet weak var buttonNine: UIButton!
    @IBOutlet weak var buttonPoint: UIButton!
    
    @IBOutlet weak var buttonAC: UIButton!
    @IBOutlet weak var buttonPlusMinus: UIButton!
    @IBOutlet weak var buttonPercent: UIButton!
    
    @IBOutlet weak var buttonEqual: UIButton!
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var buttonMinus: UIButton!
    @IBOutlet weak var buttonMultiply: UIButton!
    @IBOutlet weak var buttonDivide: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cornerRadius = buttonZero.bounds.height / 2
        
        [buttonZero, buttonOne, buttonTwo, buttonThree, buttonFour, buttonFive, buttonSix, buttonSeven, buttonEight, buttonNine, buttonPoint, buttonAC, buttonPlusMinus, buttonPercent, buttonEqual, buttonPlus, buttonMinus, buttonMultiply, buttonDivide]
            .forEach({ $0?.layer.cornerRadius = cornerRadius })
    }
    
    func setup() {
        reactor = CalculatorReactor()
    }
    
    func bind(reactor: CalculatorReactor) {
        let buttons: [UIButton] = [
            buttonZero, buttonOne, buttonTwo,
            buttonThree, buttonFour, buttonFive,
            buttonSix, buttonSeven, buttonEight, buttonNine
        ]
        
        buttons.enumerated().forEach({ (value) in
            value.element.rx.tap
                .map { .numberAndPoint("\(value.offset)") }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        })
        buttonPoint.rx.tap
            .map { .numberAndPoint(".") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        buttonAC.rx.tap
            .map { .reset }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        buttonPlus.rx.tap
            .map { .operation(.binaryOperation({ $0 + $1 })) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        buttonMinus.rx.tap
            .map { .operation(.binaryOperation({ $0 - $1 })) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        buttonMultiply.rx.tap
            .map { .operation(.binaryOperation({ $0 * $1 })) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        buttonDivide.rx.tap
            .map { .operation(.binaryOperation({ $0 / $1 })) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        buttonEqual.rx.tap
            .map { .operation(.result) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map({ $0.displayText })
            .bind(to: labelResult.rx.text)
            .disposed(by: disposeBag)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
}
