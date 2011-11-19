//
//  AuthView.m
//  Sample Geoloqi App
//
//  Created by Aaron Parecki on 2011-09-01.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "AuthView.h"
#import "LQClient.h"

@implementation AuthView

@synthesize emailField, activityIndicator, signUpView, signInView, usernameField, passwordField;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)signIn:(id)sender {
	self.activityIndicator.alpha = 1.0;
	[[LQClient single] signInWithUsername:self.usernameField.text andPassword:self.passwordField.text callback:^(NSDictionary *response, NSError *error){
        if(response) {
            [[NSNotificationCenter defaultCenter] postNotificationName:LQAuthenticationSucceededNotification
                                                                object:nil
                                                              userInfo:nil];
            [[self parentViewController] dismissModalViewControllerAnimated:YES];
        } else {
            // TODO: You might want to handle errors differently
            [[[[UIAlertView alloc] initWithTitle:@"Error!" message:[error.userInfo objectForKey:@"error_description"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] autorelease] show];
        }
	}];
}

- (IBAction)signUp:(id)sender {
	self.activityIndicator.alpha = 1.0;
	[[LQClient single] createNewAccountWithEmail:self.emailField.text callback:^(NSDictionary *response, NSError *error){
        if(response) {
            [[NSNotificationCenter defaultCenter] postNotificationName:LQAuthenticationSucceededNotification
                                                                object:nil
                                                              userInfo:nil];
            [[self parentViewController] dismissModalViewControllerAnimated:YES];
        } else {
            // TODO: You might want to handle errors differently
            [[[[UIAlertView alloc] initWithTitle:@"Error!" message:[error.userInfo objectForKey:@"error_description"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] autorelease] show];
        }
	}];
}

- (IBAction)modeWasChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if([segmentedControl selectedSegmentIndex] == 0) {
        self.signInView.hidden = YES;
        self.signUpView.hidden = NO;
    } else {
        self.signInView.hidden = NO;
        self.signUpView.hidden = YES;
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[emailField release];
    [usernameField release];
    [passwordField release];
    [signInView release];
    [signUpView release];
	[activityIndicator release];
    [super dealloc];
}


@end
