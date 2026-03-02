//
//  NewDoc.swift
//
//  Created by Davi Orzechowski on 03/07/24.
//

import Foundation
import AppIntents

@available(iOS 16, *)
class NewDoc: AppIntent {
    var postRecrod = NSMutableDictionary()
    func sendItem(_ isExtreme:Bool,_ recoveryKey:String) async -> Bool {
        var myName = name
        if(isExtreme){
            myName = SwiftHelper.extremeEncrypt(myName,recoveryKey) ?? ""
        }
        postRecrod["name"] = myName
        if(expire.count != 0){
            var myDesc = expire
            if(isExtreme){
                myDesc = SwiftHelper.extremeEncrypt(myDesc,recoveryKey) ?? ""
            }
            postRecrod["observation"] = myDesc
        }
        if(annotation.count != 0){
            var myDesc = annotation
            if(isExtreme){
                myDesc = SwiftHelper.extremeEncrypt(myDesc,recoveryKey) ?? ""
            }
            postRecrod["description"] = myDesc
        }
        var myPassword = code
        if(isExtreme){
            myPassword = SwiftHelper.extremeEncrypt(myPassword,recoveryKey) ?? ""
        }
        postRecrod["password"] = myPassword
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
