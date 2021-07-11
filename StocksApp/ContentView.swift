//
//  ContentView.swift
//  StocksApp
//
//  Created by Hunter Kingsbeer on 29/06/21.
//

import SwiftUI
import CoreData

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

enum StockMode {
    case expanding
    case editing
    case deleting
}

enum ScreenMode {
    case homepage
    case stocks
    case categories
    case stats
}

struct ContentView: View {
    @State var stockMode : StockMode = .expanding
    @State var screenMode : ScreenMode = .homepage
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            
            VStack {
                HStack(alignment: .center){
                    Text("Portfolio.")
                        .font(.system(.largeTitle, design: .rounded))
                        .foregroundColor(Color("text"))
                    Spacer()
                    RoundedRectangle(cornerRadius: 50)
                        .frame(width: UIScreen.screenWidth * 0.15, height: UIScreen.screenHeight * 0.05)
                        .foregroundColor(Color("accent"))
                        .overlay(
                            Image(systemName: true ? "gearshape.fill" : "eye")
                                .foregroundColor(Color("text"))
                                .font(.title)
                        )
                }.padding(.horizontal).padding(.bottom, 1)
                
                ScrollView([], showsIndicators: false) {
                    VStack {
                        // stock scrollview
                        StockView(stockMode: $stockMode, screenMode: $screenMode)
                            .transition(AnyTransition.move(edge: .trailing).combined(with: AnyTransition.opacity))

                        // category scrollview
                        CategoryView()
                            .transition(AnyTransition.move(edge: .trailing).combined(with: AnyTransition.opacity))
                            .animation(.spring())
                        
                        //actions scrollview
                        ActionView(stockMode: $stockMode)
                            .transition(AnyTransition.move(edge: .trailing).combined(with: AnyTransition.opacity))
                            .animation(.spring())
                    }
                }
            }.padding(.top)
            .ignoresSafeArea(edges: .bottom)
            VStack {
                if screenMode == .homepage || screenMode == .stats {
                    BottomSheet(screenMode: $screenMode)
                        .transition(AnyTransition.offset(y: UIScreen.screenHeight * 0.35))
                }
            }.ignoresSafeArea(edges: .bottom)
        }
    }
}

