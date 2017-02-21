//
//  HCNotiView.m
//  HCJB
//
//  Created by 互传 on 2017/2/20.
//  Copyright © 2017年 互传. All rights reserved.
//

#import "HCNotiView.h"

@implementation HCNotiView

+ (instancetype)loadNotiView{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([HCNotiView class]) owner:nil options:nil] lastObject];
}

@end
