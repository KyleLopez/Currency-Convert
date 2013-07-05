//
//  CCCurrencyViewController.m
//  Currency Convert
//
//  Created by Kyle Lopez on 3/11/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import "CCCurrencyViewController.h"
#import "CCCurrencyTableDataSource.h"
#import "CCWikipediaViewController.h"
#import "CCCurrencyConversion.h"
#import "CCCurrencyCell.h"
#import <QuartzCore/QuartzCore.h>

#define kInputDialogueKey @"TextViewKey"

@interface CCCurrencyViewController ()
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong) CCCurrencyTableDataSource <UITableViewDataSource> *data;
@property (strong) CCCurrencyConversion *moneyValue;
@end

@implementation CCCurrencyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _data = [[CCCurrencyTableDataSource alloc] initWithTableView:self.table];
    self.table.dataSource = _data;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kInputDialogueKey];
    
    NSLocale *locale = [NSLocale currentLocale];
    
    if(!data)
    {
        if((self.moneyValue = [self.data conversionForCurrencyISO:[locale objectForKey:NSLocaleCurrencyCode]]))
        {
            self.moneyValue.currencyISO = [locale objectForKey:NSLocaleCurrencyCode];
        }
        else
        {
            self.moneyValue = [[CCCurrencyConversion alloc]initWithRate:[NSDecimalNumber decimalNumberWithString:@"1.0"]];
            self.moneyValue.currencyISO = @"USD";
            
            NSDictionary *components = @{NSLocaleCurrencyCode : self.moneyValue.currencyISO};
            locale = [[NSLocale alloc]initWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:components]];
        }
        
        data = [NSKeyedArchiver archivedDataWithRootObject:self.moneyValue];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kInputDialogueKey];
    }
    else {
        self.moneyValue = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSDictionary *components = @{NSLocaleCurrencyCode : self.moneyValue.currencyISO};
        locale = [[NSLocale alloc]initWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:components]];
    }
    
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc]init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:locale];
    
    self.currencyInput.text = [currencyFormatter stringFromNumber:self.moneyValue.currentValue];
    
    self.currencyInput.clearButtonMode = UITextFieldViewModeAlways;
    self.currencyInput.delegate = self;
    
    self.currencyIcon.image = [UIImage imageNamed:self.moneyValue.currencyISO];
    
    self.currencyIcon.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currencyIcon.layer.shadowOffset = CGSizeMake(0, 1);
    self.currencyIcon.layer.shadowOpacity = 0.8;
    self.currencyIcon.layer.shadowRadius = 1.0;
    
    self.data.convertValue = self.moneyValue;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    gesture.delegate = self;
    [self.table addGestureRecognizer:gesture];
}

