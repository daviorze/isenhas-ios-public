//
//  ChangeMasterKey.swift
//  
//
//  Created by Davi Orzechowski on 06/03/24.
//

import Foundation

class ChangeMasterKey:UIViewController {
    @IBAction func create(_ sender:Any){
        if(uiexample?.text?.count != 0 && uiexample?.text == uiexample2?.text && uiexample2?.text?.count != 0)
        {
            let database = SwiftHelper.readDatabase()
            let salt = SwiftHelper.randomSalt()
            let derivated = SwiftHelper.deriveKeyPBKDF2(password: uiexample?.text ?? "", salt: salt) //Derivate AccessKey
            globals.encryptionKey = derivated
            SwiftHelper.saveVaultKeyToKeychain(key: derivated) //Save Access key to keychain
            database["salt"] = salt.base64EncodedString()
            let okEncrypted = SwiftHelper.encryptStringAES("ok")
            database["challenge"] = okEncrypted //Create a challenge to use to Sign in
            SwiftHelper.saveDatabase(database)
        }
    }
}
