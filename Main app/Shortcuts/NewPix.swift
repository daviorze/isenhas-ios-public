//
//  NewPix.swift
//
//  Created by Davi Orzechowski on 03/07/24.
//

import Foundation
import AppIntents

@available(iOS 16, *)
class NewPix: AppIntent,@unchecked Sendable {
    let postRecrod = NSMutableDictionary()
    func sendItem(_ isExtreme:Bool,_ recoveryKey:String) async -> Bool {
        var myName = name
        if(isExtreme){
            myName = SwiftHelper.extremeEncrypt(myName,recoveryKey) ?? ""
        }
        postRecrod["name"] = myName
        if(description.count != 0){
            var myObservation = description
            if(isExtreme){
                myObservation = SwiftHelper.extremeEncrypt(myObservation,recoveryKey) ?? ""
            }
            postRecrod["observation"] = myObservation
        }
        var myPassword = pix
        if(isExtreme){
            myPassword = SwiftHelper.extremeEncrypt(myPassword,recoveryKey) ?? ""
        }
        postRecrod["password"] = myPassword
        postRecrod["encrypted"] = "1"
        return await withCheckedContinuation { continuation in
            let api = API()
            api.createSingleItem(self.postRecrod, completion: {
                result in
                DispatchQueue.main.async(execute: {
                    let statusCode = (result?["statusCode"] as? NSString ?? "400").integerValue
                    if(statusCode == 200){
                        let database_passwords = database["passwords"] as? NSMutableArray ?? NSMutableArray()
                        database_passwords = organizeItemToSave(database_passwords,postRecrod) //Organize JSON to save locally
                        database["passwords"] = database_passwords
                        SwiftHelper.saveDatabase(database)
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                })
            })
        }
    }
}
