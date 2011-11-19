//
//  LQPlace.m
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-11-16.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQPlace.h"


@implementation LQPlace

@synthesize place_id, name, display_name, center, radius;

+ (LQPlace *)placeFromDictionary:(NSDictionary *)dict {
	LQPlace *place = [[[LQPlace alloc] init] autorelease];
	
	place.place_id = [dict objectForKey:@"place_id"];
	place.name = [dict objectForKey:@"name"];
	place.display_name = [dict objectForKey:@"display_name"];
	place.center = CLLocationCoordinate2DMake([[dict objectForKey:@"latitude"] doubleValue], [[dict objectForKey:@"longitude"] doubleValue]);
	place.radius = [[dict objectForKey:@"radius"] doubleValue];
	
	return place;
}

- (id)init {
	self = [super init];
	self.name = nil;
	self.display_name = nil;
	self.center = CLLocationCoordinate2DMake(0.0, 0.0);
	self.radius = 0.0;
	return self;
}

- (CLRegion *)region {
	return [[[CLRegion alloc] initCircularRegionWithCenter:self.center radius:self.radius identifier:[NSString stringWithFormat:@"%@ %@", self.place_id, self.display_name]] autorelease];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"\nName: %@\nDisplay Name: %@\nLatitude: %f\nLongitude: %f\nRadius: %d",
			self.name, self.display_name, self.center.latitude, self.center.longitude, self.radius];
}

- (void)dealloc {
	[name release];
	[display_name release];
	[super dealloc];
}

@end
