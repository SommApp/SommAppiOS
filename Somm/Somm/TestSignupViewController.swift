//
//  TestSignupViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/24/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit
import XCTest

class TestSignupViewController: XCTestCase {
    var testObj :SignupViewController?

    override func setUp() {
        super.setUp()
        testObj = SignupViewController()
    }
    
    func testIsUsernamePassBlank_Returns_True_Given_Blank_username_password() {
        var result = testObj?.isUsernamePassBlank("", password: "")
        XCTAssert(result==true)
    }
    func testIsUsernamePassBlank_Returns_False_Given_a_username_password() {
        var result = testObj?.isUsernamePassBlank("a", password: "a")
        XCTAssert(result==false)
    }
}
