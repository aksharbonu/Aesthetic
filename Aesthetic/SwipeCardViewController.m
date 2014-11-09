//
//  SwipeCardViewController.m
//  Aesthetic
//
//  Created by Akshar Bonu on 10/26/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import "SwipeCardViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SwipeCardViewController.h"



/*
 
    KNOWN BUGS: 
    - changing .pushed when it is not necessarily true (temp fix)
    - not asychronous (will benefit from pulling data in background)
 
    TODO (short term):

    - error
    - user data saving more robust
    - cancel swipe
 
    TODO (long term)
    - improved algorithm for fetching
    - frame size
*/

static const CGFloat ChooseClothingButtonHorizontalPadding = 80.f;
static const CGFloat ChooseClothingButtonVerticalPadding = 20.f;


@implementation SwipeCardViewController

- (void) viewDidLoad
{
    self.realm = [RLMRealm defaultRealm];
    NSLog(@"%@", self.realm.path);
    
    [self sanitize];
    [self constructNopeButton];
    [self constructLikedButton];
    
    [self hideButtons];
    [self disableButtons];
    
    BOOL success = [self _getNewClothingItems];
    
    if (success)
    {
        [self _updateCards];
        [self enableButtons];
        [self revealButtons];
    }
    
    [self _loadData];
}

