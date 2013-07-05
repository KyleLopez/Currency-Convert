//
//  CCCurrencyViewController.h
//  Currency Convert
//
//  Created by Kyle Lopez on 3/11/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCurrencyViewController : UIViewController <UITableViewDelegate,UITextFieldDelegate,NSDecimalNumberBehaviors,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *currencyIcon;
@property (weak, nonatomic) IBOutlet UITextField *currencyInput;
@property (weak, nonatomic) IBOutlet UIImageView *topView;

- (IBAction)refreshData:(id)sender;
@end
