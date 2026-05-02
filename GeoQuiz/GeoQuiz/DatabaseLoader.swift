//
//  DatabaseLoader.swift
//  GeoQuiz
//
//  Created by Jan on 01/05/2026.
//

import Foundation
import CoreData

class DatabaseLoader {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func loadToDatabase() {
        let europeCountries = loadFromFile(from: "EuropeCountriesList")
        let asiaCountries = loadFromFile(from: "AsiaCountriesList")
        let africaCountries = loadFromFile(from: "AfricaCountriesList")
        let oceaniaCountries = loadFromFile(from: "OceaniaCountriesList")
        let northAmericaCountries = loadFromFile(from: "NorthAmericaCountriesList")
        let southAmericaCountries = loadFromFile(from: "SouthAmericaCountriesList")
        let europeCapitals = loadFromFile(from: "EuropeCapitals")
        let asiaCapitals = loadFromFile(from: "AsiaCapitals")
        let africaCapitals = loadFromFile(from: "AfricaCapitals")
        let oceaniaCapitals = loadFromFile(from: "OceaniaCapitals")
        let northAmericaCapitals = loadFromFile(from: "NorthAmericaCapitals")
        let southAmericaCapitals = loadFromFile(from: "SouthAmericaCapitals")
        let europeFlags = flagsForCountries(countries: europeCountries)
        let asiaFlags = flagsForCountries(countries: asiaCountries)
        let africaFlags = flagsForCountries(countries: africaCountries)
        let oceaniaFlags = flagsForCountries(countries: oceaniaCountries)
        let northAmericaFlags = flagsForCountries(countries: northAmericaCountries)
        let southAmericaFlags = flagsForCountries(countries: southAmericaCountries)
        createContinents()
        createCountries(names: europeCountries, capitals: europeCapitals, flags: europeFlags, continent: "Europe")
        createCountries(names: asiaCountries, capitals: asiaCapitals, flags: asiaFlags, continent: "Asia")
        createCountries(names: africaCountries, capitals: africaCapitals, flags: africaFlags, continent: "Africa")
        createCountries(names: oceaniaCountries, capitals: oceaniaCapitals, flags: oceaniaFlags, continent: "Oceania")
        createCountries(names: northAmericaCountries, capitals: northAmericaCapitals, flags: northAmericaFlags, continent: "North America")
        createCountries(names: southAmericaCountries, capitals: southAmericaCapitals, flags: southAmericaFlags, continent: "South America")
        createCategories()
        createLevel(for: "Europe", type: "Flags")
        createLevel(for: "Europe", type: "Capitals")
        createLevel(for: "Asia", type: "Flags")
        createLevel(for: "Asia", type: "Capitals")
        createLevel(for: "Africa", type: "Flags")
        createLevel(for: "Africa", type: "Capitals")
        createLevel(for: "Oceania", type: "Flags")
        createLevel(for: "Oceania", type: "Capitals")
        createLevel(for: "North America", type: "Flags")
        createLevel(for: "North America", type: "Capitals")
        createLevel(for: "South America", type: "Flags")
        createLevel(for: "South America", type: "Capitals")
    }
    
    private func loadFromFile(from fileName: String) -> [String] {
        if let file = Bundle.main.url(forResource: fileName, withExtension: "txt") {
            if let content = try? String(contentsOf: file, encoding: .utf8) {
                let results = content.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
                return results
            }
            return []
        }
        return []
    }
    
    private func flagsForCountries(countries: [String]) -> [String] {
        var flags: [String] = []
        for country in countries {
            let flagName = country.lowercased().replacingOccurrences(of: " ", with: "_")
            flags.append(flagName)
        }
        return flags
    }
    
    private func createContinents() {
        let europe = Continent(context: context)
        europe.continentName = "Europe"
        
        let asia = Continent(context: context)
        asia.continentName = "Asia"
        
        let africa = Continent(context: context)
        africa.continentName = "Africa"
        
        let oceania = Continent(context: context)
        oceania.continentName = "Oceania"
        
        let northAmerica = Continent(context: context)
        northAmerica.continentName = "North America"
        
        let southAmerica = Continent(context: context)
        southAmerica.continentName = "South America"
        
        do {
            try context.save()
        }
        catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func createCountries(names: [String], capitals: [String], flags: [String], continent: String) {
        if names.count == capitals.count, names.count == flags.count {
            for index in 0..<names.count {
                //print("\(names[index]) \(capitals[index]) \(flags[index])\n")
                let country = Country(context: context)
                country.countryName = names[index]
                
                let capital = Capital(context: context)
                capital.capitalName = capitals[index]
                capital.numberOfGuess = 0
                capital.numberOfCorrect = 0
                
                let flag = Flag(context: context)
                flag.flagFileName = flags[index]
                flag.numberOfGuess = 0
                flag.numberOfCorrect = 0
                
                country.flag = flag
                country.capital = capital

                let continentRequest = Continent.fetchRequest()
                let predicate = NSPredicate(format: "continentName == %@", continent)
                continentRequest.predicate = predicate
                let fetchedContinents = try? context.fetch(continentRequest)
                country.continent = fetchedContinents?.first
                
                do {
                    try context.save()
                }
                catch {
                    print("Failed to save context: \(error)")
                }
            }
        }
        else {
            print("Arrays sizes not equal")
        }
    }
    
    private func createCategories() {
        let flags = Category(context: context)
        flags.categoryName = "Flags"
        
        let capitals = Category(context: context)
        capitals.categoryName = "Capitals"
        
        do {
            try context.save()
        }
        catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func createLevel(for continent: String, type category: String) {
        let level = Level(context: context)
        level.levelDescription = "Guess the \(category.lowercased()) of countries in \(continent)"
        
        let continentRequest = Continent.fetchRequest()
        let predicateContinent = NSPredicate(format: "continentName == %@", continent)
        continentRequest.predicate = predicateContinent
        let fetchedContinents = try? context.fetch(continentRequest)
        level.continent = fetchedContinents?.first
        
        let categoryRequest = Category.fetchRequest()
        let predicateCategory = NSPredicate(format: "categoryName == %@", category)
        categoryRequest.predicate = predicateCategory
        let fetchedCategories = try? context.fetch(categoryRequest)
        level.category = fetchedCategories?.first
        
        do {
            try context.save()
        }
        catch {
            print("Failed to save context: \(error)")
        }
    }
}
