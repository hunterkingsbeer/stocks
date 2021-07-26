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
            .environmentObject(UserSettings())
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
    @EnvironmentObject var settings : UserSettings
    @State var stockMode : StockMode = .expanding
    @State var screenMode : ScreenMode = .homepage
    @State var selectedCategory : String = ""
    
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
                .onAppear(perform: {
                    Stock.fetchAllStockData()
                }).onChange(of: selectedCategory, perform: { value in
                    print(value)
                })
            
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
                        StockView(stockMode: $stockMode, screenMode: $screenMode, selectedCategory: $selectedCategory)
                            .transition(AnyTransition.move(edge: .trailing).combined(with: AnyTransition.opacity))
                        

                        // category scrollview
                        CategoryView(selectedCategory: $selectedCategory)
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

struct StockView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Stock.input, ascending: false)],
        animation: .spring())
    var stocks: FetchedResults<Stock>
    @Binding var stockMode : StockMode
    @Binding var screenMode : ScreenMode
    @Binding var selectedCategory: String
    
    var body: some View {
        /*TabView {
            if stocks.count > 0 {
                ForEach(stocks.filter({ selectedCategory == "" ? ($0.category ?? "").count > 0 : $0.category!.localizedCaseInsensitiveContains(selectedCategory)})) { stock in
                    StockCard(stock: stock, stockMode: $stockMode, screenMode: $screenMode)
                        .frame(width: UIScreen.screenWidth * (screenMode == .stocks ? 0.9 : 0.4), height: UIScreen.screenHeight * (screenMode == .stocks ? 0.8 : 0.37))
                }
            } else {
                NoStocksCard()
            }
        }.tabViewStyle(PageTabViewStyle())*/
        
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if stocks.count > 0 {
                    ForEach(stocks.filter({ selectedCategory == "" ? ($0.category ?? "").count > 0 : $0.category!.localizedCaseInsensitiveContains(selectedCategory)})) { stock in
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

struct StockCard: View {
    @ObservedObject var stock : Stock
    @Binding var stockMode : StockMode
    @Binding var screenMode : ScreenMode
    @State var pendingDelete : Bool = false
    
    var body: some View {
        let profit = (stock.shares * stock.price)-stock.input > 0
        
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
                    
                    if screenMode == .stocks {
                        Text("DETAILS")
                    }
                    
                    Spacer()
                    Text("$\(stock.price, specifier: "%.2f")")
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color("accentAlt"))
                    
                    Divider()
                    Text("$\(stock.shares * stock.price, specifier: "%.0f")")
                        .font(.system(.title, design: .rounded)).bold()
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color("text"))
                    Text("\(profit ? "$" : "-$")\(abs((stock.shares * stock.price)-stock.input), specifier: "%.2f")")
                        .font(.system(.body, design: .rounded)).bold()
                        .lineLimit(1).minimumScaleFactor(0.8)
                        .foregroundColor(Color(profit ? "green" : "red"))
                    Text("\(((stock.shares * stock.price - stock.input)/stock.input)*100, specifier: "%.2f")%")
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

struct CategoryView: View {
    let categories = Category.availableCategories()
    @Binding var selectedCategory : String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<categories.count) { category in
                    CategoryCard(category: categories[category], selectedCategory: $selectedCategory)
                }
            }.padding(.horizontal)
        }
    }
}

struct CategoryCard: View {
    let category : Category
    @Binding var selectedCategory : String
    
