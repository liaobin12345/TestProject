//
//  MyAnnotation.m
//  MapDemo
//
//  Created by mac on 14-8-21.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

- (NSString *)title
{
    return _title;
}
- (NSString *)subtitle
{
    return _subtitle;
}
- (CLLocationCoordinate2D)coordinate
{
    return _coordinate2D;
}

// 没有setter 通过重构构造函数修改3个属性的值
- (id)initWithCoordinate:(CLLocationCoordinate2D)tempCoordinate withTitle:(NSString *)tempTitle withSubtitle:(NSString *)tempSubtitle
{
    self = [super init];
    if (self) {
        _title = tempTitle;
        _subtitle = tempSubtitle;
        _coordinate2D = tempCoordinate;
    }
    return self;
}
@end
