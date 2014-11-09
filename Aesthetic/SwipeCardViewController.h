//
//  SwipeCardViewController.h
//  Aesthetic
//
//  Created by Akshar Bonu on 10/26/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import <Parse/Parse.h>
#import "ClothingItemView.h"

#import <Realm/Realm.h>
#import "RLMClothingTag.h"
#import "RLMUser.h"
#import "RLMClothingItem.h"

@interface SwipeCardViewController : UIViewController <MDCSwipeToChooseDelegate>

@property (nonatomic, strong) NSMutableArray *clothingItemNotDisplayed;
@property (nonatomic, strong) PFObject *currentClothingItem;
@property (nonatomic, strong) ClothingItemView *frontCardView;
@property (nonatomic, strong) ClothingItemView *backCardView;
@property (nonatomic, strong) RLMRealm* realm;
@property (nonatomic, strong) UIButton* likeButton;
@property (nonatomic, strong) UIButton* dislikeButton;


@end
