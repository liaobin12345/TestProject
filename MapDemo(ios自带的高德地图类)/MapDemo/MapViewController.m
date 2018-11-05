//
//  MapViewController.m
//  MapDemo
//
//  Created by mac on 14-8-21.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"

@interface MapViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
{
    // 地图类
    MKMapView * _mapView;
    // 定位类
    CLLocationManager * _manager;
    
    CLLocationCoordinate2D coordinate;
}

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



//- (void)viewWillAppear:(BOOL)animated
//{
//    // 判断的手机的定位功能是否开启
//    if ([CLLocationManager locationServicesEnabled]) {
//        // 启动位置更新
//        [_manager startUpdatingLocation];
//    }
//    else {
//        NSLog(@"请开启定位功能！");
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    //地图类型
//    MKMapTypeStandard = 0;普通地图
//    MKMapTypeSatellite,卫星地图
//    MKMapTypeHybrid,混合地图
  // _mapView.mapType = MKMapTypeSatellite;
  //   _mapView.mapType = MKMapTypeHybrid;
    _mapView.mapType = MKMapTypeStandard;
    [self.view addSubview:_mapView];
    
    //    22.545617,113.948135 南山科技园经纬度
    /*
     typedef struct {
     CLLocationCoordinate2D center; 经纬度结构体
     MKCoordinateSpan span; 显示范围结构体
     } MKCoordinateRegion;
     */
    CLLocationCoordinate2D coordinate2D = {22.545617,113.948135};
    
    // 创建一个经纬度结构体
    //    CLLocationCoordinate2D tempCoordinate2D = CLLocationCoordinate2DMake(<#CLLocationDegrees latitude#>, <#CLLocationDegrees longitude#>)
    // 决定地图的显示范围 值越小 地图显示越精确
    MKCoordinateSpan span = {0.05,0.05};
    //将经纬度和精度设置到地图上
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate2D, span);
    [_mapView setRegion:region animated:YES];
    
    // 左右移  上下移   放大缩小   2选1
    UISegmentedControl * segCtl = [[UISegmentedControl alloc] initWithItems:@[@"左移",@"下移",@"放大"]];
    self.navigationItem.titleView = segCtl;
    [segCtl addTarget:self action:@selector(segChange:) forControlEvents:UIControlEventValueChanged];
    // 定位
    //  允许访问用户当前的位置
    _mapView.showsUserLocation = YES;
    // 创建一个定位的对象
    _manager = [[CLLocationManager alloc] init];
    // 通过代理的形式返回用户当前的经纬度
    _manager.delegate = self;
    // 定位距离(有三种)
    _manager.distanceFilter = kCLLocationAccuracyHundredMeters;
    // 定位效果
    _manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(startLocation)];
    // 大头针
    for (int i = 0; i < 10 ;i++) {
        MyAnnotation * annotation = [[MyAnnotation alloc] initWithCoordinate:coordinate2D withTitle:@"深圳" withSubtitle:@"科技园"];
        // 添加大头针
        [_mapView addAnnotation:annotation];
        coordinate2D.latitude += 0.001;
        coordinate2D.longitude += 0.001;
    }
    
    // 移除大头针   _mapView.annotations 当前地图上所有大头针集合的数组
    [_mapView removeAnnotations:_mapView.annotations];
    // 定制大头针
    _mapView.delegate = self;
    

    //添加长按手势
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_mapView addGestureRecognizer:longPress];
}

