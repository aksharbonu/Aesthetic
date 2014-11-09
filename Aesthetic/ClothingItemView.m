//
//  ClothingItemView.m
//  Aesthetic
//
//  Created by Akshar Bonu on 10/28/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import "ClothingItemView.h"


@implementation ClothingItemView

- (instancetype)initWithFrame:(CGRect)frame
                clothingItem:(PFObject *)clothingItem
                      options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame options:options];
    if (self) {
        _clothingItem = clothingItem;
        PFFile *image = [clothingItem objectForKey: @"image"];
        NSData *imageData = [image getData];
        self.imageView.image = [UIImage imageWithData: imageData];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.autoresizingMask = self.autoresizingMask;
    }
    return self;
}

@end

