//
//  CCConversionData.m
//  Currency Convert
//
//  Created by Kyle Lopez on 3/14/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import "CCConversionData.h"

@implementation CCConversionData

-(id)initWithRate:(NSDecimalNumber *)rate {
    if(self = [super init])
    {
        self.conversion = [[CCCurrencyConversion alloc]initWithRate:rate];
    }
    return self;
}

#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:kCurrencyNameKey];
    [coder encodeObject:self.conversion forKey:kCurrencyConversionKey];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.name = [coder decodeObjectForKey:kCurrencyNameKey];
        self.conversion = [coder decodeObjectForKey:kCurrencyConversionKey];
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ : %@", self.name,self.conversion];
}

@end
