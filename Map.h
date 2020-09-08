//
//  Map.h
//  iLGL
//
//  Created by Sacha Bartholmé on 13/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Map : UIViewController <MKMapViewDelegate>

{
    IBOutlet MKMapView *schoolMapView;
}

@end
