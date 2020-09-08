//
//  Formulas.h
//  iLGL
//
//  Created by Sacha Bartholmé on 1/12/16.
//  Copyright © 2016 The iLGL Team. All rights reserved.
//


@interface Formulas : UIViewController <UIWebViewDelegate>

{
    IBOutlet UIWebView *formulasWebView;
}

@property (strong,nonatomic) NSString *file;

@end
