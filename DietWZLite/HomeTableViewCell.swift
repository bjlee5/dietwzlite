//
//  HomeTableViewCell.swift
//  Moblzip
//
//  Created by TheTerminator on 6/23/16.
//  Copyright © 2016 Moblzip LLC. All rights reserved.
//

import UIKit

protocol HomeTableViewCellDelegate: NSObjectProtocol {
    func weightChanged(_ cell: HomeTableViewCell, lbs: Float)
    func choiceControlChanged(_ dataItem: InfoItem.Data, mealWeight: MealWeight)
    func showInfoForDataItem(_ dataItem: InfoItem.Data)
}

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var valueLbl: UILabel?
    @IBOutlet weak var decreaseBtn: UIButton?
    @IBOutlet weak var increaseBtn: UIButton?
    
    @IBOutlet weak var valueFld: UITextField?
    
    @IBOutlet weak var lbsFld: UITextField?
    @IBOutlet weak var kgFld: UITextField?
    
    @IBOutlet weak var statusSegment: UISegmentedControl?
    @IBOutlet weak var segChoices: DWSegmentedControl?

    var delegate: HomeTableViewCellDelegate!
    var category: CategoryInfoAbstract!
    var dataItem: InfoItem.Data?
    var index: Int!

    let kgPerLbs = 0.45359237 as Float

    // MARK: - View Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let curString: NSString = textField.text! as NSString
        let newString: NSString = curString.replacingCharacters(in: range, with: string) as NSString
        let curValue: Float = newString.floatValue
        
        if textField == lbsFld {
            let newValue: Float = curValue * kgPerLbs
            kgFld?.text = String(format: "%.01f", newValue)
        } else if textField == kgFld {
            let newValue: Float = curValue / kgPerLbs
            lbsFld?.text = String(format: "%.01f", newValue)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = lbsFld?.text, let value = Float(text) {
            delegate.weightChanged(self, lbs: value)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func choiceControlChanged(_ sender: DWSegmentedControl) {
        let mealWeight = MealWeight(rawValue: sender.selectedIndex)!
        delegate.choiceControlChanged(dataItem!, mealWeight: mealWeight)
    }
    
    // MARK: - Utility
    
    func configWithCategory(_ category: CategoryInfoAbstract, index: Int, indexPath: IndexPath, dataItem: InfoItem.Data?, delegate: HomeTableViewCellDelegate) {
        
        titleLbl.text = category.label
        self.category = category
        self.index = index
        self.delegate = delegate
        self.dataItem = dataItem
        
        infoBtn.isHidden = (indexPath as NSIndexPath).section != 0
        infoBtn.addTarget(self, action: #selector(HomeTableViewCell.showInfo), for: .touchUpInside)
        
        switch category.mode {
        case .multiChoice:
            configForMultichoice(dataItem!) //no custom multi choice yet so can be implicit unwrapped
        case .counter:
            configForCounter()
        case .question:
            configForQuestion()
        case .weight:
            configForWeight()
        case .numeric:
            configForNumeric()
        default:
            assertionFailure("configWithCategory: shouldnt config for unknown")
        }
    }
    
    func showInfo() {
        delegate.showInfoForDataItem(dataItem!)
    }
    
    //MARK: - Private
    
    fileprivate func configForCounter() {
        valueLbl?.text = String(Int(category.value))
        decreaseBtn?.tag = index
        increaseBtn?.tag = index
    }
    
    fileprivate func configForQuestion() {
        
        let value = Int(category.value)
        
        guard let segment = statusSegment else { fatalError("Question type cells need statusSegument outlet connected") }
        
        segment.tag = index
        segment.selectedSegmentIndex = (0..<segment.numberOfSegments ~= value) ? value : UISegmentedControlNoSegment
    }
    
    fileprivate func configForWeight() {
        
        let value = category.value
        
        if value == 0 {
            kgFld?.text = ""
            lbsFld?.text = ""
        } else {
            lbsFld?.text = String(format: "%.01f", value)
            let kilogram = value * kgPerLbs
            kgFld?.text = String(format: "%.01f", kilogram)
        }
        
        tag = index
    }
    
    fileprivate func configForNumeric() {
        
        let value = category.value
        
        if value == 0 {
            valueFld?.text = ""
        } else {
            if category.point == 0 {
                valueFld?.text = String(Int(value))
            } else if category.point == 1 {
                valueFld?.text = String(format: "%.1f", value)
            } else {
                valueFld?.text = String(format: "%.2f", value)
            }
        }
        
        valueFld?.tag = index
    }
    
    func configForMultichoice(_ dataItem: InfoItem.Data) {
        
        self.dataItem = dataItem
        
        let todayInfo = Utils.sharedInstance.getCurrDay()
        
        guard let segment = segChoices else { fatalError("Multi choice type cells need statusSegument outlet connected") }
        
        segment.mode = .meal
        
        titleLbl.text = dataItem.rawValue
        
        infoBtn.addTarget(self, action: #selector(HomeTableViewCell.showInfo), for: .touchUpInside)
        
        let value = todayInfo.mealWeightForDataItem(dataItem)
        
        if let someValue = value , -1..<segment.items.count ~= someValue {
            segment.selectedIndex = someValue
        }
    }
}
