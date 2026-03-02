//
//  Passwords.swift
//  
//
//  Created by Davi Orzechowski on 04/03/24.
//

import Foundation

class MfaPasswords:UIViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let database = SwiftHelper.readDatabase()
        let database_passwords = database["passwords"] as? NSMutableArray ?? NSMutableArray()
        database_passwords = replaceItemToSave(database_passwords,indexPath.row) //Organize JSON to save locally
        database["passwords"] = database_passwords
        SwiftHelper.saveDatabase(database)
    }
}
