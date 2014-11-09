//
//  RLMClothingItem.m
//  Aesthetic
//
//  Created by Akshar Bonu on 11/4/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import "RLMClothingItem.h"

// TODO: soldby
// TODO: pushed

@implementation RLMClothingItem

// Assumes not pushed

+ (RLMClothingItem *) createRLMClothingItemFromPFClothingItem: (PFUser*) ParseClothingItem
{
    RLMClothingItem *clothingItem = [[RLMClothingItem alloc] init];
    clothingItem.objectId = ParseClothingItem.objectId;
    clothingItem.createdAt = ParseClothingItem.createdAt;
    clothingItem.updatedAt = ParseClothingItem.updatedAt;
    clothingItem.name = [ParseClothingItem objectForKey: @"name"];
    clothingItem.active = [[ParseClothingItem objectForKey: @"active"] boolValue];
    clothingItem.image = [(PFFile *) [ParseClothingItem objectForKey: @"image"] getData];
    
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    for (NSString* tag in (NSArray *)[ParseClothingItem objectForKey: @"tags"]) {
        RLMClothingTag* clothingTag = [[RLMClothingTag alloc] init];
        clothingTag.tag = tag;
        [realm addObject: clothingTag];
        [clothingItem.tags addObject: clothingTag];
    }
    
    clothingItem.rightSwipes = [[ParseClothingItem objectForKey: @"rightSwipes"] integerValue];
    clothingItem.leftSwipes = [[ParseClothingItem objectForKey: @"leftSwipes"] integerValue];
    clothingItem.price = [[ParseClothingItem objectForKey: @"price"] floatValue];
    clothingItem.soldBy = NULL;
    clothingItem.pushed = false;
    [realm addObject: clothingItem];
    [realm commitWriteTransaction];
    
    return clothingItem;
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
