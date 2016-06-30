//
//  ViewController.m
//  category -Demo
//
//  Created by 郭彬 on 16/6/30.
//  Copyright © 2016年 walker. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Programmer.h"
#import "Programmer+Category.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Person *p = [[Person alloc]init];
    p.personPublicName = @"Person的publicName";

    Programmer *programmer = [[Programmer alloc]init];
    
    //通过runtime实现了setter/getter
    programmer.nameWithSetterGetter = @"有setter/getter";    //调用setter，成功
    NSLog(@"%@",programmer.nameWithSetterGetter);            //调用getter，成功
    
//    NSLog(@"%@",_nameWithSetterGetter); //这是调用_成员变量，错误提示为：（Use of undeclared identifier '_nameWithSetterGetter'）

    
    //普通声明，无setter/getter
//    programmer.nameWithoutSetterGetter = @"无setter/getter";    //调用setter，编译成功，运行报错为：（-[Programmer setNameWithSetterGetter:]: unrecognized selector sent to instance 0x7f9de358fd70'）
    
//    NSLog(@"%@",programmer.nameWithoutSetterGetter);   //调用getter，编译成功，运行报错为-[Programmer setNameWithSetterGetter:]: unrecognized selector sent to instance 0x7fe22be11ea0'

//    NSLog(@"%@",_nameWithoutSetterGetter);    //这是调用_成员变量
//    NSLog(@"%@",_nameWithSetterGetter);

    
//    分类的方法实现
    [programmer programCategoryMethod];

}


@end
