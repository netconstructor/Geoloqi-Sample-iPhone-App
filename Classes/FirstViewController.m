//
//  FirstViewController.m
//  Sample Geoloqi App
//
//  Created by Aaron Parecki on 2011-11-16.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "FirstViewController.h"
#import "LQClient.h"
#import "SampleAppDelegate.h"
#import "AuthView.h"

@implementation FirstViewController

@synthesize nameLabel;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)reloadPlaceList {
	[[LQClient single] getPlacesWithCallback:^(NSMutableArray *places, NSError *error){
		if(error != nil) {
			NSLog(@"Error retrieving places: %@", error);
		} else {
			NSLog(@"Places callback! %@", places);
			for(LQPlace *place in places) {
				NSLog(@"Found place %@", place.display_name);
			}
            if([places count] == 0)
                NSLog(@"No places found. Why don't you make some!");
		}
	}];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = [[LQClient single] displayName];
    [self reloadPlaceList];
}

- (IBAction)signOut:(id)sender {
    NSLog(@"Sign Out Tapped");
    [[LQClient single] logout];
    [[NSNotificationCenter defaultCenter] addObserver:appDelegate
                                             selector:@selector(authenticationDidSucceed:)
                                                 name:LQAuthenticationSucceededNotification
                                               object:nil];
    [appDelegate.tabBarController presentModalViewController:[[[AuthView alloc] init] autorelease] animated:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
