//
//  RLMClothingTag.h
//  Aesthetic
//
//  Created by Akshar Bonu on 11/4/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import <Realm/Realm.h>

@interface RLMClothingTag : RLMObject
@property NSString* tag;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<RLMClothingTag>
RLM_ARRAY_TYPE(RLMClothingTag)
