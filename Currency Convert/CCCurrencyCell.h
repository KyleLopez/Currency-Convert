//
//  CCCurrencyCell.h
//  Currency Convert
//
//  Created by Kyle Lopez on 3/11/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCurrencyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *currencyImage;
@property (weak, nonatomic) IBOutlet UILabel *currencyName;
@property (weak, nonatomic) IBOutlet UILabel *exchangeValue;

@end
