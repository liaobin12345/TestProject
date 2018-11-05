//
//  MyAnnotation.h
//  MapDemo
//
//  Created by mac on 14-8-21.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D _coordinate2D;
    NSString *_title;
    NSString *_subtitle;
}

// 3个属性的getter
- (NSString *)title;
- (NSString *)subtitle;
- (CLLocationCoordinate2D)coordinate;
// 没有setter 通过重构构造函数修改3个属性的值
- (id)initWithCoordinate:(CLLocationCoordinate2D)tempCoordinate withTitle:(NSString *)tempTitle withSubtitle:(NSString *)tempSubtitle;

@end
