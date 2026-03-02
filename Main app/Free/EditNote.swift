//
//  EditNote.swift
//  
//
//  Created by Davi Orzechowski on 06/03/24.
//

import Foundation

class EditNote:UIViewController {
    @IBAction func edit(_ sender:Any)
    {
        let database = SwiftHelper.readDatabase()
        let database_passwords = database["passwords"] as? NSMutableArray ?? NSMutableArray()
        database_passwords = replaceItemToSave(database_passwords) //Organize JSON to save locally
        database["passwords"] = database_passwords
        SwiftHelper.saveDatabase(database)
    }
}
