//
//  RLMUser.h
//  Aesthetic
//
//  Created by Akshar Bonu on 11/4/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import <Realm/Realm.h>
#import "RLMClothingItem.h"
#import <Parse/Parse.h>

@class RLMClothingItem;
@protocol RLMClothingItem;

@interface RLMUser : RLMObject


+ (RLMUser *) createRLMUserFromPFUser: (PFUser*) ParseUser;

// Parse Managed
@property NSString* objectId; // Parse objectId
@property NSString* username; // Parse username
@property NSDate* createdAt;
@property NSDate* updatedAt;

// User Information
@property NSData* profile; // Facebook
@property RLMArray<RLMClothingItem> *wardrobe;
@property RLMArray<RLMClothingItem> *trash;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<RLMUser>
RLM_ARRAY_TYPE(RLMUser)
