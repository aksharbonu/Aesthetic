//
//  RLMClothingItem.h
//  Aesthetic
//
//  Created by Akshar Bonu on 11/4/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import <Realm/Realm.h>
#import <Parse/Parse.h>
#import "RLMUser.h"
#import "RLMClothingTag.h"

@class RLMUser;
@protocol RLMUser;

@interface RLMClothingItem : RLMObject

+ (RLMClothingItem *) createRLMClothingItemFromPFClothingItem: (PFObject*) ParseClothingItem;

// Parse Managed
@property NSString* objectId;
@property NSDate* createdAt;
@property NSDate* updatedAt;

// Clothing Item Information
@property NSString* name;
@property BOOL active;
@property NSData* image;
@property RLMArray<RLMClothingTag>* tags;
@property NSInteger rightSwipes;
@property NSInteger leftSwipes;
@property float price;
@property RLMUser* soldBy;

// Extra Information
@property RLMArray<RLMUser> *hasSwiped;

// Independent from Parse
@property BOOL pushed;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<RLMClothingItem>
RLM_ARRAY_TYPE(RLMClothingItem)
