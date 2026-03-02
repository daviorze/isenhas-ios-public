//
//  PResult.swift
//  
//
//  Created by Davi Orzechowski on 14/03/24.
//

import Foundation

class PResult:UIViewController {
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
        if(selected_pass["secret"] != nil){
            var myObservation = selected_pass["secret"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["secret"] = myObservation
        }
        if(selected_pass["period"] != nil){
            var myObservation = selected_pass["period"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["period"] = myObservation
        }
        if(selected_pass["algorithm"] != nil){
            var myObservation = selected_pass["algorithm"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["algorithm"] = myObservation
        }
        if(selected_pass["digits"] != nil){
            var myObservation = selected_pass["digits"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["digits"] = myObservation
        }
        var myPassword = selected_pass["password"] as? String ?? ""
        if(extreme){
            myPassword = SwiftHelper.extremeEncrypt(myPassword, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["password"] = myPassword
        if(selected_pass["old"] != nil){
            var myObservation = selected_pass["old"] as? String ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) ?? ""
            }
            postRecrod["old"] = myObservation
        }
        if(isFavorite){
            postRecrod["favorite"] = "ok"
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
