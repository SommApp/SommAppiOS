//
//  TestLoginViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/25/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit
import XCTest

class TestLoginViewController: XCTestCase {
    var testObj :LoginViewController?
    
    override func setUp() {
        super.setUp()
        testObj = LoginViewController()
    }
    
    func testIsUsernamePassBlank_Returns_True_Given_Blank_username_password() {
        var result = testObj?.isUsernamePassBlank(email:"", password: "")
        XCTAssert(result==true)
    }
    func testIsUsernamePassBlank_Returns_False_Given_a_username_password() {
        var result = testObj?.isUsernamePassBlank(email:"a", password: "a")
        XCTAssert(result==false)
    }
    func testIsUsernamePassBlank_Returns_true_Given_a_username_no_password() {
        var result = testObj?.isUsernamePassBlank(email:"a", password: "")
        XCTAssert(result==true)
    }
    func testIsUsernamePassBlank_Returns_true_Given_a_password_no_username() {
        var result = testObj?.isUsernamePassBlank(email:"", password: "a")
        XCTAssert(result==true)
    }
}
