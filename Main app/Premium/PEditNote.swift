//
//  PEditNote.swift
//  
//
//  Created by Davi Orzechowski on 18/03/24.
//

import Foundation

class PEditNote:UIViewController {
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
        var myPassword = uiexample?.text ?? ""
        if(extreme){
            myPassword = SwiftHelper.extremeEncrypt(myPassword, SwiftHelper.getRecoveryKey()) 
        }
        postRecrod["password"] = myPassword
  
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
