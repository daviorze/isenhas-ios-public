//
//  AddPix.swift
//  
//
//  Created by Davi Orzechowski on 06/03/24.
//

import Foundation

class AddPix:UIViewController {
    @IBAction func create(_ sender:Any){
        let database = SwiftHelper.readDatabase()
        let passwords = database["passwords"] as? NSMutableArray ?? NSMutableArray()
        if(passwords.count < 5){
            let database_passwords = database["passwords"] as? NSMutableArray ?? NSMutableArray()
            database_passwords = addItemToSave(database_passwords) //Organize JSON to save locally
            database["passwords"] = database_passwords
            SwiftHelper.saveDatabase(database)
        }
    }
}
