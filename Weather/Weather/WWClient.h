//
//  WWClient.h
//  Weather
//
//  Created by King on 16/2/18.
//  Copyright © 2016年 King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
@import CoreLocation;

@interface WWClient : NSObject

-(RACSignal *)fetchJSONFromURL:(NSURL *)url;
-(RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;  //当时
-(RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;  //每时
-(RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;  //每日
@end
