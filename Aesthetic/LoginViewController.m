//
//  LoginViewController.m
//  Aesthetic
//
//  Created by Akshar Bonu on 10/26/14.
//  Copyright (c) 2014 aksharbonu. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SwipeCardViewController.h"

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
       [self _presentSwipeCardViewControllerAnimated:YES];
    }
}

- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            if (!error) {
                // TODO: The user cancelled the Facebook login
            } else {
                // TODO: The user cancelled the Facebook login because of an error (check variable)
            }
            // TODO: action for error. Possible solutions include UIViewAlert
        } else {
            if (user.isNew) {
                // TODO: User with facebook signed up and logged in
            } else {
                // TODO: User with facebook logged in
            }
            [self _presentSwipeCardViewControllerAnimated:YES];
        }
    }];
    
}

- (void)_presentSwipeCardViewControllerAnimated:(BOOL)animated {
    [self performSegueWithIdentifier:@"successfulFacebookLogin" sender:self];
}

- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue
{
    // TODO: logout
}

@end
