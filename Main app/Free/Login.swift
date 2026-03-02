//
//  Login.swift
//  
//
//  Created by Davi Orzechowski on 21/03/24.
//

import Foundation
import LocalAuthentication
class Login:UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var police = LAPolicy.deviceOwnerAuthenticationWithBiometrics
#if targetEnvironment(macCatalyst)
        police = LAPolicy.deviceOwnerAuthentication
#endif
        openBiometry(police)
    }
    func openBiometry(_ police:LAPolicy){
        let myContext = LAContext()
        var error: NSError?
        let myLocalizedReasonString = NSLocalizedString("Login.touchid", comment: "")
        let database = SwiftHelper.readDatabase()
        let currentFingerprintData = database["fingerPrint"] as? Data ?? Data()
        if(myContext.canEvaluatePolicy(police, error: &error)){
            myContext.evaluatePolicy(police, localizedReason: myLocalizedReasonString, reply: {
                success,error in
                if (success) {
                    DispatchQueue.main.async(execute: {
                        self.newFingerPrintData = myContext.evaluatedPolicyDomainState ?? Data()
                        if(currentFingerprintData != nil && currentFingerprintData?.isEqual(to: self.newFingerPrintData!) == false){
                            if(myContext.biometryType == .faceID){
                                /*Face ID changed, request password*/
                            } else {
                                /*Touch ID changed, request password*/
                            }
                        } else {
                            /*Success, vault encryption key unlocked*/
                        }
                    })
                } else {
                    /*Wrong FaceID/TouchID*/
                }
            })
        } else {
            /*Wrong FaceID/TouchID*/
        }
    }
    @IBAction func start(_ sender:Any){
        let database = SwiftHelper.readDatabase()
        let challenge = database["challenge"] as? String ?? ""
        let salt = Data(base64Encoded: database["salt"] as? String ?? "") ?? Data()
        let derivated = SwiftHelper.deriveKeyPBKDF2(password: master?.text ?? "", salt: salt)
        globals.encryptionKey = derivated
        SwiftHelper.saveVaultKeyToKeychain(key: derivated)
        /*Check if key can solve the challenge*/
        let result = SwiftHelper.decryptStringAES(challenge)
        if(result == "ok"){
            if(newFingerPrintData.count != 0){
                database["fingerPrint"] = newFingerPrintData
                SwiftHelper.saveDatabase(database)
            }
            /*Success*/
        } else {
            /*Wrong key*/
        }
    }
}
