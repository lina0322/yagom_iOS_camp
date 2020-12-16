//
//  DecimalCalculatorTests.swift
//  CalculatorTests
//
//  Created by 김태형 on 2020/12/15.
//

import XCTest
@testable import Calculator

final class DecimalCalculatorTests: XCTestCase {
    private var sut: DecimalCalculator!
    
    override func setUp() {
        super.setUp()
        sut = DecimalCalculator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testAdd() {
        XCTAssertEqual(sut.operate(calculatorOperator: .add, firstValue: "1", secondValue: "2"), "3.0")
        XCTAssertEqual(sut.operate(calculatorOperator: .add, firstValue: "3", secondValue: "-2"), "1.0")
        XCTAssertEqual(sut.operate(calculatorOperator: .add, firstValue: "-1", secondValue: "2"), "1.0")
        XCTAssertEqual(sut.operate(calculatorOperator: .add, firstValue: "-2", secondValue: "-3"), "-5.0")
    }
    
    func testSubtract() {
        XCTAssertEqual(sut.operate(calculatorOperator: .subtract, firstValue: "2", secondValue: "1"), "1.0")
        XCTAssertEqual(sut.operate(calculatorOperator: .subtract, firstValue: "1", secondValue: "-2"), "3.0")
        XCTAssertEqual(sut.operate(calculatorOperator: .subtract, firstValue: "-1", secondValue: "3"), "-4.0")
        XCTAssertEqual(sut.operate(calculatorOperator: .subtract, firstValue: "-1", secondValue: "-3"), "2.0")
    }
    
    func testMultiple() {
        XCTAssertEqual(sut.operate(calculatorOperator: .multiple, firstValue: "3", secondValue: "4"), "12.0")
    }
    
    func testDivide() {
        XCTAssertEqual(sut.operate(calculatorOperator: .divide, firstValue: "10", secondValue: "2"), "5.0")
    }
    
//  0으로 나누었을 때 에러 코드 추가 필요
//    func testDivideByzero() {
//        XCTAssertEqual(sut.operate(calculatorOperator: .divide, firstValue: "15", secondValue: "0"), "error")
//    }
    
    func testIsOperator() {
        XCTAssertEqual(sut.isOperator("+"), true)
        XCTAssertEqual(sut.isOperator("-"), true)
        XCTAssertEqual(sut.isOperator("*"), true)
        XCTAssertEqual(sut.isOperator("/"), true)
        XCTAssertEqual(sut.isOperator("="), false)
        XCTAssertEqual(sut.isOperator(")"), false)
    }
    
    func testIsEqual() {
        XCTAssertEqual(sut.isEqual("="), true)
        XCTAssertEqual(sut.isEqual("*"), false)
    }
    
    func testHandleDigit() {
        //정수 + 소수 = 9자리 이상일때 정수부터 총 9자리까지만 출력
        sut.handleInput("1234.123456")
        sut.handleInput("+")
        sut.handleInput("1111.111111")
        sut.handleInput("=")
        XCTAssertEqual(sut.resultValue, "2345.23456")
        
        //정수 9자리 이상일때 1의자리 부터 총 9자리만 출력
        sut.handleInput("111122223333")
        sut.handleInput("+")
        sut.handleInput("222233334444")
        sut.handleInput("=")
        XCTAssertEqual(sut.resultValue, "355557777")
   }

    func testCalculateVariousIntValues() {
        sut.handleInput("10")
        sut.handleInput("+")
        sut.handleInput("2")
        sut.handleInput("*")
        sut.handleInput("3")
        sut.handleInput("-")
        sut.handleInput("4")
        sut.handleInput("/")
        sut.handleInput("2")
        sut.handleInput("=")
        
        XCTAssertEqual(sut.resultValue, "14")
        
    }
    
    func testCalculateVariousDoubleValues() {
        sut.handleInput("13.234")
        sut.handleInput("*")
        sut.handleInput("21.3132")
        sut.handleInput("=")
        
        XCTAssertEqual(sut.resultValue, "282.058888") // 9자리 초과 반올림적용 필요
        
    }
}
