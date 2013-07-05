//
//  CCCurrencyConversion.h
//  Currency Convert
//
//  Created by Kyle Lopez on 3/20/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCurrencyTokenKey @"CurrencyToken"
#define kConversionKey    @"FromUSDConversion"
#define kCurrentValueKey  @"CurrencyCurrentValue"

@interface CCCurrencyConversion : NSObject <NSCoding,NSCopying>

@property (strong) NSDecimalNumber *currentValue;
@property (strong) NSString *currencyISO;
@property (strong, readonly) NSDecimalNumber *conversionRate;

-(id)initWithRate:(NSDecimalNumber *)rate;
-(void)currencyConversionToOtherCurrency:(CCCurrencyConversion*)otherCurrency;

@end
