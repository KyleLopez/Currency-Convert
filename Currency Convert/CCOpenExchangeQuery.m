//
//  CCOpenExchangeQuery.m
//  Currency Convert
//
//  Created by Kyle Lopez on 3/13/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import "CCOpenExchangeQuery.h"
#import "Reachability.h"
#import "CCConversionData.h"

#define kTimestampKey @"TimestampKey"

@interface CCOpenExchangeQuery() {
    NSString *app_id;
    NSString *api_url;
    NSString *api_conversions;
    NSString *api_names;
}
@property (strong) NSString *filePath;
@property (strong) NSDate *timestamp;
@end

@implementation CCOpenExchangeQuery

-(id)initWithTableView:(UITableView*)tableView {
    if(self = [super init]) {
        app_id = @"?app_id=c6f28b0e681243b69c9bfbccdf7eee15";
        api_url = @"http://openexchangerates.org/api/";
        api_conversions = @"latest.json";
        api_names = @"currencies.json";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        self.filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CurrencyRates.plist"];
        
        self.conversionFactors =(NSArray *)[NSKeyedUnarchiver unarchiveObjectWithFile:self.filePath];
        
        if(!self.conversionFactors || [[NSDate date] timeIntervalSinceDate:self.timestamp] >= 3600)
        {
            self.conversionFactors = [NSArray array];
            [self fetchUpdate:tableView];
        }
        else
        {
            self.timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kTimestampKey];
        }
    }
    return self;
}

-(NSUInteger)indexOfCurrencyISO:(NSString*)currencyISO
{
    NSInteger len = [self.conversionFactors count];
    for(NSInteger i = 0; i < len; i++)
    {
        CCConversionData *data = (CCConversionData*)self.conversionFactors[i];
        if([data.conversion.currencyISO isEqualToString:currencyISO])
            return i;
    }
    return -1;
}

-(void)fetchUpdate:(UITableView*)tableview {
    Reachability *reachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reachable currentReachabilityStatus];
    
    if(netStatus != NotReachable)
    {
        NSOperationQueue *downloadQueue = [[NSOperationQueue alloc]init];
        downloadQueue.name = @"DownloadQueue";
        
        [downloadQueue addOperationWithBlock:^(void){
            NSURLRequest *request_conversions = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",api_url,api_conversions,app_id]]];
            NSURLRequest *request_currencyNames = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",api_url,api_names,app_id]]];
            
            NSURLResponse *response1 = nil;
            NSError *error1 = nil;
            NSURLResponse *response2 = nil;
            NSError *error2 = nil;
            
            NSData *conversion_data = [NSURLConnection sendSynchronousRequest:request_conversions returningResponse:&response1 error:&error1];
            
            NSData *currencyNames_data = [NSURLConnection sendSynchronousRequest:request_currencyNames returningResponse:&response2 error:&error2];
            
            if(error1 == nil && error2 == nil)
            {
                NSDictionary *conversion_dict = [NSJSONSerialization JSONObjectWithData:conversion_data options:kNilOptions error:&error1];
                NSDictionary *currency_dict = [NSJSONSerialization JSONObjectWithData:currencyNames_data options:kNilOptions error:&error2];
                
                NSDictionary *conversions = [conversion_dict objectForKey:@"rates"];
                NSMutableArray *fin_data = [NSMutableArray arrayWithCapacity:161];
                
                for (NSString *key in conversions) {
                    CCConversionData *nData = [[CCConversionData alloc]initWithRate:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[conversions objectForKey:key]]]];
                    
                    nData.name = [currency_dict objectForKey:key];
                    nData.conversion.currencyISO = key;
                    
                    [fin_data addObject:nData];
                }
                
                self.conversionFactors = [fin_data sortedArrayUsingComparator:^(id obj1, id obj2){
                    CCConversionData *ob1 = obj1;
                    CCConversionData *ob2 = obj2;
                    return [ob1.conversion.currencyISO compare:ob2.conversion.currencyISO];
                }];
                
                NSOperationQueue *saveQueue = [[NSOperationQueue alloc]init];
                saveQueue.name = @"SaveQueue";
                
                [saveQueue addOperationWithBlock:^(void){
                    self.timestamp = [NSDate date];
                    [NSKeyedArchiver archiveRootObject:self.conversionFactors toFile:self.filePath];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:self.timestamp forKey:kTimestampKey];
                }];
                if(tableview != nil)
                {
                    [tableview reloadData];
                }
            }
            else
            {
                NSLog(@"Error: %@ & %@",error1,error2);
            }
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Unable to access internet connection. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [alert show];
    }
}

-(void)refreshValues:(UITableView*)tableview{
    NSDate *now = [NSDate date];
    if([now timeIntervalSinceDate:self.timestamp] >= 3600)
    {
        [self fetchUpdate:tableview];
    }
    else
    {
        [tableview reloadData];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Refresh" message:@"Unable to refresh:currency data only updates once every hour. Try again later" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [alert show];
    }
}

-(NSArray*)getConversionRates {
    return self.conversionFactors;
}

@end
