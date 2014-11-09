//
//  WardrobeViewController.m
//  Aesthetic
//
//  Created by Akshar Bonu on 10/29/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import "WardrobeViewController.h"
#import <Parse/Parse.h>
#import "ClothingItemCell.h"

static NSString *kCellIdentifier = @"Cell Identifier";

@implementation WardrobeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    PFRelation* wardrobeRelation = [[PFUser currentUser] relationForKey: @"wardrobe"];
    PFQuery* wardrobeQuery = [wardrobeRelation query];
    [wardrobeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects.count)
        {
            self.wardrobe = [NSMutableArray arrayWithArray: objects];
            [self.collectionView reloadData];
            [self.collectionView layoutIfNeeded];
        }
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.wardrobe.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ClothingItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ClothingItem" forIndexPath:indexPath];
    PFFile *image = [(PFObject *)self.wardrobe[indexPath.row] objectForKey: @"image"];
    NSData *imageData = [image getData];
    cell.imageView.image = [UIImage imageWithData: imageData];
    return cell;
}

@end
