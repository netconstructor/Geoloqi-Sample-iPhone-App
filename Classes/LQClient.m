//
//  LQClient.m
//  Sample Geoloqi App
//
//  Created by Aaron Parecki on 2011-08-31.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQClient.h"
#import "LQConfig.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation LQClient

+ (LQClient *)single {
	static LQClient *singleton = nil;
    if(!singleton) {
		singleton = [[self alloc] init];
	}
	return singleton;
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark -
/**
 * Getter/setter for properties, uses NSUserDefaults for permanent storage.
 */
- (NSString *)accessToken {
	return [[NSUserDefaults standardUserDefaults] stringForKey:LQAccessTokenKey];
}
- (void)setAccessToken:(NSString *)token {
	[[NSUserDefaults standardUserDefaults] setObject:[[token copy] autorelease] forKey:LQAccessTokenKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)displayName {
	return [[NSUserDefaults standardUserDefaults] stringForKey:LQAuthDisplayNameKey];
}
- (void)setDisplayName:(NSString *)name {
	[[NSUserDefaults standardUserDefaults] setObject:[[name copy] autorelease] forKey:LQAuthDisplayNameKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)emailAddress {
	return [[NSUserDefaults standardUserDefaults] stringForKey:LQAuthEmailAddressKey];
}
- (void)setEmailAddress:(NSString *)email {
	[[NSUserDefaults standardUserDefaults] setObject:[[email copy] autorelease] forKey:LQAuthEmailAddressKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)userID {
	return [[NSUserDefaults standardUserDefaults] stringForKey:LQAuthUserIDKey];
}
- (void)setUserID:(NSString *)uid {
	[[NSUserDefaults standardUserDefaults] setObject:[[uid copy] autorelease] forKey:LQAuthUserIDKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)sharedLink {
	return [[NSUserDefaults standardUserDefaults] stringForKey:LQAuthSharedLinkKey];
}
- (void)setSharedLink:(NSString *)token {
	[[NSUserDefaults standardUserDefaults] setObject:[[token copy] autorelease] forKey:LQAuthSharedLinkKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isLoggedIn {
	return self.accessToken != nil;
}

#pragma mark API Request Methods

- (ASIHTTPRequest *)appRequestWithURL:(NSURL *)url {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
	[request setUsername:LQ_OAUTH_CLIENT_ID];
	[request setPassword:LQ_OAUTH_SECRET];
	return request;
}

- (ASIHTTPRequest *)appRequestWithURL:(NSURL *)url class:(NSString *)class {
	ASIHTTPRequest *request = [NSClassFromString(class) requestWithURL:url];
	[request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
	[request setUsername:LQ_OAUTH_CLIENT_ID];
	[request setPassword:LQ_OAUTH_SECRET];
	return request;
}

- (ASIHTTPRequest *)userRequestWithURL:(NSURL *)url {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth %@", self.accessToken]];
	return request;
}

- (ASIHTTPRequest *)userRequestWithURL:(NSURL *)url class:(NSString *)class {
	ASIHTTPRequest *request = [NSClassFromString(class) requestWithURL:url];
	[request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth %@", self.accessToken]];
	return request;
}

- (NSDictionary *)dictionaryFromResponse:(NSString *)response {
	NSError *err = nil;
	NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[response dataUsingEncoding:NSUTF8StringEncoding] error:&err];
	return res;
}

- (NSURL *)urlWithPath:(NSString *)path {
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", LQAPIBaseURL, path]];
}

- (void)runRequest:(ASIHTTPRequest *)inRequest callback:(LQHTTPRequestCallback)callback {
	__block ASIHTTPRequest *request = inRequest;
	[request setCompletionBlock:^{
		callback([self dictionaryFromResponse:[request responseString]], nil);
	}];
	[request setFailedBlock:^{
		callback(nil, request.error);
	}];
	[request startAsynchronous];
}

- (void)apiRequest:(NSString *)path withCallback:(LQHTTPRequestCallback)callback {
	__block ASIHTTPRequest *request = [self userRequestWithURL:[self urlWithPath:path]];
	[self runRequest:request callback:callback];
}

/**
 * Helper method for returning device hardware string
 */
- (NSString *)hardware
{
	size_t size;
	
	// Set 'oldp' parameter to NULL to get the size of the data
	// returned so we can allocate appropriate amount of space
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
	
	// Allocate the space to store name
	char *name = malloc(size);
	
	// Get the platform name
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	
	// Place name into a string
	NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
	
	// Done with this
	free(name);
	
	return machine;
}

- (void)addDeviceInfoToRequest:(ASIFormDataRequest *)request {
	UIDevice *d = [UIDevice currentDevice];
	[request setPostValue:[NSString stringWithFormat:@"%@ %@", d.systemName, d.systemVersion] forKey:@"platform"];
	[request setPostValue:[self hardware] forKey:@"hardware"];
	[request setPostValue:[LQClient UUIDString] forKey:@"device_id"];
}


#pragma mark Login Methods

- (void)createNewAccountWithEmail:(NSString *)email callback:(LQHTTPRequestCallback)callback {
	NSURL *url = [self urlWithPath:@"user/create"];
	__block ASIFormDataRequest *request = (ASIFormDataRequest *)[self appRequestWithURL:url class:@"ASIFormDataRequest"];
    
	[self addDeviceInfoToRequest:request];
    [request setPostValue:email forKey:@"email"];
	
	[request setCompletionBlock:^{
		NSDictionary *responseDict = [self dictionaryFromResponse:[request responseString]];
        if([responseDict objectForKey:@"error"] == nil) {
            NSLog(@"User Create Response: %@", responseDict);
            self.emailAddress = email;
            self.userID = (NSString *)[responseDict objectForKey:@"user_id"];
            self.displayName = (NSString *)[responseDict objectForKey:@"display_name"];
            self.accessToken = (NSString *)[responseDict objectForKey:@"access_token"];  // this runs synchronize
            callback(responseDict, nil);
        } else {
            NSLog(@"User Create Response: %@", responseDict);
            NSNumber *errorNumber = [responseDict objectForKey:@"error_code"];
            callback(nil, [NSError errorWithDomain:@"geoloqi.com" code:[errorNumber intValue] userInfo:responseDict]);
        }
	}];
	[request startAsynchronous];
}

- (void)signInWithUsername:(NSString *)username andPassword:(NSString *)password callback:(LQHTTPRequestCallback)callback {
	NSURL *url = [self urlWithPath:@"oauth/token"];
	__block ASIFormDataRequest *request = (ASIFormDataRequest *)[self appRequestWithURL:url class:@"ASIFormDataRequest"];
    
	[self addDeviceInfoToRequest:request];
    [request setPostValue:@"password" forKey:@"grant_type"];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
	
	[request setCompletionBlock:^{
        NSDictionary *responseDict = [self dictionaryFromResponse:[request responseString]];
        if([responseDict objectForKey:@"error"] == nil) {
            NSLog(@"User Login Response: %@", responseDict);
            self.userID = (NSString *)[responseDict objectForKey:@"user_id"];
            self.displayName = (NSString *)[responseDict objectForKey:@"display_name"];
            self.accessToken = (NSString *)[responseDict objectForKey:@"access_token"];  // this runs synchronize
            callback(responseDict, nil);
        } else {
            NSLog(@"User Login Response: %@", responseDict);
            NSNumber *errorNumber = [responseDict objectForKey:@"error_code"];
            callback(nil, [NSError errorWithDomain:@"geoloqi.com" code:[errorNumber intValue] userInfo:responseDict]);
        }
	}];
	[request startAsynchronous];
}

- (void)sendPushToken:(NSString *)token withCallback:(LQHTTPRequestCallback)callback {
	NSURL *url = [self urlWithPath:@"account/set_apn_token"];
	__block ASIFormDataRequest *request = (ASIFormDataRequest *)[self userRequestWithURL:url class:@"ASIFormDataRequest"];
	[self addDeviceInfoToRequest:request];
	[request setPostValue:token forKey:@"token"];
	[self runRequest:request callback:callback];
}

#pragma mark API Methods

- (void)createShareToken {
	NSURL *url = [self urlWithPath:@"link/create"];
	__block ASIFormDataRequest *request = (ASIFormDataRequest *)[self userRequestWithURL:url class:@"ASIFormDataRequest"];
	[request setPostValue:@"Testing Location" forKey:@"description"];
	[self runRequest:request callback:^(NSDictionary *response, NSError *error){
		self.sharedLink = [response objectForKey:@"shortlink"];
	}];
}

- (void)fetchNearbyLayers:(CLLocation *)location withCallback:(LQHTTPRequestCallback)callback {
	NSURL *url = [self urlWithPath:[NSString stringWithFormat:@"layer/nearby?latitude=%f&longitude=%f", 
									location.coordinate.latitude, location.coordinate.longitude]];
	__block ASIHTTPRequest *request;
	if([self isLoggedIn]) {
		request = [self userRequestWithURL:url];
	} else {
		request = [self appRequestWithURL:url];
	}
	[self runRequest:request callback:callback];
}

- (void)fetchPlaceContext:(CLLocation *)location withCallback:(LQHTTPRequestCallback)callback {
	NSURL *url = [self urlWithPath:[NSString stringWithFormat:@"location/context?latitude=%f&longitude=%f", 
									location.coordinate.latitude, location.coordinate.longitude]];
	__block ASIHTTPRequest *request;
	if([self isLoggedIn]) {
		request = [self userRequestWithURL:url];
	} else {
		request = [self appRequestWithURL:url];
	}
	[self runRequest:request callback:callback];
}

- (void)getPlacesWithCallback:(LQPlaceListCallback)callback {
	[self apiRequest:@"place/list" withCallback:^(NSDictionary *response, NSError *error){
		if(error != nil) {
			callback(nil, error);
		} else {
			NSLog(@"[LQClient] %@", [response objectForKey:@"places"]);
			NSMutableArray *places = [[NSMutableArray alloc] init];
			if([response objectForKey:@"places"] != nil) {
				for(NSMutableDictionary *place in [response objectForKey:@"places"]) {
					[places addObject:[LQPlace placeFromDictionary:place]];
				}
			}
			callback(places, nil);
		}
	}];
}

#pragma mark Location Methods

- (NSString *)dateInFormat:(NSString*)stringFormat {
	char buffer[80];
	const char *format = [stringFormat UTF8String];
	time_t rawtime;
	struct tm *timeinfo;
	time(&rawtime);
	timeinfo = localtime(&rawtime);
	strftime(buffer, 80, format, timeinfo);
	return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)dictionaryFromLocation:(CLLocation *)location
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	
	NSDictionary *pos = [NSDictionary dictionaryWithObjectsAndKeys:
						 [NSNumber numberWithDouble:location.coordinate.latitude], @"latitude",
						 [NSNumber numberWithDouble:location.coordinate.longitude], @"longitude",
						 [NSNumber numberWithDouble:location.speed * 3.6], @"speed",
						 [NSNumber numberWithDouble:location.altitude], @"altitude",
						 [NSNumber numberWithDouble:location.course], @"heading",
						 [NSNumber numberWithDouble:location.verticalAccuracy], @"vertical_accuracy",
						 [NSNumber numberWithDouble:location.horizontalAccuracy], @"horizontal_accuracy",
						 nil];
	
	[dictionary setObject:[NSDictionary dictionaryWithObject:pos forKey:@"position"]
				   forKey:@"location"];
    
	[dictionary setObject:[NSString stringWithFormat:@"%d", [[NSNumber numberWithDouble:[location.timestamp timeIntervalSince1970]] intValue]] forKey:@"date"];
	
	UIDevice *d = [UIDevice currentDevice];
	
	// Raw information
	[dictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:1], @"distance_filter",
						   [NSNumber numberWithInt:0], @"tracking_limit",
						   [NSNumber numberWithInt:0], @"rate_limit",
						   [NSNumber numberWithInt:round(d.batteryLevel*100)], @"battery",
						   nil]
				   forKey:@"raw"];
	// NB: it appears iOS rounds the reported battery level to increments of 5%
	
	// Client device information
	NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
	[dictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:
						   [bundleInfo objectForKey:@"CFBundleDisplayName"], @"name",
						   [bundleInfo objectForKey:@"CFBundleVersion"], @"version",
						   [NSString stringWithFormat:@"%@ %@", d.systemName, d.systemVersion], @"platform",
						   [self hardware], @"hardware",
						   nil]
				   forKey:@"client"];
	
	return dictionary;
}

- (void)postLocationUpdate:(CLLocation *)location {
	NSURL *url = [self urlWithPath:@"location/update"];
	__block ASIFormDataRequest *request = (ASIFormDataRequest *)[self userRequestWithURL:url class:@"ASIFormDataRequest"];
    NSMutableArray *points = [[NSMutableArray alloc] init];
    [points addObject:[self dictionaryFromLocation:location]];
    NSString *jsonString = [[CJSONSerializer serializer] serializeArray:points];
    [request setPostBody:[NSData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
    [request addRequestHeader:@"Content-type" value:@"application/json"];
	[self runRequest:request callback:^(NSDictionary *response, NSError *error){
        NSLog(@"Location Update Succeeded: %@", response);
	}];
}

#pragma mark -

+ (NSData *)UUID {
	if([[NSUserDefaults standardUserDefaults] dataForKey:LQUUIDKey] == nil) {
		CFUUIDRef theUUID = CFUUIDCreate(NULL);
		CFUUIDBytes bytes = CFUUIDGetUUIDBytes(theUUID);
		NSData *dataUUID = [NSData dataWithBytes:&bytes length:sizeof(CFUUIDBytes)];
		CFRelease(theUUID);
		[[NSUserDefaults standardUserDefaults] setObject:dataUUID forKey:LQUUIDKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		DLog(@"Generating new UUID: %@", dataUUID);
		return dataUUID;
	} else {
		DLog(@"Returning existing UUID: %@", [[NSUserDefaults standardUserDefaults] dataForKey:LQUUIDKey]);
		return [[NSUserDefaults standardUserDefaults] dataForKey:LQUUIDKey];
	}
}

+ (NSString *)UUIDString {
	const unsigned *tokenBytes = [[LQClient UUID] bytes];
	return [NSString stringWithFormat:@"%08x%08x%08x%08x",
                            ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]), ntohl(tokenBytes[3])];	
}

- (void)logout {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:LQAuthEmailAddressKey];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:LQAuthUserIDKey];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:LQAccessTokenKey];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:LQAuthSharedLinkKey];
	self.accessToken = nil;
}
@end


