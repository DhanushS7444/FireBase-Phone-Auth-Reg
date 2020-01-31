//
//  Functionalities.swift
//  PhoneAuthentic
//
//  Created by Dhanush on 30/01/20.
//  Copyright © 2020 Dhanush. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

// creating user
func createUser(name: String,about : String,imageData : Data,completion : @escaping (Bool)-> Void){
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    let uid = Auth.auth().currentUser?.uid
    storage.child("profilepics").child(uid!).putData(imageData, metadata: nil) { (_, err) in
        if err != nil{
            print((err?.localizedDescription)!)
            return
        }
        storage.child("profilepics").child(uid!).downloadURL { (url, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            db.collection("users").document(uid!).setData(["name":name,"about":about,"pic":"\(url!)","uid":uid!]) { (err) in
                if err != nil{
                    print((err?.localizedDescription)!)
                    return
                }
                completion(true)
                UserDefaults.standard.set(true, forKey: "status")
                UserDefaults.standard.set(name, forKey: "UserName")
                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
            }
        }
    }
}

//checking the user
func checkUser(completion : @escaping (Bool, String) -> Void) {
    let db = Firestore.firestore()
    db.collection("users").getDocuments{(snap, err) in
        if err != nil {
            print((err?.localizedDescription)!)
            return
        }
        for i in snap!.documents {
            if i.documentID == Auth.auth().currentUser?.uid  {
                completion(true,i.get("name") as! String)
                return
            }
        }
        completion(false,"")
    }
}
