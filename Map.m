//
//  Map.m
//  iLGL
//
//  Created by Sacha Bartholmé on 13/07/15.
//  Copyright (c) 2015 The iLGL Team. All rights reserved.
//

#import "Map.h"

@implementation Map

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self home];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    CLLocationCoordinate2D centre = [mapView centerCoordinate];
    self.navigationItem.title = [NSString stringWithFormat:@"%.3f  %.3f", centre.latitude, centre.longitude];
}

- (IBAction)home {
    
    CLLocationCoordinate2D center;
    center.latitude = 49.61970;
    center.longitude= 6.12134;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, 300, 300);
    [schoolMapView setRegion:region animated:YES];
}

@end
