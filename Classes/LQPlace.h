//
//  LQPlace.h
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-11-16.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LQPlace : NSObject {

}

@property (nonatomic, retain) NSString *place_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *display_name;
@property (nonatomic, assign) CLLocationCoordinate2D center;
@property (nonatomic, assign) CLLocationDistance radius;

+ (LQPlace *)placeFromDictionary:(NSDictionary *)dict;
- (CLRegion *)region;

@end
