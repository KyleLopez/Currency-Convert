//
//  CCConversionData.h
//  Currency Convert
//
//  Created by Kyle Lopez on 3/14/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCCurrencyConversion.h"

#define kCurrencyNameKey       @"CurrencyName"
#define kCurrencyConversionKey @"CurrencyConversion"

@interface CCConversionData : NSObject <NSCoding>
@property (strong) NSString *name;
@property (strong) CCCurrencyConversion *conversion;

-(id)initWithRate:(NSDecimalNumber *)rate;

@end
