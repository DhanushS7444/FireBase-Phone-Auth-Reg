//
//  FirstPage.swift
//  PhoneAuthentic
//
//  Created by Dhanush on 30/01/20.
//  Copyright © 2020 Dhanush. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct FirstPage : View {
    @State var show : Bool = false
    @State var no = ""
    @State var ccode = ""
    @State var alert : Bool = false
    @State var msg = ""
    @State var ID = ""
    var body : some View {
        
        ZStack(alignment: .topLeading) {
            GeometryReader{_ in
                VStack(spacing : 20) {
                    Text("Verify Your Number")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Text("Please Enter Your Number To Verify your Account")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top,12)
                    
                    HStack{
                        TextField("+91", text: self.$ccode)
                            .keyboardType(.numberPad)
                            .frame(width: 45)
                            .padding()
                            .background(Color("Color"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        TextField("Number", text: self.$no)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color("Color"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }.padding(.top,15)
                    NavigationLink(destination: SecondPage(show: self.$show, ID: self.$ID), isActive: self.$show){
                        Button(action: {
                            // remove this when u are using real phone numbers
                            Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                            PhoneAuthProvider.provider().verifyPhoneNumber("+"+self.ccode+self.no, uiDelegate: nil){(ID, err) in
                                if err != nil{
                                    self.msg = (err?.localizedDescription)!
                                    self.alert.toggle()
                                    return
                                }
                                self.ID = ID!
                                self.show.toggle()
                            }
                        }){
                            Text("Send")
                                .frame(width: UIScreen.main.bounds.width - 30  , height: 50)
                        }.foregroundColor(.white)
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .navigationBarHidden(true)
                }
            }
            
        }.padding()
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
    }
}
