//
//  PEdit.swift
//  AutoFillPasswords
//
//  Created by Davi Orzechowski on 22/03/24.
//

import Foundation

class PEditPasskey:UIViewController {
    func updateItem() {
        let postRecrod = NSMutableDictionary()
        let database = SwiftHelper.readDatabase()
        let extreme = isExtremePrivacyMode()
        let element = globals.ConfigParameters?["password"] as? NSDictionary ?? NSDictionary()

        var myName = uiexample?.text ?? ""
        if(extreme){
            myName = SwiftHelper.extremeEncrypt(myName, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["name"] = myName
        if(uiexample?.text?.count != 0){
            var myObservation = uiexample?.text
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["observation"] = myObservation
        }
        if(uiexample?.text?.count != 0 && uiexample?.text != NSLocalizedString("Add.placeholder", comment: "")){
            var myObservation = uiexample?.text ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["description"] = myObservation
        }
        if(element["userHandle"] != nil){
            var myObservation = element["userHandle"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["userHandle"] = myObservation
        }
        if(element["recordIdentifier"] != nil){
            var myObservation = element["recordIdentifier"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["recordIdentifier"] = myObservation
        }
        if(element["credentialID"] != nil){
            var myObservation = element["credentialID"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["credentialID"] = myObservation
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
        })
    }
}