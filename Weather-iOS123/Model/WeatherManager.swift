//
//  WeatherManager.swift
//  Weather-iOS123
//
//  Created by Beltrami Dias Batista, Thiago on 09/03/22.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=d00a54025688dbbb4f530d96b1045280"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let formatedCityName = cityName.formatCityName()
        let urlString = "\(weatherURL)&q=\(formatedCityName)"
        self.performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        self.performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        
        //Passo 1 - criar a URL()
        
        if let url = URL(string: urlString){
            
            //Passo 2 - criar uma sessão (semelhante ao que seria o navegador ao comunicar com o API)
            let session = URLSession(configuration: .default)
            
            //Passo 3 - atribuir uma atividade à sessão
            let task = session.dataTask(with: url) { (data, responde, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(weather: weather)
                    }
//                    converte o json em string para visualizar se a chamada está correta
//                    let dataString = String(data: safeData, encoding: .utf8)
//                    print(dataString)
                }
            }
            
            //Passo 4 - iniciar a atividade
            task.resume()
        }
        
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(cityName: name, temperature: temp, conditionId: id)
            
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            
            return nil
        }
        
    }
}

extension String {
    
    func formatCityName() -> String
    {
        let safeCity = self.folding(options: .diacriticInsensitive, locale: .current)
        let safestCity = safeCity.replacingOccurrences(of: " ", with: "+")
        return safestCity
    }
    
}

