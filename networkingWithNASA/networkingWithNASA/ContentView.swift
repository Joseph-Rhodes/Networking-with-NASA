//
//  ContentView.swift
//  networkingWithNASA
//
//  Created by Joseph Rhodes on 2/24/25.
//

import SwiftUI

struct nasa: Codable{
    var title:String
    var date:String
    var url:String
}

class NasaModel{
    var nasa:nasa?
    var imageURL:URL?
    var refreshDate:Date?
    
    func refresh() async{
        self.nasa = await getNasa()
    }
    
    private func getNasa() async -> nasa?{
        let session = URLSession(configuration: .default)
        
        if let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"){
            let request = URLRequest(url:url)
            
            do{
                let (data,response) = try await session.data(for:request)
                let decoder = JSONDecoder()
                let nasa = try decoder.decode(networkingWithNASA.nasa.self, from: data)
                self.imageURL = URL(string:nasa.url)
                self.refreshDate = Date()
                return nasa
            }catch{
                print(error)
            }
        }
        return nil
    }
}

struct ContentView: View {
    @State var fetchingNasa = false
    @State var dailyNasa: nasa?
    @State var imageURL: URL?
    @State var nasaModel = NasaModel()
    
    func loadComic(){
        fetchingNasa = true
        Task{
            await nasaModel.refresh()
            fetchingNasa = false
        }
    }
    
    var body: some View {
        VStack {
            Text("Today's Nasa Image")
            AsyncImage(url: nasaModel.imageURL){image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            }placeholder: {
                if(fetchingNasa){
                    ProgressView()
                }
            }
            Spacer()
            Button("Get Nasa") {
                loadComic()
            }
            .padding()
            .background(Color(red: 0, green: 0, blue: 0.5))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            
            .disabled(fetchingNasa)
        }.padding()
            .onAppear{
                loadComic()
            }
    }
}

#Preview {
    ContentView()
}
