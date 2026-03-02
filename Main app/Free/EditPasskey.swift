
//
//  EditA.swift
//  AutoFillPasswords
//
//  Created by Davi Orzechowski on 22/03/24.
//

import Foundation

class EditPasskey:UIViewController {
    @IBAction func edit(_ sender:Any)
    {
        let database = SwiftHelper.readDatabase()
        let database_passwords = database["passwords"] as? NSMutableArray ?? NSMutableArray()
        database_passwords = replaceItemToSave(database_passwords) //Organize JSON to save locally
        database["passwords"] = database_passwords
        SwiftHelper.saveDatabase(database)
    }
}
