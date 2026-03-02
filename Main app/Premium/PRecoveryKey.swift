//
//  PRecoveryKey.swift
//  isenhas
//
//  Created by Davi Orzechowski on 18/08/23.
//

import Foundation
import CryptoKit

class PRecoveryKey: UIViewController {

    /*Create a new recovery key to store locally encrypted, and send the sha256 hash to the cloud.*/
    func generateKey() -> String {
        var keyData = Data(count: 32)
        _ = keyData.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!) }
    
        let charset = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var humanReadable = ""
        
        for byte in keyData {
            let index = Int(byte) % charset.count
            humanReadable.append(charset[index])
        }
        
        var blocks: [String] = []
        var i = humanReadable.startIndex
        while i < humanReadable.endIndex {
            let end = humanReadable.index(i, offsetBy: 6, limitedBy: humanReadable.endIndex) ?? humanReadable.endIndex
            blocks.append(String(humanReadable[i..<end]))
            i = end
        }
        
        let formattedKey = blocks.joined(separator: "-")
        return formattedKey
    }
    func updateUser(_ recoveryCode:String,_ extremePrivacy:String,_ recoveryEnabled:String){
        let body = NSMutableDictionary()
        let user = NSMutableDictionary()
        if(!recoveryCode.isEmpty){
            user["recovery"] = Features.sha256Hash(forText: recoveryCode)
        }
        user["recoveryenabled"] = recoveryEnabled //Recovery key hash sha256
        user["extremeprivacy"] = extremePrivacy //true or false
        body["user"] = user
        let downloadQueue = DispatchQueue(label: "downloader")
        downloadQueue.async(execute: {
            let api = API()
            api.updateuser(body, completion: { result in
                DispatchQueue.main.async(execute: {
                    let statusCode = result?["statusCode"] as? String
                    if(statusCode == "200"){
                        if(!recoveryCode.isEmpty){
                            SwiftHelper.saveRecoveryKey(recoveryCode) //encrypt and save in local database
                        }
                    } 
                })
            })
        })
    }
    func updatePassword(_ interation:Int,_ passwords:NSMutableArray,_ extremePrivacy:String){
        if(extremePrivacy == "true"){
            password = encryptPassword(password) //User enable zero knowledge
        } else {
            password = decryptPassword(password) //User disable zero knowledge
        }
        let downloadQueue = DispatchQueue(label: "downloader")
        downloadQueue.async(execute: {
            let api = API()
            api.updateItem(password, completion: {
                result in
                DispatchQueue.main.async(execute: {
                    let statusCode = (result?["statusCode"] as? NSString ?? "400").integerValue
                    if(statusCode == 200){
                        /*continue updating all vault items*/
                    } 
                })
            })
        })
    }
    func encryptPassword(_ element:NSMutableDictionary) -> NSMutableDictionary{
        let postRecrod = NSMutableDictionary()
        var myName = element["name"] as? String ?? ""
        postRecrod["name"] = SwiftHelper.extremeEncrypt(myName,SwiftHelper.getRecoveryKey())
        if(element["observation"] != nil){
            let observation = element["observation"] as? String ?? ""
            postRecrod["observation"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        if(element["description"] != nil){
            let observation = element["description"] as? String ?? ""
            postRecrod["description"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        if(element["password"] != nil){
            let observation = element["password"] as? String ?? ""
            postRecrod["password"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        if(element["old"] != nil){
            let observation = element["old"] as? String ?? ""
            postRecrod["old"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        if(element["secret"] != nil){
            let observation = element["secret"] as? String ?? ""
            postRecrod["secret"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        if(element["period"] != nil){
            let observation = element["period"] as? String ?? ""
            postRecrod["period"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        if(element["algorithm"] != nil){
            let observation = element["algorithm"] as? String ?? ""
            postRecrod["algorithm"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        if(element["digits"] != nil){
            let observation = element["digits"] as? String ?? ""
            postRecrod["digits"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        if(element["userHandle"] != nil){
            let observation = element["userHandle"] as? String ?? ""
            postRecrod["userHandle"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        if(element["recordIdentifier"] != nil){
            let observation = element["recordIdentifier"] as? String ?? ""
            postRecrod["recordIdentifier"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        if(element["credentialID"] != nil){
            let observation = element["credentialID"] as? String ?? ""
            postRecrod["credentialID"] = SwiftHelper.extremeEncrypt(observation, SwiftHelper.getRecoveryKey())
        }
        return postRecrod
    }
    func decryptPassword(_ element:NSMutableDictionary) -> NSMutableDictionary{
        let postRecrod = NSMutableDictionary()
        var myName = element["name"] as? String ?? ""
        myName = SwiftHelper.extremeDecrypt(myName, SwiftHelper.getRecoveryKey())
        postRecrod["name"] = myName
        if(element["observation"] != nil){
            var observation = element["observation"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey()) 
            postRecrod["observation"] = observation
        }
        if(element["description"] != nil){
            var observation = element["description"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey()) 
            postRecrod["description"] = observation
        }
        if(element["password"] != nil){
            var observation = element["password"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey()) 
            postRecrod["password"] = observation
        }
        if(element["password"] != nil){
            var observation = element["password"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey()) 
            postRecrod["password"] = observation
        }
        if(element["old"] != nil){
            var observation = element["old"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey())
            postRecrod["old"] = observation
        }
        postRecrod["encrypted"] = "1"
        if(element["favorite"] != nil){
            postRecrod["favorite"] = "ok"
        }
        if(element["secret"] != nil){
            var observation = element["secret"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey())
            postRecrod["secret"] = observation
        }
        if(element["period"] != nil){
            var observation = element["period"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey()) 
            postRecrod["period"] = observation
        }
        if(element["algorithm"] != nil){
            var observation = element["algorithm"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey()) 
            postRecrod["algorithm"] = observation
        }
        if(element["digits"] != nil){
            var observation = element["digits"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey()) 
            postRecrod["digits"] = observation
        }
        if(element["type"] != nil){
            postRecrod["type"] = element["type"] as? String ?? ""
        }
        if(element["userHandle"] != nil){
            var observation = element["userHandle"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey()) 
            postRecrod["userHandle"] = observation
        }
        if(element["recordIdentifier"] != nil){
            var observation = element["recordIdentifier"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey()) 
            postRecrod["recordIdentifier"] = observation
        }
        if(element["credentialID"] != nil){
            var observation = element["credentialID"] as? String ?? ""
            observation = SwiftHelper.extremeDecrypt(observation, SwiftHelper.getRecoveryKey()) 
            postRecrod["credentialID"] = observation
        }
        postRecrod["id"] = element["id"] as? String ?? ""
        return postRecrod
    }
}