/// Retrieves the screen size of the user's device.
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct BottomSheet: View {
    @Binding var screenMode : ScreenMode
    
    var body: some View {
        VStack {
            if screenMode != .stats {
                Spacer()
            }
            
            VStack(alignment: .leading){
                Button(action: {
                    screenMode = screenMode == .stats ? .homepage : .stats
                }){
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.up")
                            .rotationEffect(.degrees(screenMode == .stats ? 180 : 0))
                            .animation(.spring())
                        Spacer()
                    }.font(.title)
                    .foregroundColor(Color("background"))
                }
                
                Text("$\(19345.32, specifier: "%.2f")")
                    .font(.system(size: 50, design: .rounded)).bold()
                    .lineLimit(1).minimumScaleFactor(0.8)
                    .padding(1)
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("RETURN".uppercased())
                            .font(.system(.body, design: .rounded)).bold()
                        Text("$\(2751.92, specifier: "%.2f")")
                            .font(.system(.largeTitle, design: .rounded)).bold()
                            .foregroundColor(Color("green"))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Percentage".uppercased())
                            .font(.system(.body, design: .rounded)).bold()
                            //.foregroundColor(Color("background"))
                        Text("\((2751.92/19345.32) * 10, specifier: "%.2f")%")
                            .font(.system(.largeTitle, design: .rounded)).bold()
                            .foregroundColor(Color("green"))
                    }
                }
                if screenMode == .stats {
                    Spacer()
                }
            }.padding().padding(.bottom, 20)
            .background(Color("object")).cornerRadius(25)
        }.padding(.top, 65)
        .ignoresSafeArea(edges: .bottom).animation(.spring())
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
    let category : Category
    
    var body: some View {
        let subicons = csvToArray(csv: category.subicons)
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(gradient: Gradient(colors: [Color(category.color), Color(category.color).opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            RoundedRectangle(cornerRadius: 24)
                .foregroundColor(Color("object"))
                .overlay(
                    VStack(alignment: .leading){
                        HStack {
                            Text("Category")
                                .font(.system(.body, design: .rounded))
                            Spacer()
                            Image(systemName: subicons[0])
                                .font(.system(.footnote))
                            Image(systemName: subicons[1])
                                .font(.system(.footnote))
                            Image(systemName: subicons[2])
                                .font(.system(.footnote))
                                .foregroundColor(Color(category.color))
                            
                        }.foregroundColor(Color("accentAlt"))
                        Text(category.title)
                            .font(.system(.title, design: .rounded))
                            .lineLimit(2).multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(Color("text"))
                        Spacer()
                    }.padding()
                ).padding(1.5)
        }.frame(width: UIScreen.screenWidth * 0.5, height: UIScreen.screenHeight * 0.15)
    }
}

struct StockCard: View {
    var stock : Stock
    @Binding var stockMode : StockMode
    @Binding var screenMode : ScreenMode
    @State var pendingDelete : Bool = false
    var price = 5.00
    
    var body: some View {
        let profit = (stock.shares * price)-stock.input > 0
        
        RoundedRectangle(cornerRadius: 25)
            .foregroundColor(Color("object"))
            .overlay(
                VStack(alignment: .leading){
                    HStack(alignment: .center) {
                        Text("\(stock.symbol ?? "")")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Color("accentAlt"))
                        Image("\(stock.symbol ?? "")white")
                            .resizable().renderingMode(.template)
                            .foregroundColor(Color("accentAlt"))
                            .scaledToFit().frame(height: UIScreen.screenHeight*0.025)
                        
                        Spacer()
                        Image(systemName: Category.icon(symbol: stock.category ?? ""))
                            .font(.system(.footnote))
                            .foregroundColor(Color(Category.color(symbol: stock.category ?? "")))
                    }.padding(.bottom, 1)
                    
                    Text("\(stock.title ?? "").")
                        .font(.system(.title, design: .rounded))
                        .lineLimit(2).minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color("text"))
                    Text("$\(price, specifier: "%.2f")")
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color("accentAlt"))
                    
                    Spacer()
                    Divider()
                    Text("$\(stock.shares * price, specifier: "%.0f")")
                        .font(.system(.title, design: .rounded)).bold()
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color("text"))
                    Text("\(profit ? "$" : "-$")\(abs((stock.shares * price)-stock.input), specifier: "%.2f")")
                        .font(.system(.body, design: .rounded)).bold()
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color(profit ? "green" : "red"))
                    Text("\(((stock.shares * price - stock.input)/stock.input)*100, specifier: "%.2f")%")
                        .font(.system(.body, design: .rounded)).bold()
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color(profit ? "green" : "red"))
                    
                    Button(action:{
                        withAnimation(Animation.spring()){
                            if stockMode == .deleting {
                                // deleting
                                if !pendingDelete {
                                    pendingDelete = true
                                } else {
                                    Stock.delete(stock: stock)
                                }
                            } else if stockMode == .editing {
                                screenMode = screenMode == .stocks ? .homepage : .stocks
                            } else {
                                screenMode = screenMode == .stocks ? .homepage : .stocks
                            }
                        }
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color(stockMode == .deleting ? "red" : "accent"))
                                .animation(.spring())
                            
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(Color(Stock.color(stockMode: stockMode, pendingDelete: pendingDelete)))
                                .overlay(
                                    VStack {
                                        if stockMode == .editing {
                                            Image(systemName: "pencil")
                                                .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.5)))
                                        } else if stockMode == .deleting {
                                            Image(systemName: "trash.fill")
                                                .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.5)))
                                                .scaleEffect(pendingDelete ? 1.2 : 1)
                                        } else {
                                            Image(systemName: screenMode == .stocks ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                                .transition(AnyTransition.opacity.combined(with: .scale(scale: 0.5)))
                                                .scaleEffect(screenMode == .stocks ? 1.2 : 1)
                                                .animation(.spring())
                                        }
                                    }.font(.body).foregroundColor(Color("object"))
                                    .animation(.spring())
                                )
                                .cornerRadius(15)
                                .padding(1.5)
                        }.frame(height: UIScreen.screenHeight * (screenMode == .stocks ? 0.08 : 0.045))
                    }.buttonStyle(ShrinkingButton())
                    .onChange(of: pendingDelete, perform: { _ in
                        withAnimation(.spring()){
                            if pendingDelete == true {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    pendingDelete = false // turns off delete button after 2 secs
                                }
                            }
                        }
                    })
                }.padding()
            )
    }
}

