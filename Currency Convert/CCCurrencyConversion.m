//
//  CCCurrencyConversion.m
//  Currency Convert
//
//  Created by Kyle Lopez on 3/20/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import "CCCurrencyConversion.h"
#import "CCConversionData.h"

@interface CCCurrencyConversion()
@property (strong,readwrite) NSDecimalNumber *conversionRate;
@end

@implementation CCCurrencyConversion

-(id)initWithRate:(NSDecimalNumber *)rate {
    if(self = [super init])
    {
        self.currentValue = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        self.conversionRate = rate;
    }
    return self;
}

-(void)currencyConversionToOtherCurrency:(CCCurrencyConversion*)otherCurrency; {
    otherCurrency.currentValue = [[self.currentValue decimalNumberByDividingBy:self.conversionRate] decimalNumberByMultiplyingBy:otherCurrency.conversionRate];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ : %@ : %@",self.currencyISO,self.conversionRate,self.currentValue];
}

#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.conversionRate forKey:kConversionKey];
    [coder encodeObject:self.currencyISO forKey:kCurrencyTokenKey];
    [coder encodeObject:self.currentValue forKey:kCurrentValueKey];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.conversionRate = [coder decodeObjectForKey:kConversionKey];
        self.currencyISO = [coder decodeObjectForKey:kCurrencyTokenKey];
        self.currentValue = [coder decodeObjectForKey:kCurrentValueKey];
    }
    return self;
}

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone {
    id copy = [[self.class alloc]init];
    
    if(copy)
    {
        [copy setConversionRate:[self.conversionRate copyWithZone:zone]];
        [copy setCurrencyISO:[self.currencyISO copyWithZone:zone]];
        [copy setCurrentValue:[self.currentValue copyWithZone:zone]];
    }
    return copy;
}

@end
