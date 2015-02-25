//
//  TestSignupViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/24/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit
import XCTest

class TestStringHelper: XCTestCase {
    var testObj :StringHelper = StringHelper()

    override func setUp() {
        super.setUp()
    }
    
    func testIsUsernamePassBlank_Returns_True_Given_Blank_username_password() {
        var result = testObj.isEmailPassBlank(email:"", password: "")
        XCTAssert(result==true)
    }
    func testIsUsernamePassBlank_Returns_False_Given_a_username_password() {
        var result = testObj.isEmailPassBlank(email:"a", password: "a")
        XCTAssert(result==false)
    }
    func testIsUsernamePassBlank_Returns_true_Given_a_username_no_password() {
        var result = testObj.isEmailPassBlank(email:"a", password: "")
        XCTAssert(result==true)
    }
    func testIsUsernamePassBlank_Returns_true_Given_a_password_no_username() {
        var result = testObj.isEmailPassBlank(email:"", password: "a")
        XCTAssert(result==true)
    }
    
    
    func testContainsEmail_Returns_true_given_email(){
        var result = testObj.containsEmail("steve@abc.com")
        XCTAssert(result==true)
    }
    
    func testContainsEmail_Returns_false_given_non_email(){
        var result = testObj.containsEmail("steve@.com")
        XCTAssert(result==false)
    }
    func testContainsEmail_Returns_false_given_non_email2(){
        var result = testObj.containsEmail("steve@.")
        XCTAssert(result==false)
    }
    func testContainsEmail_Returns_false_given_non_email3(){
        var result = testObj.containsEmail("steve@")
        XCTAssert(result==false)
    }
    func testContainsEmail_Returns_false_given_non_email4(){
        var result = testObj.containsEmail("steve.com")
        XCTAssert(result==false)
    }
    func testContainsEmail_Returns_true_given_valid_email(){
        var result = testObj.containsEmail("ste.ve@a.com")
        XCTAssert(result==true)
    }
    func testContainsEmail_Returns_false_given_non_email5(){
        var result = testObj.containsEmail("ste.v@e@.com")
        XCTAssert(result==false)
    }
    
}

