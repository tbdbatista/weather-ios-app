//
//  WeatherViewController.swift
//  Weather-iOS123
//
//  Created by Beltrami Dias Batista, Thiago on 07/03/22.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
   
    //MARK: - Outlets
    @IBOutlet weak var imageWeatherCondition: UIImageView!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var textFieldSearch: UITextField!
    
    //MARK: - Variables
    var searchTimer: Timer?
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    //var delegate = WeatherManagerDelegate.self
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherManager.delegate = self
        textFieldSearch.delegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }
    
    //MARK: - Navigation
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        
      _ = textFieldShouldReturn(textFieldSearch)
        
    }
    @IBAction func didTapCurrentLocationButton(_ sender: UIButton) {
        
        locationManager.requestLocation()
        textFieldSearch.text = ""
        
    }
    
    @IBAction func didBeginEdit(_ sender: UITextField) {
        
        updateSearchResults(for: sender.text ?? "")
        
    }
    
    func updateSearchResults(for searchText: String) {
     
        self.searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] (timer) in
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                
                self?.weatherManager.fetchWeather(cityName: searchText)
                
            }
        })
    }
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textFieldSearch.text!)
        textFieldSearch.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textFieldSearch.text != "" {
            return true
        } else {
            textFieldSearch.placeholder = "You must enter a city name"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = textFieldSearch.text {
            
            weatherManager.fetchWeather(cityName: city)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldSearch.clearsOnBeginEditing = true
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    
    func didUpdateWeather(weather: WeatherModel) {
        
        DispatchQueue.main.async { [self] in
            labelCity.text = weather.cityName
            labelTemperature.text = weather.temperatureString
            imageWeatherCondition.image = UIImage(systemName: weather.conditionName)
            
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
        DispatchQueue.main.async { [self] in
            labelCity.text = "City not found, verify city name or check your internet connection"
            labelTemperature.text = "-"
            imageWeatherCondition.image = UIImage(systemName: "")
            
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//API key d00a54025688dbbb4f530d96b1045280