    var body: some View {
        let subicons = csvToArray(csv: category.subicons)
        Button(action: {
            selectedCategory = isSelected() ? "" : category.symbol
        }){
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(category.color)]), startPoint: .top, endPoint: .bottom))
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(Color(isSelected() ? category.color : "object"))
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
                                    .foregroundColor(Color(isSelected() ? "background" : category.color))
                                
                            }.foregroundColor(Color(isSelected() ? "background" : "accentAlt")).animation(.spring())
                            Text(category.title)
                                .font(.system(.title, design: .rounded))
                                .lineLimit(2).multilineTextAlignment(.leading)
                                .minimumScaleFactor(0.8)
                                .foregroundColor(Color(isSelected() ? "background" : "text")).animation(.spring())
                            Spacer()
                        }.padding()
                    ).padding(1.5)
            }.frame(width: UIScreen.screenWidth * 0.5, height: UIScreen.screenHeight * 0.15)
        }.buttonStyle(ShrinkingButton())
    }
    func isSelected() -> Bool {
        return selectedCategory == category.symbol
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
                    AddStockSheet(displaying: $addingStock)
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
                
                Text("$\(getPortfolioStats()[0], specifier: "%.2f")")
                    .font(.system(size: 50, design: .rounded)).bold()
                    .lineLimit(1).minimumScaleFactor(0.8)
                    .padding(1)
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("RETURN".uppercased())
                            .font(.system(.body, design: .rounded)).bold()
                        Text("$\(getPortfolioStats()[1], specifier: "%.2f")")
                            .font(.system(.largeTitle, design: .rounded)).bold()
                            .lineLimit(1)
                            .foregroundColor(Color("green"))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Percentage".uppercased())
                            .font(.system(.body, design: .rounded)).bold()
                            //.foregroundColor(Color("background"))
                        Text("\(getPortfolioStats()[2], specifier: "%.2f")%")
                            .font(.system(.largeTitle, design: .rounded)).bold()
                            .lineLimit(1)
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
    
    // [0] = sum, [1] = profit/loss, [2] = percentage increase/decrease
    func getPortfolioStats() -> [Double] {
        var sum = 0.0
        var input = 0.0
        for stock in Stock.getStocks() {
            sum += stock.shares * stock.price
            input += stock.input
        }
        
        let profit: Double = sum-input
        let percentage: Double = ((sum-input)/input)*100
        
        return [sum, profit, percentage.isNaN ? 0.0 : percentage]
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
                        AddStockSheet(displaying: $addingStock)
                    }
                }.padding()
            )
            .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenHeight * 0.37)
    }
}

struct AddStockSheet: View {
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
                .padding(.horizontal).padding(.top, 20)
            
            InputField(field: $title, placeholder: "Title")
            
            InputField(field: $symbol, placeholder: "Symbol", capitalized: true)
            
            HStack {
                InputField(field: $shares, placeholder: "Shares", decimalOnly: true, horizontalStack: true)
                
                InputField(field: $input, placeholder: "Input", decimalOnly: true, horizontalStack: true)
            }.padding(.horizontal)
            
            VStack{
                CustomTextField(placeholder: "Category", text: $category)
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(Color("accentAlt"))
                    .padding(.top).padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        let categories = Category.categories
                        ForEach(0..<categories.count) { index in
                            let categoryIn = categories[index]
                            Button(action: {
                                category = category == categoryIn.symbol.capitalized ? "" : categoryIn.symbol.capitalized
                            }){
                                Image(systemName: categoryIn.icon)
                                    .foregroundColor(Color((isCategorySelected(categoryIn: categoryIn.symbol) ? "background" : categoryIn.color)))
                                    .font(.largeTitle)
                                    .frame(width: UIScreen.screenWidth * 0.15,
                                           height: UIScreen.screenWidth * 0.15)
                                    .background(Color(isCategorySelected(categoryIn: categoryIn.symbol) ?  Category.color(symbol: category) : "object")).cornerRadius(15)
                            }
                        }
                    }.padding(.horizontal).padding(.bottom)
                }
            }.background(Color("object")).cornerRadius(25)
            .padding(.horizontal)
            
            //only supporting USX stocks
            /*Toggle(usd ? "US Market" : "NZ Market", isOn: $usd)
                .font(.system(.title, design: .rounded))
                .foregroundColor(Color("accentAlt"))
                .padding()
                .background(Color("object")).cornerRadius(25)
                .padding(.horizontal)*/
            
            Text("Bought \(shares.isEmpty ? "0" : shares) shares of \(symbol.isEmpty ? "nothing" : symbol), for $\(input.isEmpty ? "0" : input).")
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(Color("accent"))
                .padding(.horizontal)
            
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
            .padding(.horizontal)
            
            
        }.padding(.vertical).ignoresSafeArea(.keyboard)
    }
    func isCategorySelected(categoryIn: String) -> Bool {
        return categoryIn.lowercased() == category.lowercased()
    }
}


struct InputField: View {
    @Binding var field: String
    var placeholder: String
    var decimalOnly: Bool = false
    var horizontalStack: Bool = false
    var capitalized: Bool = false
    
    var body: some View {
        CustomTextField(placeholder: placeholder, text: $field)
            .keyboardType(decimalOnly ? .decimalPad : .default)
            .autocapitalization(capitalized ? .allCharacters : .words)
            .font(.system(.title, design: .rounded))
            .foregroundColor(Color("accentAlt"))
            .padding()
            .background(Color("object")).cornerRadius(25)
            .padding(.horizontal, horizontalStack ? 0 : 15)
    }
}
