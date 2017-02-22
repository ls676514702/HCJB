//
//  HCWebView.m
//  HCJB
//
//  Created by 互传 on 2017/2/21.
//  Copyright © 2017年 互传. All rights reserved.
//

#import "HCWebView.h"

@implementation HCWebView
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
+ (instancetype)loadWebView:(UIView *)backView{
    HCWebView *_wkWebview = [[self alloc] initWithFrame:backView.bounds];
    _wkWebview.backgroundColor = [UIColor whiteColor];
    NSURL *url = [NSURL URLWithString:@"http://110.huchuan6.com/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_wkWebview loadRequest:request];
    return _wkWebview;
}
@end
