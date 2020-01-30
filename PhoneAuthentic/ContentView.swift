//
//  ContentView.swift
//  PhoneAuthentic
//
//  Created by Dhanush on 24/01/20.
//  Copyright © 2020 Dhanush. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

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
            NotificationCenter.default.addObserver(forName: NSNotification.Name("statusChange"), object: nil, queue: .main){
                (_) in
                let status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                self.status = status
            }
        }
    }
}
struct ImagePicker : UIViewControllerRepresentable {
    
    @Binding var picker : Bool
    @Binding var imageData : Data
    
    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePicker.Coordinator(parent1.self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    class Coordinator : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent : ImagePicker
        init(parent1 : ImagePicker) {
            parent = parent1
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.picker.toggle()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as! UIImage
            let data = image.jpegData(compressionQuality: 0.45)
            self.parent.imageData = data!
            self.parent.picker.toggle()
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
                            //Auth.auth().settings?.isAppVerificationDisabledForTesting = true
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

struct Home : View {
    var body : some View{
        VStack{
            Text("Welcome \(UserDefaults.standard.value(forKey: "UserName") as! String)")
            Text("Home")
            Button(action: {
                try! Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
            }){
                Text("Logout")
            }
        }
    }
}

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

struct AccountCreation : View {
    @Binding var show : Bool
    @State var name = ""
    @State var about = ""
    @State var picker = false
    @State var loading = false
    @State var alert = false
    @State var imageData: Data = .init(count : 0)
    var body : some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Awesome !!! Crate an Account")
                .font(.title)
            HStack{
                Spacer()
                Button(action : {
                    self.picker.toggle()
                }){
                    if self.imageData.count == 0 {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .resizable()
                            .frame(width: 90, height: 70)
                            .foregroundColor(.gray)
                    }else{
                        Image(uiImage : UIImage(data: self.imageData)!)
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 90, height: 70)
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding(.vertical, 15)
            
            Text("Enter User Name")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, 12)
            
            TextField("Name", text: self.$name)
                .keyboardType(.numberPad)
                .padding()
                .background(Color("Color"))
                .clipShape(RoundedRectangle(cornerSize: 10))
                .padding(.top, 15)
            
            Text("About You")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, 12)
            
            TextField("About", text: self.$about)
                .keyboardType(.numberPad)
            .padding()
            .background(Color("Color"))
                .clipShape(RoundedRectangle(cornerSize: 10))
                .padding(.top, 15)
            
            if self.loading{
                HStack{
                    Spacer()
                    Indicator()
                    Spacer()
                    
                }
            }else{
                Button(action : {
                    if self.name != "" && self.about != ""&& self.imageData.count != 0{
                        self.loading.toggle()
                    
                    }else{
                        self.alert.toggle()
                    }
                    
                    
                    
                }){
                    Text("Create")
                        .frame(width: UIScreen.main.bounds.width - 30, height: 50)
                }.foregroundColor(Color.white)
                    .background(Color.orange)
                .cornerRadius(10)
            }
            
        }
    }
}

struct Indicator : UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
        
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Indicator>) {
        
    }
}


func createUser(name : String, about: String, imageData : Data, Completion : @escaping(Bool) -> Void){
    let db = Firestore.firestore()
}
