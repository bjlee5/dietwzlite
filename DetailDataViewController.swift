//
//  DetailDataViewController.swift
//  Moblzip
//
//  Created by Niklas Olsson on 25/12/14.
//  Copyright (c) 2014 niklas. All rights reserved.
//

import UIKit

class DetailDataViewController: UIViewController {

    
    @IBOutlet weak var scrollNutrition: UIScrollView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var lblDescrip: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblServing: UILabel!
    
    @IBOutlet weak var lblCalories: UILabel!
    @IBOutlet weak var lblCaloriesFat: UILabel!
    @IBOutlet weak var lblTotalFat: UILabel!
    @IBOutlet weak var lblSaturatedFat: UILabel!
    @IBOutlet weak var lblSodium: UILabel!
    @IBOutlet weak var lblCholestrol: UILabel!

    @IBOutlet weak var lblPolyunsaturatedFat: UILabel!
    @IBOutlet weak var lblMonoUnSaturatedFat: UILabel!
    @IBOutlet weak var lblTotalCarb: UILabel!
    @IBOutlet weak var lblDietryFiber: UILabel!
    @IBOutlet weak var lblSugar: UILabel!
    @IBOutlet weak var lblProtein: UILabel!
    
    
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var lblAd: UILabel!
    @IBOutlet weak var descView: UIView!
    
    @IBOutlet weak var typServView: UIView!
    @IBOutlet weak var btnRecipe: UIButton!
    
    var dataInfo = HealthyAlternatives()
    
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        adView.isHidden = true
        descView.backgroundColor = ThemeColors.goodChoiceBackground
        typServView.backgroundColor = ThemeColors.goodChoiceBackground
        self.navigationController?.interactivePopGestureRecognizer!.delegate = nil
        

        // Do any additional setup after loading the view.

        titleLbl.text = dataInfo.itemCat
        lblDescrip.text = dataInfo.itemDescrip
        lblComment.text = dataInfo.itemComment
        lblServing.text = dataInfo.itemServing
        
        lblCalories.text = dataInfo.itemKcal.description
        lblCaloriesFat.text = dataInfo.itemCalFat.description
        
        let totalFat = dataInfo.itemSatFat + dataInfo.ItemPoly + dataInfo.ItemMono
        lblTotalFat.text = totalFat.description
        lblSaturatedFat.text = dataInfo.itemSatFat.description
        lblMonoUnSaturatedFat.text = dataInfo.ItemMono.description
        lblPolyunsaturatedFat.text = dataInfo.ItemPoly.description
        
        lblCholestrol.text = dataInfo.ItemChol.description
        lblSodium.text = dataInfo.itemSodium.description
        
        lblTotalCarb.text = dataInfo.itemCarbs.description
        lblDietryFiber.text = dataInfo.itemFiber.description
        lblSugar.text = dataInfo.itemSugar.description
        
        lblProtein.text = dataInfo.itemProtein.description
        
        let aSelector : Selector = #selector(DetailDataViewController.bannerAdClicked(_:))
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        adView.addGestureRecognizer(tapGesture)
        adView.isUserInteractionEnabled = true
        
//        dlog("Recipe html \(dataInfo.recipeHTML)")
        btnRecipe.isHidden = (dataInfo.recipeHTML == "")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func bannerAdClicked(_ sender: AnyObject) {
        dlog("Banner Ad Clicked")
        
        if let checkURL = URL(string: "http://www.dietwz.com") , UIApplication.shared.openURL(checkURL) {
            dlog("url successfully opened")
        } else {
            dlog("invalid url")
        }
    }
    
    @IBAction func onBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRecipe(_ sender: AnyObject) {
        
        let recipeVC = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        recipeVC.recipe = Recipes(healthyAlternatives: dataInfo)
        navigationController?.pushViewController(recipeVC, animated: true)
    }
}