// Create and add the "nope" button.
- (void)constructNopeButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"nope"];
    button.frame = CGRectMake(ChooseClothingButtonHorizontalPadding,
                              CGRectGetMaxY(self.view.frame) - 100 + ChooseClothingButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:247.f/255.f
                                         green:91.f/255.f
                                          blue:37.f/255.f
                                         alpha:1.f]];
    [button addTarget:self
               action:@selector(nopeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    self.dislikeButton = button;
    
    [self.view addSubview:button];
}

// Create and add the "like" button.
- (void)constructLikedButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"liked"];
    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChooseClothingButtonHorizontalPadding,
                              CGRectGetMaxY(self.view.frame) - 100 + ChooseClothingButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:29.f/255.f
                                         green:245.f/255.f
                                          blue:106.f/255.f
                                         alpha:1.f]];
    [button addTarget:self
               action:@selector(likeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    self.likeButton = button;
    
    [self.view addSubview:button];
}

- (void) disableButtons
{
    self.dislikeButton.enabled = NO;
    self.likeButton.enabled = NO;
}

- (void) enableButtons
{
    self.dislikeButton.enabled = YES;
    self.likeButton.enabled = YES;
}

- (void) hideButtons
{
    self.dislikeButton.hidden = YES;
    self.likeButton.hidden = YES;
}

- (void) revealButtons
{
    self.dislikeButton.hidden = NO;
    self.likeButton.hidden = NO;
}

// Programmatically "nopes" the front card view.
// Async
- (void)nopeFrontCardView {
    if (self.frontCardView)
    {
        [self disableButtons];
        [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
    }
}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView {
    [self disableButtons];
    if (!self.backCardView)
    {
        [self hideButtons];
    }
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}

- (void) setFrontCardView:(ClothingItemView *)frontCardView
{
    _frontCardView = frontCardView;
    if (!self.backCardView)
    {
        [self hideButtons];
    }
    self.currentClothingItem = frontCardView.clothingItem;
}

- (void ) _updateCards
{
    if (!self.frontCardView)
    {
        self.frontCardView = [self popClothingItemViewWithFrame: [self frontCardViewFrame]];
        [self.view addSubview: self.frontCardView];
    }
    if (!self.backCardView)
    {
        self.backCardView = [self popClothingItemViewWithFrame: [self backCardViewFrame]];
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
    }
}

- (BOOL) _getNewClothingItems
{
    
    [self syncParseAndRealm];
    PFQuery *query = [PFQuery queryWithClassName:@"ClothingItem"];
    if (self.frontCardView)
    {
        [query whereKey:@"objectId" notEqualTo: self.frontCardView.clothingItem.objectId];
    }
    [query whereKey: @"hasSwiped" notEqualTo:[PFUser currentUser]];
    query.limit = 10;
    // CORNER CASES: error, no objects, aysnc
    
    self.clothingItemNotDisplayed = [NSMutableArray arrayWithArray: [query findObjects]];

    if (self.clothingItemNotDisplayed.count)
    {
        return true;
    }
    else
    {
        return false;
    }
    /*
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && [objects count])
        {
            self.clothingItemNotDisplayed = [NSMutableArray arrayWithArray:objects];
            [self _updateCards];
        }
        else
        {
            // TODO: handle error
        }
    }];
     */
}

- (IBAction)logoutButtonPressed:(UIBarButtonItem *)sender
{
    [self logoutButtonAction: sender];
}

- (void)logoutButtonAction:(id)sender {
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // return to LoginViewController
    [self performSegueWithIdentifier:@"logoutToLoginScreen" sender:self];
}

- (ClothingItemView *) popClothingItemViewWithFrame:(CGRect)frame {
    if ([self.clothingItemNotDisplayed count] == 0) {
        return nil;
    }
    
    // UIView+MDCSwipeToChoose and ClothingItemView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 80.f;
    options.likedText = @"Like";
    options.nopeText = @"Dislike";
    options.likedColor = [UIColor blueColor];
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y - (state.thresholdRatio * 10.f),
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };
    
    ClothingItemView* view = [[ClothingItemView alloc] initWithFrame:frame clothingItem:self.clothingItemNotDisplayed[0] options:options];
    [self.clothingItemNotDisplayed removeObjectAtIndex: 0];
    
    return view;
}


- (void)viewDidCancelSwipe:(UIView *)view {
    // TODO: This is called when a user didn't fully swipe left or right.
    // Reflects indecision
}


// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    
    RLMResults *users = [RLMUser objectsWhere:@"objectId = %@", [PFUser currentUser].objectId];
    RLMUser* user;
    if (users.count == 0)
    {
        user = [RLMUser createRLMUserFromPFUser: [PFUser currentUser]];
    }
    else
    {
        user = [users firstObject];
    }
    
    if (!self.currentClothingItem)
    {
        return;
    }
    
    RLMClothingItem* item = [RLMClothingItem createRLMClothingItemFromPFClothingItem: self.currentClothingItem];
    
    [self.realm beginWriteTransaction];
    [item.hasSwiped addObject: user];
    (direction == MDCSwipeDirectionLeft) ? item.leftSwipes++ : item.rightSwipes++;
    [(direction == MDCSwipeDirectionLeft) ? user.trash : user.wardrobe addObject: item];
    [self.realm commitWriteTransaction];
    
    self.frontCardView = self.backCardView;
    
    if (!self.frontCardView)
    {

        BOOL success = [self _getNewClothingItems];
        
        if (success)
        {
            [self _updateCards];
            [self enableButtons];
            [self revealButtons];
        }
    }
    else
    {
        
        if ((self.backCardView = [self popClothingItemViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
        }
        [self enableButtons];
    }
}

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 60.f * 1.5;
    CGFloat bottomPadding = 200.f;
    return CGRectMake(horizontalPadding,
                      topPadding,
                      CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      CGRectGetHeight(self.view.frame) - bottomPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 10.f,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

#pragma mark - Facebook

- (void)_loadData {
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            NSString *name = userData[@"name"];
            if (name) {
                userProfile[@"name"] = name;
            }
            
            NSString *location = userData[@"location"][@"name"];
            if (location) {
                userProfile[@"location"] = location;
            }
            
            NSString *gender = userData[@"gender"];
            if (gender) {
                userProfile[@"gender"] = gender;
            }
            
            NSString *birthday = userData[@"birthday"];
            if (birthday) {
                userProfile[@"birthday"] = birthday;
            }
            
            NSString *relationshipStatus = userData[@"relationship_status"];
            if (relationshipStatus) {
                userProfile[@"relationship"] = relationshipStatus;
            }
            
            userProfile[@"pictureURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) {
            // Since the request failed, we can check if it was due to an invalid session
            [self logoutButtonAction:nil];
        } else {
            // TODO: handle other errors
        }
    }];
}

- (BOOL) syncParseAndRealm
{
    RLMResults *users = [RLMUser objectsWhere:@"objectId = %@", [PFUser currentUser].objectId];
    RLMUser* user;
    if (users.count == 0)
    {
        user = [RLMUser createRLMUserFromPFUser: [PFUser currentUser]];
        return true;
    }
    else
    {
        user = [users firstObject];
    }
    
    RLMArray* wardrobe = user.wardrobe;
    RLMArray* trash = user.trash;
    
    NSMutableArray* toUpdate = [NSMutableArray arrayWithArray: @[[PFUser currentUser]]];
    [self.realm beginWriteTransaction];
    for (RLMClothingItem* clothingItem in wardrobe) {
        if (!clothingItem.pushed)
        {
            PFQuery *query = [PFQuery queryWithClassName:@"ClothingItem"];
            [query whereKey:@"objectId" equalTo:clothingItem.objectId];
            PFObject* parseClothingItem = [query getFirstObject];
            PFRelation *relation = [parseClothingItem relationForKey:@"hasSwiped"];
            [relation addObject: [PFUser currentUser]];
            [parseClothingItem incrementKey: @"rightSwipes"];
            
            PFRelation* bucket = [[PFUser currentUser] relationForKey: @"wardrobe"];
            [bucket addObject: parseClothingItem];
            [toUpdate addObject: parseClothingItem];
            
            clothingItem.pushed = true;
        }
    }
    
    for (RLMClothingItem* clothingItem in trash) {
        if (!clothingItem.pushed)
        {
            PFQuery *query = [PFQuery queryWithClassName:@"ClothingItem"];
            [query whereKey:@"objectId" equalTo:clothingItem.objectId];
            PFObject* parseClothingItem = [query getFirstObject];
            PFRelation *relation = [parseClothingItem relationForKey:@"hasSwiped"];
            [relation addObject: [PFUser currentUser]];
            [parseClothingItem incrementKey: @"leftSwipes"];
            
            PFRelation* bucket = [[PFUser currentUser] relationForKey: @"trash"];
            [bucket addObject: parseClothingItem];
            [toUpdate addObject: parseClothingItem];
            
            clothingItem.pushed = true;
        }
    }
    [self.realm commitWriteTransaction];
    
    return [PFObject saveAll: toUpdate];
}

// CODE FOR DEVELOPMENT. DELETES ALL DATA.

- (void) sanitize
{
    [self.realm beginWriteTransaction];
    [self.realm deleteAllObjects];
    [self.realm commitWriteTransaction];
    
    PFQuery *query = [PFQuery queryWithClassName:@"ClothingItem"];
    NSArray* clothingItems = [query findObjects];
    for (PFObject* item in clothingItems) {
        [item setObject:[NSNumber numberWithInteger:0] forKey:@"leftSwipes"];
        [item setObject:[NSNumber numberWithInteger:0] forKey:@"rightSwipes"];
        PFRelation *relation = [item relationForKey:@"hasSwiped"];
        [relation removeObject: [PFUser currentUser]];
    }
    
    PFRelation* trash = [[PFUser currentUser] relationForKey: @"trash"];
    PFRelation* wardrobe = [[PFUser currentUser] relationForKey: @"wardrobe"];
    
    for (PFObject* item in [[trash query] findObjects]) {
        [trash removeObject: item];
    }
    
    for (PFObject* item in [[wardrobe query] findObjects]) {
        [wardrobe removeObject:item];
    }
    
    [[PFUser currentUser] save];
    [PFObject saveAll: clothingItems];
}

@end
