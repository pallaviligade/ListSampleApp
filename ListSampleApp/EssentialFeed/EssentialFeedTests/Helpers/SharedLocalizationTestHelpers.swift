//
//  SharedLocalizationTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 15.10.23.
//

import XCTest

public func assertLocalizedKeyAndValuesExist(in presentationBundles: Bundle, _ table: String) {
    let allLocalizesBundles  = allLocalizationBundles(in: presentationBundles)
    let locatizationStringKeys = allLocalizedStringKeys(in: allLocalizesBundles, table: table)
    
    allLocalizesBundles.forEach { (bundles, localization) in
        locatizationStringKeys.forEach { key in
            let lanuage = Locale.current.localizedString(forLanguageCode: localization) ?? ""
            let locatizationString = bundles.localizedString(forKey: key, value: nil, table: table)
            
            if locatizationString == key || locatizationString.isEmpty {
                XCTFail("Missing '\(lanuage)' '\(localization)' localized string for key '\(key)' in table '\(table)' ")
            }
        }
    }
}
    
    private typealias LocalizedBundle = (bundle:  Bundle, localization: String)
    
    private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #file, line: UInt = #line) -> [LocalizedBundle] {
        
        return bundle.localizations.compactMap { localization in
                    guard
                        let path = bundle.path(forResource: localization, ofType: "lproj"),
                        let localizedBundle = Bundle(path: path)
                    else {
                        XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
                        return nil
                    }

                    return (localizedBundle, localization)
                }
        
    }
    
    private func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
            return bundles.reduce([]) { (acc, current) in
                guard
                    let path = current.bundle.path(forResource: table, ofType: "strings"),
                    let strings = NSDictionary(contentsOfFile: path),
                    let keys = strings.allKeys as? [String]
                else {
                    XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line: line)
                    return acc
                }

                return acc.union(Set(keys))
            }
        }
    
