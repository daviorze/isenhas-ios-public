//
//  ConfirmMasterKey.swift
//  
//
//  Created by Davi Orzechowski on 05/03/24.
//

import Foundation

class ConfirmMasterKey:UIViewController {
    
    @IBAction func start(_ sender:Any){
        let database = SwiftHelper.readDatabase()
        let challenge = database["challenge"] as? String ?? ""
        let salt = Data(base64Encoded: database["salt"] as? String ?? "") ?? Data()
        let derivated = SwiftHelper.deriveKeyPBKDF2(password: uiexample?.text ?? "", salt: salt)
        globals.encryptionKey = derivated
        /*Check if key can solve the challenge*/
        let result = SwiftHelper.decryptStringAES(challenge)
        if(result == "ok"){
            /*Success*/
        }
    } 
}
