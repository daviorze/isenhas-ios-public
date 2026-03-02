//
//  PEdit.swift
//  
//
//  Created by Davi Orzechowski on 18/03/24.
//

import Foundation

class PEdit:UIViewController {
    func updateItem(){
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
            var myObservation = uiexample?.text ?? ""
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
        var myPasswordc = uiexample?.text ?? ""
        if(extreme){
            myPasswordc = SwiftHelper.extremeEncrypt(myPasswordc, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["password"] = myPasswordc
        let myPassword = uiexample?.text
        if(passwordChanged(myPassword))
        {
            var old = getOldPassword()
            if(extreme){
                old = SwiftHelper.extremeEncrypt(old, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["old"] = old
        } else if(element["old"] != nil){
            var old = element["old"] as? String ?? ""
            if(extreme){
                old = SwiftHelper.extremeEncrypt(old, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["old"] = old
        }
        if(element["secret"] != nil){
            var mySecret = element["secret"] as? String ?? ""
            if(extreme){
                mySecret = SwiftHelper.extremeEncrypt(mySecret, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["secret"] = mySecret
        }
        if(element["period"] != nil){
            var mySecret = element["period"] as? String ?? ""
            if(extreme){
                mySecret = SwiftHelper.extremeEncrypt(mySecret, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["period"] = mySecret
        }
        if(element["algorithm"] != nil){
            var mySecret = element["algorithm"] as? String ?? ""
            if(extreme){
                mySecret = SwiftHelper.extremeEncrypt(mySecret, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["algorithm"] = mySecret
        }
        if(element["digits"] != nil){
            var mySecret = element["digits"] as? String ?? ""
            if(extreme){
                mySecret = SwiftHelper.extremeEncrypt(mySecret, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["digits"] = mySecret
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