//
//  LQClient.h
//  Sample Geoloqi App
//
//  Created by Aaron Parecki on 2011-08-31.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "LQPlace.h"

static NSString *const LQAPIBaseURL = @"https://api.geoloqi.com/1/";

static NSString *const LQAuthenticationSucceededNotification = @"LQAuthenticationSucceededNotification";
static NSString *const LQAuthenticationFailedNotification = @"LQAuthenticationFailedNotification";
static NSString *const LQAccessTokenKey = @"LQAccessToken";
static NSString *const LQAuthDisplayNameKey = @"LQAuthDisplayNameKey";
static NSString *const LQAuthEmailAddressKey = @"LQAuthEmailAddressKey";
static NSString *const LQAuthUserIDKey = @"LQAuthUserIDKey";
static NSString *const LQAuthSharedLinkKey = @"LQAuthSharedLinkKey";
static NSString *const LQUUIDKey = @"LQUUIDKey";

typedef void (^LQHTTPRequestCallback)(NSDictionary *response, NSError *error);
typedef void (^LQPlaceListCallback)(NSMutableArray *places, NSError *error);

@interface LQClient : NSObject {
}

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *userID;

+ (LQClient *)single;
+ (NSData *)UUID;
+ (NSString *)UUIDString;
- (BOOL)isLoggedIn;

- (void)apiRequest:(NSString *)path withCallback:(LQHTTPRequestCallback)callback;

- (void)createNewAccountWithEmail:(NSString *)email callback:(LQHTTPRequestCallback)callback;
- (void)signInWithUsername:(NSString *)username andPassword:(NSString *)password callback:(LQHTTPRequestCallback)callback;
- (void)sendPushToken:(NSString *)token withCallback:(LQHTTPRequestCallback)callback;

- (void)postLocationUpdate:(CLLocation *)location;
- (void)fetchNearbyLayers:(CLLocation *)location withCallback:(LQHTTPRequestCallback)callback;
- (void)fetchPlaceContext:(CLLocation *)location withCallback:(LQHTTPRequestCallback)callback;
- (void)getPlacesWithCallback:(LQPlaceListCallback)callback;

- (void)logout;

@end

