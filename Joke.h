//
//  Joke.h
//  iLGL
//
//  Created by Sacha Bartholmé on 24/02/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//


@interface Joke : UIViewController <NSURLConnectionDelegate, UITextViewDelegate>

{
    IBOutlet UITextView *jokeTextView;
    NSMutableData *mutableData;
}

@end
