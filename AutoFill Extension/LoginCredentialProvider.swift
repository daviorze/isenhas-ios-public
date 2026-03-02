//
//  LoginCredentialProvider.swift
//  AutoFillPasswords
//
//  Created by Davi Orzechowski on 30/06/23.
//  Autofill login class

import Foundation
import AuthenticationServices
import LocalAuthentication

class LoginCredentialProvider:ASCredentialProviderViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        /*Request Biometry*/
        var police = LAPolicy.deviceOwnerAuthenticationWithBiometrics
#if targetEnvironment(macCatalyst)
        police = LAPolicy.deviceOwnerAuthentication
#endif
        if(myContext.canEvaluatePolicy(police, error: nil)){
            myContext.evaluatePolicy(police, localizedReason: myLocalizedReasonString, reply: { (success,error) in
                if(success){
                    DispatchQueue.main.async {
                        self.newFingerPrintData = myContext.evaluatedPolicyDomainState
                        if(currentFingerprintData != nil && currentFingerprintData?.isEqual(to: self.newFingerPrintData!) == false){
                            if(myContext.biometryType == .faceID){
                                /*Face ID changed, request password*/
                            } else {
                                /*Touch ID changed, request password*/
                            }
                        } else {
                            /*Success, vault encryption key unlocked*/
                        }
                    }
                } else {
                    /*Wrong FaceID/TouchID*/
                }
            })
        } else {
            /*Wrong FaceID/TouchID*/
        }
        
    }
    @objc
    @IBAction func start(_ sender:Any){
        let database = SwiftHelper.readDatabase()
        let challenge = database["challenge"] as? String ?? ""
        let salt = Data(base64Encoded: database["salt"] as? String ?? "") ?? Data()
        let derivated = SwiftHelper.deriveKeyPBKDF2(password: master?.text ?? "", salt: salt)
        globals.encryptionKey = derivated
        /*Check if key can solve the challenge*/
        let result = SwiftHelper.decryptStringAES(challenge)
        if(result == "ok"){
            if(newFingerPrintData != nil){
                database["fingerPrintAutofill"] = newFingerPrintData
                SwiftHelper.saveDatabase(database)
            }
            /*Success*/
        } else {
            /*Wrong key*/
        }
    }
    
}
