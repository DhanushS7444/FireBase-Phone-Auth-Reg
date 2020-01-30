//
//  SecondPage.swift
//  PhoneAuthentic
//
//  Created by Dhanush on 30/01/20.
//  Copyright © 2020 Dhanush. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct SecondPage : View {
    @Binding var show : Bool
    @State var code = ""
    @Binding var ID : String
    @State var msg = ""
    @State var alert  = false
    @State var creation = false
    @State var loading = false
    var body : some View {
        ZStack(alignment: .topLeading) {
            GeometryReader{_ in
                VStack(spacing : 20) {
                    Text("Verification Code")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Text("Please Enter Verification Code")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top,12)
                    
                    TextField("Code", text: self.$code)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color("Color"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top,15)
                    
                    if self.loading{
                        HStack{
                            Spacer()
                            Indicator()
                            Spacer()
                        }
                    }
                    else
                    {
                        Button(action: {
                            self.loading.toggle()
                            let credentials =  PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.code)
                            Auth.auth().signIn(with: credentials) {(res, err) in
                                if err != nil{
                                    self.msg = (err?.localizedDescription)!
                                    self.alert.toggle()
                                    self.loading.toggle()
                                    return
                                }
                                checkUser{(exists, user) in
                                    if exists{
                                        UserDefaults.standard.set(true, forKey: "status")
                                        UserDefaults.standard.set(user, forKey: "UserName")
                                        NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                                    }
                                    else{
                                        self.loading.toggle()
                                        self.creation.toggle()
                                    }
                                }
                                
                            }
                        }){
                            Text("Verify")
                                .frame(width: UIScreen.main.bounds.width - 30  , height: 50)
                        }.foregroundColor(.white)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                }
            }
            Button(action: {
                self.show.toggle()
            }){
                Image(systemName: "chevron.left")
                    .font(.title)
            }.foregroundColor(.orange)
            
        }.padding()
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarHidden(true)
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
        .sheet(isPresented: self.$creation){
            AccountCreation(show: self.$creation)
        }
    }
}
