//
//  WWManger.h
//  Weather
//
//  Created by King on 16/2/18.
//  Copyright © 2016年 King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWClient.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "WWCondition.h"
#import <TSMessage.h>
#import "WWHourlyForecast.h"
#import "WWDailyForecast.h"
@import CoreLocation;

@interface WWManger : NSObject

@property(nonatomic,strong,readwrite) WWCondition *currentCondition;
@property(nonatomic,strong,readwrite) CLLocation *currentLocation;
@property(nonatomic,strong,readwrite) NSArray *hourlyForecast;
@property(nonatomic,strong,readwrite) NSArray *dailyForecast;
@property(nonatomic,strong,readwrite) NSString *cityName;
@property(nonatomic,strong,readwrite) WWDailyForecast *dailyforecast;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WWClient *client;


+(instancetype)sharedManager;


//启动或刷新整个位置和天气的查找过程
-(void)findCurrentLocation;
@end
