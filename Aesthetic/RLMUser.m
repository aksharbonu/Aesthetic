//
//  RLMUser.m
//  Aesthetic
//
//  Created by Akshar Bonu on 11/4/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import "RLMUser.h"

@implementation RLMUser

+ (RLMUser *) createRLMUserFromPFUser: (PFUser*) ParseUser
{
    RLMUser * user = [[RLMUser alloc] init];
    user.objectId = ParseUser.objectId;
    user.username = ParseUser.username;
    user.createdAt = ParseUser.createdAt;
    user.updatedAt = ParseUser.updatedAt;
    user.profile = [NSKeyedArchiver archivedDataWithRootObject:[ParseUser objectForKey: @"profile"]];
    
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject: user];
    [realm commitWriteTransaction];
    
    PFRelation* trash = [[PFUser currentUser] relationForKey: @"trash"];
    PFRelation* wardrobe = [[PFUser currentUser] relationForKey: @"wardrobe"];
    
    for (PFObject* item in [[trash query] findObjects]) {
        RLMClothingItem* clothingItem = [RLMClothingItem createRLMClothingItemFromPFClothingItem: item];
        
        [realm beginWriteTransaction];
        [user.trash addObject: clothingItem];
        [clothingItem.hasSwiped addObject: user];
        clothingItem.pushed = true;
        [realm commitWriteTransaction];
    }
    
    for (PFObject* item in [[wardrobe query] findObjects]) {
        RLMClothingItem* clothingItem = [RLMClothingItem createRLMClothingItemFromPFClothingItem: item];
        
        [realm beginWriteTransaction];
        [user.trash addObject: clothingItem];
        [clothingItem.hasSwiped addObject: user];
        clothingItem.pushed = true;
        [realm commitWriteTransaction];
    }
    
    return user;
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
