//
//  AddDoc.swift
//  
//
//  Created by Davi Orzechowski on 24/01/24.
//

import Foundation

class AddDoc:UIViewController {
    @IBAction func create(_ sender:Any){
        let database = SwiftHelper.readDatabase()
        let passwords = database["passwords"] as? NSMutableArray ?? NSMutableArray()
        if(passwords.count < 5)
        {
            let database_passwords = database["passwords"] as? NSMutableArray ?? NSMutableArray()
            database_passwords = addItemToSave(database_passwords) //Organize JSON to save locally
            database["passwords"] = database_passwords
            SwiftHelper.saveDatabase(database)
        }
    }
}
