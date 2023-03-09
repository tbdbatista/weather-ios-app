//
//  WeatherData.swift
//  Weather-iOS123
//
//  Created by Beltrami Dias Batista, Thiago on 14/03/22.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
    
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}
