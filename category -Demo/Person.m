//
//  Person.m
//  category -Demo
//
//  Created by 郭彬 on 16/6/30.
//  Copyright © 2016年 walker. All rights reserved.
//

#import "Person.h"

@interface Person ()

@property(nonatomic,copy)NSString *personPrivateName;

@end


@implementation Person

- (void)eat {
    NSLog(@"%@",self);
}

@end
