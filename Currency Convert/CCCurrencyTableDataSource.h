//
//  CCCurrencyTableDataSource.h
//  Currency Convert
//
//  Created by Kyle Lopez on 3/11/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CCCurrencyConversion;

@interface CCCurrencyTableDataSource : NSObject <UITableViewDataSource>

@property (weak) CCCurrencyConversion *convertValue;


-(id)initWithTableView:(UITableView*)tableView;
-(void)refresh:(UITableView*)tableview;
-(NSURLRequest*)getWikipediaURLForIndexPath:(NSIndexPath*)indexPath;
-(CCCurrencyConversion*)conversionForCurrencyISO:(NSString*)currencyISO;
-(CCCurrencyConversion*)conversionForIndexPath:(NSIndexPath*)indexPath;

@end
