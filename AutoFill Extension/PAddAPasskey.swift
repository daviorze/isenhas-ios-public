//
//  PAddA.swift
//  AutoFillPasswords
//
//  Created by Davi Orzechowski on 22/03/24.
//. Create new passkey

import Foundation

class PAddAPasskey:UIViewController {
    func createItem(_ userHandle:Data,_ recordIdentifier:String,_ credentialID:Data,_ passkeyCredential:ASPasskeyRegistrationCredential){
        let postRecrod = NSMutableDictionary()
        let database = SwiftHelper.readDatabase()
        let extreme = isExtremePrivacyMode()
        var myName = uiexample.text ?? ""
        if(extreme){
            myName = SwiftHelper.extremeEncrypt(myName, SwiftHelper.getRecoveryKey())
        }
        postRecrod["name"] = myName
        if(uiexample.text?.count != 0){
            var myObservation = uiexample.text ?? ""
            if(extreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["observation"] = myObservation
        }
        if(uiexample.text?.count != 0 && uiexample.text != NSLocalizedString("Add.placeholder", comment: "")){
            var myDescription = uiexample.text ?? ""
            if(extreme){
                myDescription = SwiftHelper.extremeEncrypt(myDescription, SwiftHelper.getRecoveryKey()) 
            }
            postRecrod["description"] = myDescription
        }
        var myuserHandle = Features.data(toString:userHandle) ?? ""
        if(extreme){
            myuserHandle = SwiftHelper.extremeEncrypt(myuserHandle, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["userHandle"] = myuserHandle
        var myrecordIdentifier = recordIdentifier
        if(extreme){
            myrecordIdentifier = SwiftHelper.extremeEncrypt(myrecordIdentifier, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["recordIdentifier"] = myrecordIdentifier
        var mycredentialID = Features.data(toString:credentialID) ?? ""
        if(extreme){
            mycredentialID = SwiftHelper.extremeEncrypt(mycredentialID, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["credentialID"] = mycredentialID
        let downloadQueue = DispatchQueue(label: "downloader")
        downloadQueue.async(execute: {
            let api = API()
            api.createSingleItem(postRecrod, completion: {
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
