//
//  TransactionViewController.swift
//  BudgetApp
//
//  Created by Alexander Kerendian on 7/21/18.
//  Copyright © 2018 Alexander Kerendian. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var transaction = Transaction()
    var editingIndex: Int?
    var hasUnsavedChanges = true
    
    var amount: Float = 0 {
        didSet {
            transaction.amount = self.amount
        }
    }
    
    let transactionInfoTitle = ["MERCHANT", "DATE", "REPEAT", "CATEGORY"]

    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var transactionInfoTableView: UITableView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.amountTextField.becomeFirstResponder()
        amountTextField.tintColor = UIColor.clear
//        amountTextField.isUserInteractionEnabled = false
        transactionInfoTableView.isScrollEnabled = false
        
        setAmount()
        
        if UIScreen.main.bounds.height > 800.0 {
            keyboardHeightConstraint.constant = 325.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateSaveButton()
        transactionInfoTableView.reloadData()
    }
    
    func updateSaveButton() {
        if transaction.isSavable, hasUnsavedChanges {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }

    private func updateAmountLabel() {
        var label = "-$"
        if editingIndex != nil, !hasUnsavedChanges {
            label.append(String(transaction.amount))
            if label.split(separator: ".")[1].count < 2 {
                label.append("0")
            }
        } else if amountTextField.text == nil || amountTextField.text == "" {
            label.append("0.00")
        } else {
            let input = amountTextField.text!
            var index = (input.count > 3) ? input.count-1 : 2
            while index >= 0 {
                if index == 1 {
                    label.append(".")
                }
                if index > input.count-1 {
                    label.append("0")
                } else {
                    label.append(input[input.index(input.startIndex, offsetBy: (input.count - 1 - index))])
                }
                index -= 1
            }
        }
        amountLabel.text = label
        amount = Float(String(label.split(separator: "$").last ?? "0.00")) ?? 0.0
    }
    
    private func setAmount() {
        guard editingIndex != nil else { return }
        var amountStr = "\(self.amount)"
        let decimalCount = amountStr.split(separator: ".")[1].count
        amountStr = amountStr.replacingOccurrences(of: ".", with: "")
        if decimalCount < 2 {
            amountStr.append("0")
        }
        self.amountTextField.text = amountStr
        updateAmountLabel()
    }
    
    @IBAction func saveTransaction(_ sender: Any) {
        OverviewViewController.budget.addTransaction(transaction: transaction)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        hasUnsavedChanges = true
        updateAmountLabel()
        updateSaveButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Back button
        let backItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: nil)
        navigationItem.backBarButtonItem = backItem
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        // MerchantViewController
        if segue.identifier == "chooseMerchant" {
            let destination = segue.destination as? MerchantViewController
            if transaction.merchant != "" {
                destination?.selectedMerchant = transaction.merchant
            }
            destination?.delegate = self

        // DateViewController
        } else if segue.identifier == "chooseDate" {
            let destination = segue.destination as? DateViewController
            destination?.date = transaction.date
            destination?.delegate = self
        
        // FrequencyViewController
        } else if segue.identifier == "chooseFrequency" {
            let destination = segue.destination as? FrequencyViewController
            destination?.frequency = transaction.frequency
            destination?.delegate = self
            
        // CategoryViewController
        } else if segue.identifier == "chooseCategory" {
            let destination = segue.destination as? CategoryViewController
            destination?.selectedCategory = transaction.categoryName
            destination?.delegate = self
        }
    }
    
    // MARK: TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionInfo", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = transactionInfoTitle[indexPath.row]
        var detailText = ""
        switch indexPath.row {
        case 0:
            detailText = transaction.merchant
        case 1:
            detailText = transaction.date.getDescription()
        case 2:
            detailText = transaction.getFrequency()
        case 3:
            detailText = transaction.categoryName
        default:
            break
        }
        cell.detailTextLabel?.text = detailText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            performSegue(withIdentifier: "chooseMerchant", sender: self)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: "chooseDate", sender: self)
        } else if indexPath.row == 2 {
            performSegue(withIdentifier: "chooseFrequency", sender: self)
        } else if indexPath.row == 3 {
            performSegue(withIdentifier: "chooseCategory", sender: self)
        }
    }
}

