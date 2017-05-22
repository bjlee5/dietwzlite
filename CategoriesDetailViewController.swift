//
//  CategoriesDetailViewController.swift
//  Moblzip
//
//  Created by Sujit Maharana on 5/1/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import UIKit

class CategoriesDetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblHeadingInfo: UILabel!
    @IBOutlet weak var segTrackingMethod: DWSegmentedControl!
    @IBOutlet weak var iconTrackingMethod: UIImageView!
    @IBOutlet weak var lblTrackingInfo: UILabel!
    @IBOutlet weak var viewSelectTrackingMethod: UIView!
    @IBOutlet weak var viewDetailTrackingMethod: UIView!

    @IBOutlet weak var txtLabel: UITextField!
    @IBOutlet weak var txtLimit: UITextField!
    @IBOutlet weak var txtDecimalPlaces: UITextField!
    
    @IBOutlet weak var lblUpperLimit: UILabel!
    @IBOutlet weak var lblDecimalPlaces: UILabel!
    
    @IBOutlet weak var segDecimalPlaces: UISegmentedControl!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var lblSelectTrackingMethod: UILabel!
    
    var newCategory: Bool = false
    
    var categoryObject: CategoryInfo?
    var oldCategoryObject: CategoryInfo?
    
    let deleteButtonColor = UIColor(red: 1, green: 0.2, blue: 0.143, alpha: 1.000)
    let saveButtonColor = UIColor(red: 0.000, green: 0.4, blue: 1.000, alpha: 1.000)
    let cancelButtonColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSave.layer.cornerRadius = 5
        btnSave.layer.borderWidth = 1
        btnSave.layer.borderColor = ThemeColors.Teal.cgColor //saveButtonColor.CGColor
        btnSave.backgroundColor = UIColor.clear
        btnSave.setTitleColor(ThemeColors.Teal, for: UIControlState())
        
        btnCancel.layer.cornerRadius = 5
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = cancelButtonColor.cgColor
        btnCancel.backgroundColor = UIColor.clear
        btnCancel.setTitleColor(cancelButtonColor, for: UIControlState())
        
        btnDelete.layer.cornerRadius = 5
        btnDelete.layer.borderWidth = 1
        btnDelete.layer.borderColor = deleteButtonColor.cgColor
        btnDelete.backgroundColor = UIColor.clear
        btnDelete.setTitleColor(deleteButtonColor, for: UIControlState())
    }

    override func viewWillAppear(_ animated: Bool) {
        
        segTrackingMethod.mode = .category
        segTrackingMethod.addTarget(self, action: #selector(CategoriesDetailViewController.segmentValueChanged(_:)), for: .valueChanged)
        
        categoryObject = CategoryInfo(userDefinedCategory: true)
        if oldCategoryObject == nil {
            
            // this is new category screen
            lblHeading.text = "Add Category"
            segTrackingMethod.selectedIndex = 0
            segmentValueChanged(nil)
            btnDelete.isHidden = true
            
            newCategory = true
            
        } else {
            // which means we are in an edit screen
            newCategory = false
            
            guard let categoryObject = categoryObject else { fatalError("Can this ever be nil?") }
            
            //fill the new category object VALUES (not reference) from old one.
            categoryObject.clone(oldCategoryObject!)
//            oldCategoryObject = categoryObject
            lblHeading.text = "Edit Category"
            lblHeadingInfo.text = "Edit Custom Category"
            lblSelectTrackingMethod.text = "  Tracking method"
            txtLabel.text = categoryObject.label
            txtLimit.text = categoryObject.limit.description

            segDecimalPlaces.selectedSegmentIndex = categoryObject.point - 1
            segTrackingMethod.selectedIndex = categoryObject.mode.rawValue - 1  //<- this is also why removing the unknown case would be more efficient
            segmentValueChanged(nil)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions

    @IBAction func onCancel(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSave(_ sender: AnyObject) {
        
        if let mode = CategoryMode(rawValue: segTrackingMethod.selectedIndex + 1) { //<- this is also why removing the unknown case would be more efficient
            categoryObject?.mode = mode
        }
        
        if checkField(txtLabel, alertMessage: "Enter a label") {
            categoryObject?.label = txtLabel.text!
        } else {
            return
        }
        
        if segTrackingMethod.selectedIndex > 0 {
            
            guard let text = txtLimit.text, let floatValue = Float(text) , checkField(txtLimit, alertMessage: "Enter an upper limit") else { return }
            
            categoryObject?.limit = floatValue

            if segTrackingMethod.selectedIndex > 1 {
                categoryObject?.point = segDecimalPlaces.selectedSegmentIndex + 1
            }
        }
        
        if !newCategory {
            Utils.sharedInstance.removeCategoryFromArray(oldCategoryObject!)
        }
        
        Utils.sharedInstance.addCategory(categoryObject!)

        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func onDelete(_ sender: AnyObject) {
        Utils.sharedInstance.removeCategoryFromArray(categoryObject!)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onInfo(_ sender: AnyObject) {
        let infoView = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        infoView.infoItem = .CustomCategory
        navigationController?.pushViewController(infoView, animated: true)
    }
    
    // MARK: - Utility
    
    /// When the tracking method segment value changes, perform below operations
    func segmentValueChanged(_ sender: AnyObject?) {
        
        switch segTrackingMethod.selectedIndex {
        case 0:
            iconTrackingMethod.image = UIImage(named: "Question")
            lblTrackingInfo.text =  "  Question Details"
            
            lblUpperLimit.isHidden = true
            txtLimit.isHidden = true
            lblDecimalPlaces.isHidden = true
            segDecimalPlaces.isHidden = true
        case 1:
            iconTrackingMethod.image = UIImage(named: "Counter")?.withRenderingMode(.alwaysTemplate)
            lblTrackingInfo.text = "  Counter Details"
            
            lblUpperLimit.isHidden = false
            txtLimit.isHidden = false
            lblDecimalPlaces.isHidden = true
            segDecimalPlaces.isHidden = true
        default:
            iconTrackingMethod.image = UIImage(named: "Numeric")?.withRenderingMode(.alwaysTemplate)
            lblTrackingInfo.text = "  Numeric Value Details"
            
            lblUpperLimit.isHidden = false
            txtLimit.isHidden = false
            lblDecimalPlaces.isHidden = false
            segDecimalPlaces.isHidden = false
        }
    }
    
    // MARK: - Private
    
    /// This method takes a text field and checks if it is empty and displays the passed in message
    fileprivate func checkField(_ txtField: UITextField, alertMessage: String) -> Bool {
        if txtField.text!.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            return true
        } else {
            showWarningMessage(alertMessage)
            return false
        }
    }
}
