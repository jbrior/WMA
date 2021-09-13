//
//  MealItems+CoreDataProperties.swift
//  WMA
//
//  Created by Jesse Brior on 9/13/21.
//
//

import Foundation
import CoreData


extension MealItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MealItems> {
        return NSFetchRequest<MealItems>(entityName: "MealItems")
    }

    @NSManaged public var food: String?
    @NSManaged public var dateAdded: Date?

}

extension MealItems : Identifiable {

}
