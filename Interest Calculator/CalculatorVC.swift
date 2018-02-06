//
//  ViewController.swift
//  Interest Calculator
//
//  Created by Eli Byers on 8/5/17.
//  Copyright © 2017 Eli Byers. All rights reserved.
//

import UIKit

class CalculatorVC: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    weak var activeTextField: UITextField? = nil

    @IBOutlet weak var interestRateLabel: UILabel!
    @IBOutlet weak var interestSlider: UISlider!
    var interestRate:Float = 1
    
    
    @IBOutlet weak var startingAmountField: UITextField!
    var startingAmount:Float = 0.0
    
    @IBOutlet weak var monthlyDepositField: UITextField!
    var monthlyDeposit:Float = 0.0
    
    @IBOutlet weak var monthlyWithdrawlsField: UITextField!
    var monthlyWithdrawls:Float = 0.0
    
    @IBOutlet weak var yearsField: UITextField!
    var years:Int = 0;

    
    @IBOutlet weak var totalLabel: UILabel!
    var total:Float = 0
    
    @IBOutlet weak var interestLabel: UILabel!
    var interest:Float = 0

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // live update values
        startingAmountField.addTarget(self, action: #selector(startingAmountDidChange), for:.editingChanged)
        startingAmountField.delegate = self
        monthlyDepositField.addTarget(self, action: #selector(monthlyDepositDidChange), for:.editingChanged)
        monthlyDepositField.delegate = self
        monthlyWithdrawlsField.addTarget(self, action: #selector(monthlyWithdrawlsDidChange), for:.editingChanged)
        monthlyWithdrawlsField.delegate = self
        yearsField.addTarget(self, action: #selector(yearsDidChange), for:.editingChanged)
        yearsField.delegate = self
        
        // display value
        calculateTotal()
        
        
        //  close keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        
        //  move scroll view for keybard
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
//        let selectedRange = scrollView.selectedRange
//        scrollView.scrollRangeToVisible(selectedRange)
    }

    
    @IBAction func interestSliderDidChange(_ sender: UISlider) {
        let step:Float = 0.01
        let roundedValue = round(sender.value / step) * step
        interestRate = roundedValue
        interestRateLabel.text = "\(interestRate)%"
        
        calculateTotal()
    }
    
    func updateFieldValue(_ field: inout UITextField!,_ value: inout Float){
        if (field.text != ""){
            value = Float(field.text!)!
        } else {
            value = 0
        }
        
        calculateTotal()
    }
    
    func startingAmountDidChange() {
        updateFieldValue(&startingAmountField, &startingAmount)
    }
    
    func monthlyDepositDidChange() {
        updateFieldValue(&monthlyDepositField, &monthlyDeposit)
    }
    
    func monthlyWithdrawlsDidChange() {
        updateFieldValue(&monthlyWithdrawlsField, &monthlyWithdrawls)
    }
    
    func yearsDidChange() {
        if (yearsField.text != ""){
            years = Int(yearsField.text!)!
        } else {
            years = 0
        }
        calculateTotal()
    }
    
    func calculateTotal(){
        
        let months = years * 12
        let monthlyInterestRate = (interestRate / 100) / 12
        
        total = startingAmount
        interest = 0
        for _ in 0..<months {
            total += (monthlyDeposit - monthlyWithdrawls)
            let newInterest = total * monthlyInterestRate
            interest += newInterest
            total += newInterest
        }
        
        totalLabel.text = total.asLocaleCurrency
        interestLabel.text = interest.asLocaleCurrency
    }
    
}

extension CalculatorVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        //print("active")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        activeTextField = nil
        //print("nil")
    }
    
    func tap(gesture: UITapGestureRecognizer){
        //print("tap")
        if let field = activeTextField {
            print("resignFirstResponder")
            field.resignFirstResponder()
        }
    }
    
}

extension Float {
    var asLocaleCurrency:String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self))!
    }
}

