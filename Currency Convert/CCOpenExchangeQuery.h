//
//  CCOpenExchangeQuery.h
//  Currency Convert
//
//  Created by Kyle Lopez on 3/13/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCOpenExchangeQuery : NSObject

@property (strong) NSArray *conversionFactors;

-(id)initWithTableView:(UITableView*)tableView;
-(NSArray*)getConversionRates;
-(void)refreshValues:(UITableView*)tableview;
-(NSUInteger)indexOfCurrencyISO:(NSString*)currencyISO;

@end
