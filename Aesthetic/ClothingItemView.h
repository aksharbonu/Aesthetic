//
//  ClothingItemView.h
//  Aesthetic
//
//  Created by Akshar Bonu on 10/28/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import "MDCSwipeToChooseView.h"
#import <Parse/Parse.h>

@interface ClothingItemView : MDCSwipeToChooseView

@property (nonatomic, strong) PFObject *clothingItem;

- (instancetype)initWithFrame:(CGRect)frame clothingItem:(PFObject *) clothingItem options:(MDCSwipeToChooseViewOptions *)options;

@end
