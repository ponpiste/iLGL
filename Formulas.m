//
//  Formulas.m
//  iLGL
//
//  Created by Sacha Bartholmé on 1/12/16.
//  Copyright © 2016 The iLGL Team. All rights reserved.
//

#import "Formulas.h"

@implementation Formulas

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [_file stringByReplacingOccurrencesOfString:@".pdf" withString:@""];
    
    NSString *path = [NSString stringWithFormat:@"%@/Physics/%@",[NSBundle mainBundle].resourcePath,_file];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [formulasWebView loadData:data MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:[NSURL new]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIView animateWithDuration:0.5 animations:^{webView.alpha = 1.0;}];
}

@end