- (void)longPress:(UILongPressGestureRecognizer *)press
{
    // 手势作用0.5秒触发 手势开始（开始 取消 结束 改变。。。）
    if (press.state == UIGestureRecognizerStateBegan) {
        // 获取用户手势作用点的坐标
        CGPoint point = [press locationInView:_mapView];
        // 将UIVIEW坐标转化为经纬度
        CLLocationCoordinate2D coodinate2D = [_mapView convertPoint:point toCoordinateFromView:_mapView];
        
        [_mapView removeOverlays:_mapView.overlays];
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:coodinate2D radius:1000];
        [_mapView addOverlay:circle];

        
        // 根据经纬度 编码为 改点的详细信息
        CLGeocoder * geocoder = [[CLGeocoder alloc] init];
        CLLocation * location = [[CLLocation alloc] initWithLatitude:coodinate2D.latitude longitude:coodinate2D.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            // 详细位置信息类（国家 省 市 自治区 街道 邮政编码...）
            CLPlacemark * placeMark = placemarks[0];
            NSLog(@">>>%@ %@ %@ %@ %@ %@",placeMark.name,placeMark.locality,placeMark.country,placeMark.thoroughfare,placeMark.ISOcountryCode,placeMark.ocean);
        }];
        
        MyAnnotation * annotation = [[MyAnnotation alloc] initWithCoordinate:coodinate2D withTitle:@"xxx" withSubtitle:@"xxxxxx"];
        [_mapView addAnnotation:annotation];
    }
}


// 开始定位
- (void)startLocation
{
    [_manager startUpdatingLocation];
    //[_manager stopUpdatinglocation]
}


- (void)segChange:(UISegmentedControl *)ctl
{
    switch (ctl.selectedSegmentIndex) {
        case 0:
        {
            CLLocationCoordinate2D coordinate2D = _mapView.region.center;
            coordinate2D.longitude -= 0.001;
            _mapView.region = MKCoordinateRegionMake(coordinate2D, _mapView.region.span);
        }
            break;
        case 1:
        {
            CLLocationCoordinate2D coordinate2D = _mapView.region.center;
            coordinate2D.latitude -= 0.001;
            _mapView.region = MKCoordinateRegionMake(coordinate2D, _mapView.region.span);
        }
            break;
        default:
        {
            MKCoordinateSpan span = _mapView.region.span;
            span.latitudeDelta *= 0.9;
            span.longitudeDelta *= 0.9;
            _mapView.region = MKCoordinateRegionMake(_mapView.region.center, span);
        }
            break;
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // 定位成功回调
    NSLog(@"定位成功 %@",locations);
    CLLocation * location = locations[0];
    // 拿到香港的经纬度(结构体)
    CLLocationCoordinate2D coodinate2D = location.coordinate;
    
    
    //定位到哪 地图就就切到哪
    [_mapView setRegion:MKCoordinateRegionMake(coodinate2D, _mapView.region.span) animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // 定位失败回调
    NSLog(@"error is %@",error);
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        NSLog(@"这是用户当前的位置,不需要定制..");
        return nil;
    }
    
    MKAnnotationView * view = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MyAnnotation"];
    if (view == nil){
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyAnnotation"];
    }
    
#if 0
    MKPinAnnotationView * view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MyAnnotation"];
    if (view == nil) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyAnnotation"];
    }
    //MKPinAnntationView 专有的方法 不能定制大头针可以改变气泡
    //修改大头针颜色
    view.pinColor = MKPinAnnotationColorGreen;
    // 出现动画
    view.animatesDrop = YES;
#endif
        
    // 点击弹出气泡
    view.canShowCallout = YES;
    
    // MKAnnotationView 专有的 可以定制大头针
    view.image = [UIImage imageNamed:@"map.png"];
   
#if 0
    //自定义气泡上 左右的扩展 32*32大小的图片
        
    UIImageView * imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map.png"]];
    imgView.frame =  CGRectMake(-15, -15, 32, 32);
    view.leftCalloutAccessoryView = imgView;
    
    UIButton * b = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    b.frame = CGRectMake(0, 0, 32, 32);
    [b addTarget:self action:@selector(buddleClick:) forControlEvents:UIControlEventTouchUpInside];
    view.rightCalloutAccessoryView = b;
#endif
    
    return view;
    
}
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *_circleView=[[MKCircleView alloc] initWithCircle:overlay];
        _circleView.fillColor =  [UIColor colorWithRed:137/255.0 green:170/255.0 blue:213/255.0 alpha:0.2];
        _circleView.strokeColor = [UIColor colorWithRed:117/255.0 green:161/255.0 blue:220/255.0 alpha:0.8];
        _circleView.lineWidth=2.0;
        return _circleView;
    }
    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
