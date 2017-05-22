//
//  HealthManager.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 2/21/16.
//  Copyright © 2016 Moblzip LLC. All rights reserved.
//

import Foundation


import HealthKit

class HealthManager {
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(_ completion: ((_ success:Bool, _ error:NSError?) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead: Set<HKObjectType> = Set(arrayLiteral:(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass))!)
        
        // 2. Set the types you want to write to HK Store
        let healthKitTypesToWrite = Set(arrayLiteral: (HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass))!)
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            dlog("Healthkit is not available in this device")
            
            let error = NSError(domain: "com.dietwz", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(false, error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) -> Void in
            
//            if( completion != nil )
//            {
                completion?(success,error as NSError?)
//            }
        }
    }
    
    /// generic function to read latest sample type.
    func readMostRecentSample(_ sampleType:HKSampleType , startDate: Date, completion: ((HKSample?, NSError?) -> Void)!)
    {
       
        // 1. Build the Predicate
//        let past = NSDate.distantPast()
        let past = startDate
        let now   = Date()
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: past, end:now, options: HKQueryOptions())
        
        // 2. Build the sort descriptor to return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
        let limit = 1
        
        // 4. Build samples query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                
                if let queryError = error {
                    completion?(nil,queryError as NSError?)
                    return;
                }
                
                // Get the first sample
                let mostRecentSample = results!.first as? HKQuantitySample
                
                // Execute the completion closure
                if completion != nil {
                    completion(mostRecentSample,nil)
                }
        }
        dlog("Going to execute query in health kit to get weight")
        // 5. Execute the Query
        self.healthKitStore.execute(sampleQuery)
    }
    
    
    /// save weight to healthkit
    func writeWeight(_ weight:Double, date: Date) {
        
        // 1. Create a BMI Sample
        let wtType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
        let wtQuantity = HKQuantity(unit: HKUnit.pound(), doubleValue: weight)
        let wtSample = HKQuantitySample(type: wtType!, quantity: wtQuantity, start: date, end: date)
        
        // 2. Save the sample in the store
        healthKitStore.save(wtSample, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                derror("HK -  Error saving weight: \(error!.localizedDescription)")
            } else {
                dlog("HK - Weight sample saved successfully!")
            }
        })
    }
    
    

}
