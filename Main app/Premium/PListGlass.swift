//
//  PList.swift
//  isenhas
//
//  Created by Davi Orzechowski on 19/08/23.
//

import Foundation

@available(iOS 26.0,macOS 26.0, *)
class PListGlass: UIViewController {
   func organize(_ results:NSArray) {
        let database = SwiftHelper.readDatabase()
        let premiumEmail = Features.readPremiumEmail()
        let currentExtreme = database["extremePrivacy"] as? String ?? "false"
        let extreme = (currentExtreme.lowercased() == "true")
        var i = 0
        for rawRecord in results {
            let record = rawRecord as? NSDictionary ?? NSDictionary()
            let element = NSMutableDictionary()
            if(record["name"] != nil){
                var newValue = record["name"] as? String ?? ""
                if(extreme) {
                    newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey())
                }
                element["name"] = newValue
            }
            if(record["observation"] != nil){
                if(record["observation"] as? String != ""){
                    var newValue = record["observation"] as? String ?? ""
                    if(extreme) {
                        newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey()) 
                    }
                    element["observation"] = newValue
                }
            }
            if(record["description"] != nil){
                if(record["description"] as? String != ""){
                    var newValue = record["description"] as? String ?? ""
                    if(extreme) {
                        newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey()) 
                    }
                    element["description"] = newValue
                }
            }
            if(record["userHandle"] != nil){
                if(record["userHandle"] as? String != ""){
                    var newValue = record["userHandle"] as? String ?? ""
                    if(extreme) {
                        newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey()) 
                    }
                    element["userHandle"] = newValue
                }
            }
            if(record["credentialID"] != nil){
                if(record["credentialID"] as? String != ""){
                    var newValue = record["credentialID"] as? String ?? ""
                    if(extreme) {
                        newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey()) 
                    }
                    element["credentialID"] = newValue
                }
            }
            if(record["recordIdentifier"] != nil){
                if(record["recordIdentifier"] as? String != ""){
                    var newValue = record["recordIdentifier"] as? String ?? ""
                    if(extreme) {
                        newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey()) 
                    }
                    element["recordIdentifier"] = newValue
                }
            }
            
            if(record["old"] != nil){
                if(record["old"] as? String != ""){
                    var newValue = record["old"] as? String ?? ""
                    if(extreme) {
                        newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey()) 
                    }
                    element["old"] = newValue
                }
            }
            if(record["password"] != nil){
                var newValue = record["password"] as? String ?? ""
                if(extreme) {
                    newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey()) 
                }
                element["password"] = newValue
            }
            if(record["secret"] != nil){
                var newValue = record["secret"] as? String ?? ""
                if(extreme) {
                    newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey()) 
                }
                element["secret"] = newValue

            }
            if(record["period"] != nil){
                var newValue = record["period"] as? String ?? ""
                if(extreme) {
                    newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey())
                }
                element["period"] = newValue
            }
            if(record["digits"] != nil){
                var newValue = record["digits"] as? String ?? ""
                if(extreme) {
                    newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey())
                }
                element["digits"] = newValue
            }
            if(record["algorithm"] != nil){
                var newValue = record["algorithm"] as? String ?? ""
                if(extreme) {
                    newValue = SwiftHelper.extremeDecrypt(newValue, SwiftHelper.getRecoveryKey())
                }
                element["algorithm"] = newValue
            }
        }
    }
}