struct StockView: View {
    /// Fetches Receipt entities in CoreData sorting by the NSSortDescriptor.
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Stock.title, ascending: true)], animation: .spring())
    /// Stores the fetched results as an array of Receipt objects.
    var stocks: FetchedResults<Stock>
    @Binding var stockMode : StockMode
    @Binding var screenMode : ScreenMode
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if stocks.count > 0 {
                        ForEach(stocks) { stock in
                            StockCard(stock: stock, stockMode: $stockMode, screenMode: $screenMode)
                                .frame(width: UIScreen.screenWidth * (screenMode == .stocks ? 0.9 : 0.4), height: UIScreen.screenHeight * (screenMode == .stocks ? 0.8 : 0.37))
                        }
                    } else {
                        NoStocksCard()
                    }
                }.padding(.horizontal).padding(.top, screenMode == .stats ? 50 : 0).animation(.spring())
            }
            if stocks.count <= 0 {
                HStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("No stocks\nadded.")
                        .font(.system(.title, design: .rounded))
                        .foregroundColor(Color("object"))
                        .padding()
                    Spacer()
                }
            }
        }
    }
}
 
struct CategoryView: View {
    let categories = Category.categories
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<categories.count) { category in
                    CategoryCard(category: categories[category])
                }
            }.padding(.horizontal)
        }
    }
}

struct ActionView: View {
    @Binding var stockMode : StockMode
    @State var addingStock = false
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(action:{
                    addingStock.toggle()
                }){
                    RoundedRectangle(cornerRadius: 50)
                        .frame(width: UIScreen.screenWidth * 0.35, height: UIScreen.screenHeight * 0.048)
                        .foregroundColor(Color("object"))
                        .overlay(
                            HStack{
                                Text("Add Stock").font(.system(.body, design: .rounded))
                                Spacer()
                                Image(systemName: "cursorarrow.rays")
                            }.padding(12)
                        )
                }.buttonStyle(ShrinkingButton())
                .sheet(isPresented: $addingStock) {
                    AddStock(displaying: $addingStock)
                }
                
                Button(action:{
                    stockMode = stockMode == .editing ? .expanding : .editing
                }){
                    RoundedRectangle(cornerRadius: 50)
                        .frame(width: UIScreen.screenWidth * 0.35, height: UIScreen.screenHeight * 0.048)
                        .foregroundColor(Color(stockMode == .editing ? "yellow" : "object"))
                        .overlay(
                            HStack{
                                Text("Edit Stock").font(.system(.body, design: .rounded))
                                Image(systemName: "slider.horizontal.3")
                            }.padding(12)
                        )
                }.buttonStyle(ShrinkingButton())
                
                Button(action:{
                    stockMode = stockMode == .deleting ? .expanding : .deleting
                }){
                    RoundedRectangle(cornerRadius: 50)
                        .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenHeight * 0.048)
                        .foregroundColor(Color(stockMode == .deleting ? "red" : "object"))
                        .overlay(
                            HStack{
                                Text("Delete Stock").font(.system(.body, design: .rounded))
                                Image(systemName: "trash.fill")
                            }.padding(12)
                        )
                }.buttonStyle(ShrinkingButton())
            }.padding(.horizontal)
        }
    }
}

struct AddStock: View {
    @Binding var displaying : Bool
    @State var title : String = ""
    @State var symbol : String = ""
    @State var shares : String = ""
    @State var input : String = ""
    @State var usd : Bool = true
    @State var category : String = ""
    
