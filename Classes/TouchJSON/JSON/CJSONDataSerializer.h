//
//  CJSONDataSerializer.h
//  TouchCode
//
//  Created by Jonathan Wight on 12/07/2005.
//  Copyright 2005 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

@interface CJSONDataSerializer : NSObject {
}

+ (id)serializer;

/// Take any JSON compatible object (generally NSNull, NSNumber, NSString, NSArray and NSDictionary) and produce an NSData containing the serialized JSON.
- (NSData *)serializeObject:(id)inObject;

- (NSData *)serializeNull:(NSNull *)inNull;
- (NSData *)serializeNumber:(NSNumber *)inNumber;
- (NSData *)serializeString:(NSString *)inString;
- (NSData *)serializeArray:(NSArray *)inArray;
- (NSData *)serializeDictionary:(NSDictionary *)inDictionary;

- (NSData *)serializeObject:(id)inObject withDepth:(NSInteger)depth;
- (NSData *)serializeArray:(NSArray *)inArray withDepth:(NSInteger)depth;
- (NSData *)serializeDictionary:(NSDictionary *)inDictionary withDepth:(NSInteger)depth;

@end