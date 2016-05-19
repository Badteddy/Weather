//
//  ViewController.m
//  Weather
//
//  Created by King on 16/2/17.
//  Copyright © 2016年 King. All rights reserved.
//

#import "ViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WWManger.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "WWDailyForecast.h"
#import "WWHourlyForecast.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property(nonatomic,strong) UIImageView *backgroundImageView;
@property(nonatomic,strong) UIImageView *blurredImageView;  //模糊图片
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,assign) CGFloat screenHeight;   //屏幕高度
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@end

@implementation ViewController


-(BOOL)prefersStatusBarHidden{
    
    return YES;
}

- (id)init {
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"M月d日 a h点 ";
        
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"EEEE";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *background = [UIImage imageNamed:@"bbg.jpg"];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    // 表头
    CGRect headerFrame = [UIScreen mainScreen].bounds;
   
    CGFloat inset = 20;
    
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    CGFloat locationIconHeight = 25;
    
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    
    CGRect locationIconFrame = CGRectMake((headerFrame.size.width-iconHeight )/2,
                                          50+inset/4,
                                          locationIconHeight,
                                          locationIconHeight);
    
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    //hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    // top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    //location icon
    
    UIImageView *locationIcon =  [[UIImageView alloc] initWithFrame:locationIconFrame];
    locationIcon.contentMode = UIViewContentModeScaleAspectFit;
    locationIcon.backgroundColor = [UIColor clearColor];
    [header addSubview:locationIcon];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview:conditionsLabel];
    
    
    // bottom left
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
    
    [[WWManger sharedManager] findCurrentLocation];
    //观察WXManager单例的currentCondition
    [[RACObserve([WWManger sharedManager], currentCondition)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WWCondition *newCondition) {
         //使用气象数据更新文本标签
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f℃",newCondition.main.temp.floatValue];
         
         conditionsLabel.text = newCondition.weather[0].main;
         //使用映射的图像文件名来创建一个图像，并将其设置为视图的图标
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    
    [[RACObserve([WWManger sharedManager], cityName)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSString *city) {
         cityLabel.text = city;
         locationIcon.image = [UIImage imageNamed:@"citymanage_location@2x"];
     }];
    
    
    
//    RAC(hiloLabel,text) =  [[RACSignal combineLatest:@[
//                                                       [RACObserve([WWManger sharedManager],currentCondition.main.temp_max) distinctUntilChanged],
//                                                       [RACObserve([WWManger sharedManager], currentCondition.main.temp_min) distinctUntilChanged]
//                                                       ]
//                                              reduce:^(id hi, id  low){
//                                                
//                                               
//                                                  
//                                                  
//                                                  return [NSString stringWithFormat:@"%.0f℃ /%.0f℃",[(NSNumber *)hi floatValue] ,[(NSNumber *)low floatValue]];
//                                                  
//                                              }]
//                            deliverOn:RACScheduler.mainThreadScheduler];
    
    
    [[RACObserve([WWManger sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
         
         
     }];
    
    [[RACObserve([WWManger sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
         
         
     }];
    
   
    
    
    
    
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark- UITableViewDataSource


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        //使用最近9小时的预预报，并添加了一个作为页眉的单元格
        return MIN([[WWManger sharedManager].hourlyForecast count], 9) + 1;
    }
    
    //最近7天的每日预报，并添加了一个作为页眉的单元格
    return MIN([[WWManger sharedManager].dailyForecast count], 7) + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor= [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"最近一天" detailTitle:@"温度"];
        }
        else {
            
            List_Hourly *hourly = [WWManger sharedManager].hourlyForecast[indexPath.row -1];
            [self configureHourlyCell:cell weather:hourly];
        }
    }
    else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"最近一周" detailTitle:@"最高/最低"];
        }
        else {
            
            List_Daily *daily = [WWManger sharedManager].dailyForecast[indexPath.row -1];
            [self configureDailyCell:cell weather:daily];
            
            
            
        }
    }
    return cell;
}

#pragma mark- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}



// 1

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    
    CGFloat percent = MIN(position / height, 1.0);
    
    self.blurredImageView.alpha = percent;
}
#pragma mark- ConfigureCell
- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title detailTitle:(NSString *)detailTitle{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detailTitle;
    cell.imageView.image = nil;
}


- (void)configureHourlyCell:(UITableViewCell *)cell weather:(List_Hourly *)hourly {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:hourly.dt]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f℃",hourly.main.temp.floatValue];
    cell.imageView.image = [UIImage imageNamed:[hourly imageName:hourly.weather[0].icon]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
}


- (void)configureDailyCell:(UITableViewCell *)cell weather:(List_Daily *)daily {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:daily.dt]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f℃ / %.0f℃",
                                 daily.temp.max.floatValue,
                                 daily.temp.min.floatValue
                                 ];
    cell.imageView.image = [UIImage imageNamed:[daily imageName:daily.weather[0].icon]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
