//
//  ContentView.swift
//  PhoneAuthentic
//
//  Created by Dhanush on 24/01/20.
//  Copyright © 2020 Dhanush. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    var body: some View {
        VStack{
            if status{
                Home()
            }
            else{
                NavigationView{
                    FirstPage()
                }
            }
        }.onAppear{
            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChanged"), object: nil, queue: .main){
                (_) in
                let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                self.status = status
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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
                        
                        TextField("Number", text: self.$no)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color("Color"))
                    }.padding(.top,15)
                    NavigationLink(destination: SecondPage(show: self.$show, ID: self.$ID), isActive: self.$show){
                        Button(action: {
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

struct SecondPage : View {
    @Binding var show : Bool
    @State var code = ""
    @Binding var ID : String
    @State var msg = ""
    @State var alert  = false
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
                        .padding(.top,15)
                    Button(action: {
                        let credentials =  PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.code)
                        Auth.auth().signIn(with: credentials) {(res, err) in
                            if err != nil{
                                self.msg = (err?.localizedDescription)!
                                self.alert.toggle()
                                return
                            }
                            UserDefaults.standard.set(true, forKey: "status")
                            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                        }
                    }){
                        Text("Verify")
                            .frame(width: UIScreen.main.bounds.width - 30  , height: 50)
                    }.foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .navigationBarTitle("")
                        .navigationBarHidden(true)
                        .navigationBarHidden(true)
                }
            }
            Button(action: {
                self.show.toggle()
            }){
                Image(systemName: "chevron.left")
                    .font(.title)
            }.foregroundColor(.orange)
            
        }.padding()
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
    }
}

struct Home : View {
    var body : some View{
        VStack{
            Text("Home")
            Button(action: {
                try! Auth.auth().signOut()
                UserDefaults.standard.set(true, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
            }){
                Text("Logout")
            }
        }
    }
}
