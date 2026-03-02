//
//  PResult.swift
//  
//
//  Created by Davi Orzechowski on 14/03/24.
//

import Foundation

class PResultPasskey:UIViewController {
    /*Update item when user enable/disable favorite*/
    func updateItem()
    {
        let selected_pass = globals.ConfigParameters?["password"] as? NSMutableDictionary ?? NSMutableDictionary()
        let postRecrod = NSMutableDictionary()
        let database = SwiftHelper.readDatabase()
        let extreme = isExtremePrivacyMode()

        var myName = selected_pass["name"] as? String ?? ""
        if(extreme){
            myName = SwiftHelper.extremeEncrypt(myName, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["name"] = myName
        if(selected_pass["observation"] != nil){
            var myObservation = selected_pass["observation"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey())
            }
            postRecrod["observation"] = myObservation
        }
        if(selected_pass["description"] != nil){
            var myObservation = selected_pass["description"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["description"] = myObservation
        }
        if(isFavorite){
            postRecrod["favorite"] = "ok"
        }
        if(selected_pass["userHandle"] != nil){
            var myObservation = selected_pass["userHandle"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey())
            }
            postRecrod["userHandle"] = myObservation
        }
        if(selected_pass["credentialID"] != nil){
            var myObservation = selected_pass["credentialID"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["credentialID"] = myObservation
        }
        if(selected_pass["recordIdentifier"] != nil){
            var myObservation = selected_pass["recordIdentifier"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["recordIdentifier"] = myObservation
        }
        let downloadQueue = DispatchQueue(label: "downloader")
        downloadQueue.async(execute: {
            let api = API()
            api.updateItem(postRecrod, completion: {
                result in
                DispatchQueue.main.async(execute: {
                    let statusCode = (result?["statusCode"] as? NSString ?? "400").integerValue
                    if(statusCode == 200){
                        let database_passwords = database["passwords"] as? NSMutableArray ?? NSMutableArray()
                        database_passwords = organizeItemToSave(database_passwords,postRecrod) //Organize JSON to save locally
                        database["passwords"] = database_passwords
                        SwiftHelper.saveDatabase(database)
                    }
                })
            })
        });
    }
}
