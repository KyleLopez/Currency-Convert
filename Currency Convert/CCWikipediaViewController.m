//
//  CCWikipediaViewController.m
//  Currency Convert
//
//  Created by Kyle Lopez on 3/20/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import "CCWikipediaViewController.h"
#import "Reachability.h"

@interface CCWikipediaViewController ()
@property (strong)UIActivityIndicatorView *indicator;
@end

@implementation CCWikipediaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    Reachability *reachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reachable currentReachabilityStatus];
    
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    
    if(netStatus != NotReachable) {
        [self.webView loadRequest:self.request];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Unable to access internet connection. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView {
    if(!self.indicator)
    {
        self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicator.center = self.view.center;
        [self.view addSubview:self.indicator];
        self.indicator.hidesWhenStopped = YES;
    }
    [self.indicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.indicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Error loading Wikipedia Content. Please try again later." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
    [alert show];
}

@end
