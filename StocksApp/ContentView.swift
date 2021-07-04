//
//  ContentView.swift
//  StocksApp
//
//  Created by Hunter Kingsbeer on 29/06/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            VStack {
                HStack(alignment: .center){
                    Text("Portfolio.")
                        .font(.system(.largeTitle, design: .rounded))
                        .foregroundColor(Color("accent"))
                    Spacer()
                    RoundedRectangle(cornerRadius: 50)
                        .frame(width: UIScreen.screenWidth * 0.15, height: UIScreen.screenHeight * 0.05)
                        .foregroundColor(Color("accent"))
                        .overlay(
                            Image(systemName: true ? "gearshape.fill" : "eye")
                                .foregroundColor(Color("text"))
                                .font(.title)
                        )
                }.padding()
                
                ScrollView([], showsIndicators: false) {
                    VStack {
                        // stock scrollview
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<6) { _ in
                                    StockCard()
                                }
                            }.padding(.horizontal)
                        }
                        // category scrollview
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<6) { _ in
                                    CategoryCard()
                                }
                            }.padding(.horizontal)
                        }
                    }
                }
                Spacer()
            }
            BottomSheet()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

/// Retrieves the screen size of the user's device.
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct BottomSheet: View {
    @State var offset = CGSize(width: 0, height: UIScreen.screenHeight * 0.65)
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .foregroundColor(Color("object"))
            .overlay(
                VStack {
                    DragBar(offset: $offset)
                    
                    Text("$1,000")
                        .font(.system(size: 50, design: .rounded)).bold()
                        .padding(1)
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("RETURN".uppercased())
                                .font(.system(.body, design: .rounded)).bold()
                            Text("$\(UIScreen.screenHeight * 0.695, specifier: "%.0f")")
                                .font(.system(.largeTitle, design: .rounded)).bold()
                                .foregroundColor(Color("green"))
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Percentage".uppercased())
                                .font(.system(.body, design: .rounded)).bold()
                                //.foregroundColor(Color("background"))
                            Text("\(offset.height, specifier: "%.0f")%")
                                .font(.system(.largeTitle, design: .rounded)).bold()
                                .foregroundColor(Color("green"))
                        }
                    }
                    Spacer()
                }.padding(.horizontal)
            )
            .ignoresSafeArea(edges: /*@START_MENU_TOKEN@*/.bottom/*@END_MENU_TOKEN@*/).padding(.top)
            .offset(y: offset.height).animation(.spring())
    }
}

struct DragBar: View {
    @Binding var offset : CGSize
    
    var body: some View {
        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
            .frame(width: UIScreen.screenWidth * 0.1, height: UIScreen.screenHeight * 0.008)
            .foregroundColor(Color("background"))
            .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.03)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = CGSize(width: (gesture.translation.width), height: (gesture.translation.height)*2)
                    }
                    .onEnded { _ in
                        if abs(offset.height) < UIScreen.screenHeight * 0.575 {
                            offset.height = UIScreen.screenHeight * 0.06 // at top
                        } else {
                            offset.height = UIScreen.screenHeight * 0.65 // at bottom
                        }
                    }
            )
    }
}

struct CategoryCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(Color("red"))
            RoundedRectangle(cornerRadius: 24)
                .foregroundColor(Color("object"))
                .overlay(
                    VStack(alignment: .leading){
                        HStack {
                            Text("Category")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Image(systemName: "aqi.medium")
                                .font(.system(.footnote))
                            Image(systemName: "smallcircle.circle")
                                .font(.system(.footnote))
                            Image(systemName: "rectangle.grid.1x2")
                                .font(.system(.footnote))
                        }.foregroundColor(Color("accentAlt"))
                        Text("Material Production")
                            .font(.system(.title, design: .rounded))
                            .lineLimit(2).multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(Color("text"))
                        Spacer()
                    }.padding()
                ).padding(1.5)
        }.frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.15)
    }
}

struct StockCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .foregroundColor(Color("object"))
            .overlay(
                VStack(alignment: .leading){
                    HStack {
                        Text("MEL")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Color("accentAlt"))
                        Image("MELwhite")
                            .resizable().renderingMode(.template)
                            .foregroundColor(Color("accentAlt"))
                            .scaledToFit().frame(height: UIScreen.screenHeight*0.025)
                        
                        Spacer()
                        Image(systemName: "bolt.fill")
                            .font(.system(.footnote))
                            .foregroundColor(Color("yellow"))
                    }.padding(.bottom, 1)
                    
                    Text("Merdian Energy")
                        .font(.system(.title, design: .rounded))
                        .lineLimit(2).minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color("text"))
                    Text("$5.82")
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color("accentAlt"))
                    Divider()
                    
                    Text("$10,311")
                        .font(.system(.title, design: .rounded)).bold()
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color("text"))
                    Text("$1,902")
                        .font(.system(.body, design: .rounded)).bold()
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color("green"))
                    Text("10.9%")
                        .font(.system(.body, design: .rounded)).bold()
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color("green"))
                    
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color("accent"))
                        .overlay(Image(systemName: "arrow.up.left.and.arrow.down.right").font(.body).foregroundColor(Color("object")))
                        .frame(height: UIScreen.screenHeight * 0.05)
                        .cornerRadius(15)
                }.padding()
            ).frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenHeight * 0.4)
    }
}
