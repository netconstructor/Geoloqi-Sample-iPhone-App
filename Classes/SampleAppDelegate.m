//
//  SampleAppDelegate.m
//  Sample Geoloqi App
//
//  Created by Aaron Parecki on 2011-11-16.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "SampleAppDelegate.h"
#import "AuthView.h"
#import "LQClient.h"
#import "LQConfig.h"

SampleAppDelegate *appDelegate;

@implementation SampleAppDelegate

@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    appDelegate = self;

    if([@"" isEqualToString:LQ_OAUTH_CLIENT_ID]) {
        [[[[UIAlertView alloc] initWithTitle:@"Error!" message:@"You need an API key from developers.geoloqi.com" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Visit Site", nil] autorelease] show];
    }
    
    // Override point for customization after application launch.

    // Add the tab bar controller's view to the window and display.
    [self.window addSubview:tabBarController.view];
    [self.window makeKeyAndVisible];

    if([[LQClient single] isLoggedIn]) {

	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(authenticationDidSucceed:)
													 name:LQAuthenticationSucceededNotification
												   object:nil];
        [tabBarController presentModalViewController:[[[AuthView alloc] init] autorelease] animated:YES];
	}

    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://developers.geoloqi.com/?utm_medium=iPhone+Sample+App"]];
	if(![[UIApplication sharedApplication] openURL:url])
		NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (void)authenticationDidSucceed:(NSNotificationCenter *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQAuthenticationSucceededNotification 
                                                  object:nil];

    [[LQClient single] getPlacesWithCallback:^(NSMutableArray *places, NSError *error){
		if(error != nil) {
			NSLog(@"Error retrieving places: %@", error);
		} else {
			NSLog(@"Places callback! %@", places);
			for(LQPlace *place in places) {
				NSLog(@"Found place %@", place.display_name);
			}
		}
	}];
    
    if (tabBarController.modalViewController && [tabBarController.modalViewController isKindOfClass:[AuthView class]])
        [tabBarController dismissModalViewControllerAnimated:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

