//
//  ViewController.m
//  Test
//
//  Created by 刘少鹏 on 2017/12/11.
//  Copyright © 2017年 刘少鹏. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>



@interface ViewController ()

@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation ViewController

#pragma mark - 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextBtn.backgroundColor = [UIColor blueColor];
    [self.nextBtn setTitle:@"导航" forState:UIControlStateNormal];
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(nextBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(120, 50));
    }];
    
}
#pragma mark - 按钮点击事件
- (void)nextBtnAction:(UIButton *)sender {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"导航将会跳转到第三方App" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *amap = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jumpToAmap];
    }];
    UIAlertAction *baidu = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jumpToBaiduMap];
    }];
    UIAlertAction *appleMap = [UIAlertAction actionWithTitle:@"Apple地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jumpToAppleMap];
    }];
    
    [alertVC addAction:cancel];
    [alertVC addAction:amap];
    [alertVC addAction:baidu];
    [alertVC addAction:appleMap];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}
#pragma mark - 跳转到高德地图
/*
 sourceApplication=%@&backScheme=%@
 sourceApplication代表你自己APP的名称，会在之后跳回的时候显示出来，所以必须填写。backScheme是你APP的URL Scheme，不填是跳不回来的
 dev=0
 这里填0就行了，跟百度地图的gcj02一个意思 ，1代表wgs84， 也用不上。
 */
- (void)jumpToAmap {
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]){
        //地理编码器
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        //我们假定一个终点坐标，上海嘉定伊宁路2000号报名大厅:121.229296,31.336956
        [geocoder geocodeAddressString:@"上海嘉定区伊宁路2000号" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            for (CLPlacemark *placemark in placemarks){
                //坐标（经纬度)
                CLLocationCoordinate2D coordinate = placemark.location.coordinate;
                NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",@"导航",@"AmapScheme",coordinate.latitude, coordinate.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@NO} completionHandler:nil];
            }
        }];
    }else{
        NSLog(@"您的iPhone未安装高德地图，请进行安装！");
    }
}
#pragma mark - 跳转到百度地图
/*
 1，origin={{我的位置}}, 这个是不能被修改的，不然无法把出发位置设置为当前位置
 2，destination = latlng:%f,%f|name = 目的地
 这里面的 name 的字段不能省略，否则导航会失败，而后面的文字则可以随意
 3，coord_type = gcj02
 coord_type 允许的值为 bd09ll、gcj02、wgs84，如果你 APP 的地图 SDK 用的是百度地图 SDK，请填 bd09ll，否则就填gcj02，wgs84的话基本是用不上了（需要涉及到地图加密）
 */
- (void)jumpToBaiduMap {
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]){
        //地理编码器
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        //我们假定一个终点坐标，上海嘉定伊宁路2000号报名大厅:121.229296,31.336956
        [geocoder geocodeAddressString:@"上海嘉定区伊宁路2000号" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            for (CLPlacemark *placemark in placemarks){
                //坐标（经纬度)
                CLLocationCoordinate2D coordinate = placemark.location.coordinate;
                NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",coordinate.latitude, coordinate.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @NO} completionHandler:nil];
            }
        }];
    }else{
        //添加提示
        NSLog(@"您的iPhone未安装百度地图，请进行安装！");
    }
}
#pragma mark - 跳转到苹果地图
- (void)jumpToAppleMap {
    
    //这个判断其实是不需要的
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]){
        //MKMapItem 使用场景: 1. 跳转原生地图 2.计算线路
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        
        //地理编码器
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        //我们假定一个终点坐标，上海嘉定伊宁路2000号报名大厅:121.229296,31.336956
        [geocoder geocodeAddressString:@"上海嘉定伊宁路2000号" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            CLPlacemark *endPlacemark  = placemarks.lastObject;
            
            //创建一个地图的地标对象
            MKPlacemark *endMKPlacemark = [[MKPlacemark alloc] initWithPlacemark:endPlacemark];
            //在地图上标注一个点(终点)
            MKMapItem *endMapItem = [[MKMapItem alloc] initWithPlacemark:endMKPlacemark];
            
            //MKLaunchOptionsDirectionsModeKey 指定导航模式
            //NSString * const MKLaunchOptionsDirectionsModeDriving; 驾车
            //NSString * const MKLaunchOptionsDirectionsModeWalking; 步行
            //NSString * const MKLaunchOptionsDirectionsModeTransit; 公交
            [MKMapItem openMapsWithItems:@[currentLocation, endMapItem]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
            
        }];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
