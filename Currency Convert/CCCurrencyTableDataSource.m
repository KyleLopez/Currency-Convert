//
//  CCCurrencyTableDataSource.m
//  Currency Convert
//
//  Created by Kyle Lopez on 3/11/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import "CCCurrencyTableDataSource.h"
#import "CCCurrencyCell.h"
#import "CCOpenExchangeQuery.h"
#import "CCConversionData.h"
#import <QuartzCore/QuartzCore.h>

@interface CCCurrencyTableDataSource()
@property (strong) CCOpenExchangeQuery *query;
@end

@implementation CCCurrencyTableDataSource

-(id)initWithTableView:(UITableView*)tableView
{
    if(self == [super init])
    {
        self.query = [[CCOpenExchangeQuery alloc]initWithTableView:tableView];
    }
    return self;
}

-(CCCurrencyConversion*)conversionForCurrencyISO:(NSString*)currencyISO {
    NSInteger index;
    if((index = [self.query indexOfCurrencyISO:currencyISO]) >= 0)
    {
        CCCurrencyConversion *ret = [((CCConversionData*)self.query.conversionFactors[index]).conversion copy];
        ret.currentValue = [NSDecimalNumber decimalNumberWithString:@"0.0"];
        return ret;
    }
    else
        return nil;
}

-(CCCurrencyConversion*)conversionForIndexPath:(NSIndexPath *)indexPath {
    return [((CCConversionData*)[self.query.conversionFactors objectAtIndex:indexPath.row]).conversion copy];
}

-(void)refresh:(UITableView*)tableview
{
    [self.query refreshValues:tableview];
}

-(NSURLRequest*)getWikipediaURLForIndexPath:(NSIndexPath *)indexPath {
    CCConversionData *data = [self.query.conversionFactors objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.wikipedia.org/wiki/Special:Search/%@",[data.name stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
    return [NSURLRequest requestWithURL:url];
}

#pragma mark - UITableViewDataSource

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCCurrencyCell *cell = (CCCurrencyCell*)[tableView dequeueReusableCellWithIdentifier:@"CCCurrencyCellPrototype"];

    CCConversionData *data = [self.query.conversionFactors objectAtIndex:indexPath.row];
    
    cell.currencyName.text = data.name;
    
    NSDictionary *components = @{NSLocaleCurrencyCode : data.conversion.currencyISO};
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:components]];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc]init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:locale];
    
    [self.convertValue currencyConversionToOtherCurrency:data.conversion];
    
    cell.exchangeValue.text = [currencyFormatter stringFromNumber:data.conversion.currentValue];
    
    cell.currencyImage.image = [UIImage imageNamed:data.conversion.currencyISO];
    
    cell.currencyImage.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.currencyImage.layer.shadowOffset = CGSizeMake(0, 1);
    cell.currencyImage.layer.shadowOpacity = 0.8;
    cell.currencyImage.layer.shadowRadius = 1.0;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.query.conversionFactors count];
}

-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *charSort = [NSMutableArray arrayWithCapacity:26];
    for(CCConversionData *data in self.query.conversionFactors)
    {
        if(![charSort containsObject:[data.conversion.currencyISO substringToIndex:1]])
        {
            [charSort addObject:[data.conversion.currencyISO substringToIndex:1]];
        }
    }
    return charSort;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger b = 0;
    for(CCConversionData *data in self.query.conversionFactors)
    {
        if ([[data.conversion.currencyISO substringToIndex:1] isEqual:title])
        {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:b inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            return b;
        }
        b++;
    }
    return b;
}

@end