    var body: some View {
        VStack (alignment: .leading){
            Text("New Stock.")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(Color("text"))
                .padding(.horizontal, 5).padding(.top, 20)
            
            CustomTextField(placeholder: "Title", text: $title)
                .font(.system(.title, design: .rounded))
                .foregroundColor(Color("accentAlt"))
                .padding()
                .background(Color("object")).cornerRadius(25)
            
            CustomTextField(placeholder: "Symbol", text: $symbol)
                .font(.system(.title, design: .rounded))
                .foregroundColor(Color("accentAlt"))
                .padding()
                .background(Color("object")).cornerRadius(25)
            
            HStack {
                CustomTextField(placeholder: "Shares", text: $shares)
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(Color("accentAlt"))
                    .padding()
                    .background(Color("object")).cornerRadius(25)
                
                CustomTextField(placeholder: "Input", text: $input)
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(Color("accentAlt"))
                    .padding()
                    .background(Color("object")).cornerRadius(25)
            }
            
            CustomTextField(placeholder: "Category", text: $category)
                .font(.system(.title, design: .rounded))
                .foregroundColor(Color("accentAlt"))
                .padding()
                .background(Color("object")).cornerRadius(25)
            
            Toggle(usd ? "US Market" : "NZ Market", isOn: $usd)
                .font(.system(.title, design: .rounded))
                .foregroundColor(Color("accentAlt"))
                .padding()
                .background(Color("object")).cornerRadius(25)
            
            Text("Bought \(shares.isEmpty ? "0" : shares) shares of \(symbol.isEmpty ? "nothing" : symbol), for $\(input.isEmpty ? "0" : input).")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(Color("accent"))
                .padding(.horizontal, 5)
            
            Spacer()
            HStack{
                Button(action: {
                    displaying = false
                }){
                    RoundedRectangle(cornerRadius: 25.0)
                        .overlay(
                            Image(systemName: "xmark")
                                .foregroundColor(Color("red"))
                        )
                }
                
                Button(action: {
                    Stock.addStock(title: title, symbol: symbol, input: (input as NSString).doubleValue, shares: (shares as NSString).doubleValue, category: category)
                    displaying = false
                }){
                    RoundedRectangle(cornerRadius: 25.0)
                        .overlay(
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("green"))
                            
                        )
                }
            }.font(.title)
            .frame(height: UIScreen.screenHeight * 0.08)
            .foregroundColor(Color("object"))
            
            
        }.padding()
    }
}

struct NoStocksCard: View {
    @State var addingStock = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .foregroundColor(Color("object"))
            .overlay(
                VStack(alignment: .leading){
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Image(systemName: Category.icon(symbol: "tech"))
                            .font(.system(.footnote))
                            .foregroundColor(Color(Category.color(symbol: "tech")))
                        
                        Image(systemName: Category.icon(symbol: "clean"))
                            .font(.system(.footnote))
                            .foregroundColor(Color(Category.color(symbol: "clean")))
                        
                        Image(systemName: Category.icon(symbol: "power"))
                            .font(.system(.footnote))
                            .foregroundColor(Color(Category.color(symbol: "power")))
                    }.padding(.bottom, 1)
                    
                    Text("Add")
                        .font(.system(.title, design: .rounded))
                        .lineLimit(2).minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color("text"))
                    Text("a stock.")
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color("accentAlt"))
                    Divider()
                    
                    Spacer()
                    Button(action:{
                        addingStock.toggle()
                    }){
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(Color("accent"))
                            .overlay(Image(systemName: "cursorarrow.rays").font(.title).foregroundColor(Color("text")))
                            .frame(height: UIScreen.screenHeight * 0.1)
                            .cornerRadius(15)
                    }.buttonStyle(ShrinkingButton())
                    .sheet(isPresented: $addingStock) {
                        AddStock(displaying: $addingStock)
                    }
                }.padding()
            )
            .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenHeight * 0.37)
    }
}
