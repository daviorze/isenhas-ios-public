//
//  MfaPasswords.swift
//
//
//  Created by Davi Orzechowski on 04/09/24.
//

import Foundation

class PMfaPasswords:UIViewController {
    
    func updateItem(_ currentPassword:NSMutableDictionary, _ mfa:NSMutableDictionary,_ originalIndex:Int){
        let postRecrod = NSMutableDictionary()
        let database = SwiftHelper.readDatabase()
        let extreme = isExtremePrivacyMode()

        var myName = currentPassword["name"] as? String ?? ""
        if(extreme){
            myName = SwiftHelper.extremeEncrypt(myName, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["name"] = myName
        if(currentPassword["observation"] != nil){
            var myObservation = currentPassword["observation"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey())
            }
            postRecrod["observation"] = myObservation
        }
        if(currentPassword["description"] != nil){
            var myDescription = currentPassword["description"] as? String ?? ""
            if(extreme){
                myDescription = SwiftHelper.extremeEncrypt(myDescription, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["description"] = myDescription
        }
        if(currentPassword["password"] != nil){
            var myPassword = currentPassword["password"] as? String ?? ""
            if(extreme){
                myPassword = SwiftHelper.extremeEncrypt(myPassword, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["password"] = myPassword
        }
        var mySecret = mfa["secret"] as? String ?? ""
        if(extreme){
            mySecret = SwiftHelper.extremeEncrypt(mySecret, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["secret"] = mySecret
        var myPeriod = mfa["period"] as? String ?? "30"
        if(extreme){
            myPeriod = SwiftHelper.extremeEncrypt(myPeriod, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["period"] = myPeriod
        var myAlgorithm = mfa["algorithm"] as? String ?? "SHA1"
        if(extreme){
            myAlgorithm = SwiftHelper.extremeEncrypt(myAlgorithm, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["algorithm"] = myAlgorithm
        var myDigits = mfa["digits"] as? String ?? "6"
        if(extreme){
            myDigits = SwiftHelper.extremeEncrypt(myDigits, SwiftHelper.getRecoveryKey())
        }
        postRecrod["digits"] = myDigits
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
