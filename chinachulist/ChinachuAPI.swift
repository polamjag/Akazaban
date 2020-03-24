//
//  ChinachuAPI.swift
//  chinachulist
//
//  Created by Satoru ABE on 2020/03/01.
//  Copyright © 2020 Satoru ABE. All rights reserved.
//

import Foundation
import UIKit

func setChinachuHost(host: String) {
    UserDefaults.standard.set(host, forKey: "chinachuHost")
}

func setChinachuPort(port: Int?) {
    UserDefaults.standard.set(port ?? 10772, forKey: "chinachuPort")
}

func getChinachuHost() -> String {
    let host = UserDefaults.standard.string(forKey: "chinachuHost")
    return host == nil || host == "" ? "raspberrypi.local" : host!
}

func getChinachuPort() -> Int {
    let portNum = UserDefaults.standard.integer(forKey: "chinachuPort")
    return portNum == 0 ? 10772 : portNum
}

func getChinachuUrl(path: String, queryItems: [URLQueryItem]?) -> URL {
    var components = URLComponents()
    components.host = getChinachuHost()
    components.port = getChinachuPort()
    components.scheme = "http"
    components.path = path
    if queryItems != nil {
        components.queryItems = queryItems
    }
    components.user = "akari"
    components.password = "bakuhatsu"
    return components.url!
}

struct Channel: Decodable, Identifiable {
    public var id: String
    public var name: String
    public var programs: [Program]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case programs = "programs"
    }
    
    var currentProgram: Program? {
        return programs.first(where: { $0.isOnLiveNow })
    }
    
    var programsInStartOrder: [Program] {
        return programs.sorted(by: { $0.start < $1.start })
    }
    
    var programsByDate: [(date: String, programs: [Program])] {
        let f = DateFormatter()
        f.dateFormat = "YYYY-MM-dd"
        let dic = Dictionary(grouping: programsInStartOrder, by: { f.string(from: $0.start) })
        return dic.keys.sorted().map({
            return ($0, dic[$0]!)
        })
    }
}

enum ProgramCategory: String, Decodable {
    case news = "news"
    case sports = "sports"
    case information = "information"
    case drama = "drama"
    case music = "music"
    case variety = "variety"
    case cinema = "cinema"
    case anime = "anime"
    case documentary = "documentary"
    case theater = "theater"
    case hobby = "hobby"
    case welfare = "welfare"
    case etc = "etc"
}

struct Program: Decodable, Identifiable {
    public var id: String
    
    public var title: String
    public var fullTitle: String
    public var subTitle: String?
    
    public var start: Date
    public var end: Date
    public var seconds: Int
    
    public var detail: String
    public var flags: [String]
    public var episode: Int?
    public var category: ProgramCategory
        
    enum CodingKeys: String, CodingKey {
        case id = "id"
        
        case title = "title"
        case fullTitle = "fullTitle"
        case subTitle = "subTitle"
        
        case start = "start"
        case end = "end"
        case seconds = "seconds"
        
        case detail = "detail"
        case flags = "flags"
        case episode = "episode"
        case category = "category"
    }
    
    var isOnLiveNow: Bool {
        let now = Date()
        return start <= now && now < end;
    }
}

public class ScheduleFetcher: ObservableObject {
    @Published var channels = [Channel]()
    
    init() {
        load()
    }
    
    func load() {
        let url = getChinachuUrl(path: "/api/schedule.json", queryItems: [])
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let d = data {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let decodedLists = try decoder.decode([Channel].self, from: d)
                    DispatchQueue.main.async {
                        self.channels = decodedLists
                    }
                } else {
                    print("No Data")
                }
            } catch {
                print ("Error")
            }
            
        }.resume()
    }
}

enum ChinachuLogType: String {
    case logTypeWui = "wui"
    case logTypeOperator = "operator"
    case logTypeScheduler = "scheduler"
}

public class LogFetcher: ObservableObject {
    @Published var log: String = ""
    @Published var logType: ChinachuLogType = .logTypeWui

    func get(logType: ChinachuLogType) {
        let url = getChinachuUrl(path: "/api/log/\(logType.rawValue).txt", queryItems: [])
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let d = data {
                    DispatchQueue.main.async {
                        self.log = String(decoding: d, as: UTF8.self)
                    }
                } else {
                    print("No Data")
                }
            }
            
        }.resume()
    }
}

func openStreamingInVLC(channelId: String) {
    var components = URLComponents()
    components.scheme = "vlc-x-callback"
    components.host = "x-callback-url"
    components.path = "/stream"
    components.queryItems = [
        URLQueryItem(name: "url", value:
            getChinachuUrl(path: "/api/channel/\(channelId)/watch.m2ts", queryItems: [
                URLQueryItem(name: "ext", value: "m2ts"),
                URLQueryItem(name: "c:v", value: "copy"),
                URLQueryItem(name: "c:a", value: "copy"),
                URLQueryItem(name: "prefix", value: ""),
            ]).absoluteString
        )
    ]
    UIApplication.shared.open(components.url!)
}
