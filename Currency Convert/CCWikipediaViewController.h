//
//  CCWikipediaViewController.h
//  Currency Convert
//
//  Created by Kyle Lopez on 3/20/13.
//  Copyright (c) 2013 Kyle Lopez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCWikipediaViewController : UIViewController <UIWebViewDelegate>
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURLRequest *request;

@end