-(void)handleGesture:(UIGestureRecognizer*)gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.currencyInput resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshData:(id)sender {
    [self.data refresh:self.table];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.currencyInput resignFirstResponder];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard" bundle:nil];
    
    CCWikipediaViewController *viewController = [sBoard instantiateViewControllerWithIdentifier:@"wikiViewController"];
    viewController.request = [self.data getWikipediaURLForIndexPath:indexPath];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.moneyValue = [self.data conversionForIndexPath:indexPath];
    self.moneyValue.currentValue = [self.moneyValue.currentValue decimalNumberByRoundingAccordingToBehavior:self];
    self.data.convertValue = self.moneyValue;
    
    CCCurrencyCell *cell = (CCCurrencyCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView *animateView = [[UIImageView alloc] initWithImage:cell.currencyImage.image];
    animateView.contentMode = UIViewContentModeScaleAspectFit;
    animateView.layer.shadowColor = [UIColor blackColor].CGColor;
    animateView.layer.shadowOffset = CGSizeMake(0, 1);
    animateView.layer.shadowOpacity = 0.8;
    animateView.layer.shadowRadius = 1.0;
    
    CGRect vFrame = cell.currencyImage.frame;
    CGPoint vOrigin = [self.view convertPoint:cell.currencyImage.frame.origin fromView:cell.currencyImage];
    vOrigin.x = vOrigin.x + (vFrame.size.width / 2.0f);
    vOrigin.y = vOrigin.y + (vFrame.size.height / 2.0f);
    
    animateView.frame = vFrame;
    animateView.layer.position = vOrigin;
    [self.view addSubview:animateView];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    CGRect eFrame = self.currencyIcon.frame;
    CGPoint endpoint = self.currencyIcon.frame.origin;
    endpoint.x = endpoint.x + (eFrame.size.width / 2.0f);
    endpoint.y = endpoint.y + (eFrame.size.height / 2.0f);
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, vOrigin.x, vOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, endpoint.x + 200, vOrigin.y, endpoint.x + 120, (vOrigin.y+endpoint.y)/2.0f, endpoint.x, endpoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *anim = [CAAnimationGroup animation];
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    [anim setAnimations:@[pathAnimation]];
    anim.duration = 0.6f;
    anim.delegate = self;
    [anim setValue:animateView forKey:@"imageViewBeingAnimated"];
    
    [animateView.layer addAnimation:anim forKey:@"currencySelectAnimation"];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.moneyValue];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kInputDialogueKey];
    
    NSDictionary *components = @{NSLocaleCurrencyCode : self.moneyValue.currencyISO};
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:components]];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc]init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:locale];
    
    self.currencyInput.text = [currencyFormatter stringFromNumber:self.moneyValue.currentValue];
}

#pragma mark - CAAnimationDelegate
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if(flag)
    {
        self.currencyIcon.image = [UIImage imageNamed:self.moneyValue.currencyISO];
        [((UIView*)[anim valueForKeyPath:@"imageViewBeingAnimated"]) removeFromSuperview];
    }
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return [self.currencyInput isFirstResponder];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    self.moneyValue.currentValue = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.moneyValue];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kInputDialogueKey];
    
    self.data.convertValue = self.moneyValue;
    
    NSDictionary *components = @{NSLocaleCurrencyCode : self.moneyValue.currencyISO};
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:components]];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc]init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:locale];
    
    
    self.currencyInput.text = [currencyFormatter stringFromNumber:self.moneyValue.currentValue];
    
    [self.table reloadData];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    UITextRange *range = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
    textField.selectedTextRange = range;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    UITextRange *rnge = [textField textRangeFromPosition:textField.endOfDocument toPosition:textField.endOfDocument];
    textField.selectedTextRange = rnge;
    
    NSDictionary *components = @{NSLocaleCurrencyCode : self.moneyValue.currencyISO};
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:components]];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc]init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:locale];
    
    if([string length] == 1)
    {
        self.moneyValue.currentValue = [self.moneyValue.currentValue decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
        if(currencyFormatter.maximumFractionDigits == 2)
        {
            self.moneyValue.currentValue = [self.moneyValue.currentValue decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"0.0%@",string]]];
        }
        else {
            self.moneyValue.currentValue = [self.moneyValue.currentValue decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",string]]];
        }
    }
    else
    {
        self.moneyValue.currentValue = [self.moneyValue.currentValue decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"10"]withBehavior:self];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.moneyValue];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kInputDialogueKey];
    
    self.currencyInput.text = [currencyFormatter stringFromNumber:self.moneyValue.currentValue];
    self.data.convertValue = self.moneyValue;
    [self.table reloadData];
    return NO;
}

#pragma mark - NSDecimalBehaviors
-(NSRoundingMode)roundingMode {
    return NSRoundDown;
}

-(short)scale {
    NSDictionary *components = @{NSLocaleCurrencyCode : self.moneyValue.currencyISO};
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:components]];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc]init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:locale];
    
    return currencyFormatter.maximumFractionDigits;
}

-(NSDecimalNumber*)exceptionDuringOperation:(SEL)operation error:(NSCalculationError)error leftOperand:(NSDecimalNumber *)leftOperand rightOperand:(NSDecimalNumber *)rightOperand {
    return [NSDecimalNumber decimalNumberWithString:@"-32"];
}

@end
