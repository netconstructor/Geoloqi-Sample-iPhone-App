//
//  AuthView.h
//  Sample Geoloqi App
//
//  Created by Aaron Parecki on 2011-09-01.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AuthView : UIViewController {

}

@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIView *signInView;
@property (nonatomic, retain) IBOutlet UIView *signUpView;

- (IBAction)signIn:(id)sender;
- (IBAction)signUp:(id)sender;
- (IBAction)modeWasChanged:(id)sender;

@end
