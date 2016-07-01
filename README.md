# CategoryAndExtension--Demo

#不信你不会—分类,匿名分类,类扩展究竟是什么鬼

## 背景：

在大型项目，企业级开发中多人同时维护同一个类，此时程序员A因为某项需求只想给当前类`currentClass`添加一个方法`newMethod`，那该怎么办呢？
最简单粗暴的方式是把`newMethod`添加到`currentClass`中，然后直接实现该方法就OK了。
但考虑到OC是单继承的，子类可以拥有父类的方法和属性。
如果把`newMethod`写到`currentClass`中，那么`currentClass`的子类也会拥有`newMethod`。但真正的需求是只需要`currentClass`拥有`newMethod`，而`currentClass`的子类不会拥有。
苹果为了解决这个问题，就引入了分类（Category）的概念。

## 分类（Category）：
### 概念
分类（Category）是OC中的特有语法，它是表示一个指向分类的结构体的指针。原则上它只能增加方法，不能增加成员（实例）变量。具体原因看源码组成:
### Category源码：
```
Category
Category 是表示一个指向分类的结构体的指针，其定义如下：
typedef struct objc_category *Category;
struct objc_category {
  char *category_name                          OBJC2_UNAVAILABLE; // 分类名
  char *class_name                             OBJC2_UNAVAILABLE; // 分类所属的类名
  struct objc_method_list *instance_methods    OBJC2_UNAVAILABLE; // 实例方法列表
  struct objc_method_list *class_methods       OBJC2_UNAVAILABLE; // 类方法列表
  struct objc_protocol_list *protocols         OBJC2_UNAVAILABLE; // 分类所实现的协议列表
}
```

```
通过上面我们可以发现，这个结构体主要包含了分类定义的实例方法与类方法，其中instance_methods 列表是 objc_class 中方法列表的一个子集，而class_methods列表是元类方法列表的一个子集。
但这个结构体里面

根本没有属性列表，
根本没有属性列表，
根本没有属性列表。
```

>**注意**：
>1.分类是用于给原有类添加方法的,因为分类的结构体指针中，没有属性列表，只有方法列表。所以< **原则上讲它只能添加方法, 不能添加属性(成员变量),实际上可以通过其它方式添加属性**> ;
>2.分类中的可以写@property, 但不会生成`setter/getter`方法, 也不会生成实现以及私有的成员变量（编译时会报警告）;
>3.可以在分类中访问原有类中.h中的属性;
>4.如果分类中有和原有类同名的方法, 会优先调用分类中的方法, 就是说会忽略原有类的方法。所以同名方法调用的优先级为 `分类 > 本类 > 父类`。因此在开发中尽量不要覆盖原有类;
>5.如果多个分类中都有和原有类中同名的方法, 那么调用该方法的时候执行谁由编译器决定；编译器会执行最后一个参与编译的分类中的方法。

### 分类格式：

```
@interface 待扩展的类（分类的名称）
@end

@implementation 待扩展的名称（分类的名称）
@end

```

### 实际代码如下：

```
//  Programmer+Category.h文件中
@interface Programmer (Category)

@property(nonatomic,copy) NSString *nameWithSetterGetter;           //设置setter/getter方法的属性

@property(nonatomic,copy) NSString *nameWithoutSetterGetter;        //不设置setter/getter方法的属性（注意是可以写在这，而且编译只会报警告，运行不报错）

- (void) programCategoryMethod;                                     //分类方法

@end

//  Programmer+Category.m文件中

```

**那么问题来了：**
> 为什么在分类中声明属性时，运行不会出错呢？
> 既然分类不让添加属性，那为什么我写了@property仍然还以编译通过呢？

 **接下来我们探究下分类不能添加属性的实质原因：**
>我们知道在一个类中用@property声明属性，编译器会自动帮我们生成`_成员变量`和`setter/getter`，但分类的指针结构体中，根本没有属性列表。所以在分类中用@property声明属性，既无法生成`_成员变量`也无法生成`setter/getter`。
因此结论是：我们可以用@property声明属性，编译和运行都会通过，只要不使用程序也不会崩溃。但如果调用了`_成员变量`和`setter/getter`方法，报错就在所难免了。

--------

> **报错原因如下**

```
//普通声明，无setter/getter
//    programmer.nameWithoutSetterGetter = @"无setter/getter";    //调用setter，编译成功，运行报错为：（-[Programmer setNameWithSetterGetter:]: unrecognized selector sent to instance 0x7f9de358fd70'）
    
//    NSLog(@"%@",programmer.nameWithoutSetterGetter);           //调用getter，编译成功，运行报错为-[Programmer setNameWithSetterGetter:]: unrecognized selector sent to instance 0x7fe22be11ea0'

//    NSLog(@"%@",_nameWithoutSetterGetter);        //这是调用_成员变量,错误提示为：（Use of undeclared identifier '_nameWithoutSetterGetter'）
```

那接下来我们继续思考:
既然报错的根本原因是使用了系统没有生成的`setter/getter`方法，可不可以在手动添加`setter/getter`来避免崩溃，完成调用呢？
其实是可以的。由于OC是动态语言，方法真正的实现是通过`runtime`完成的，虽然系统不给我们生成`setter/getter`，但我们可以通过`runtime`手动添加`setter/getter`方法。那具体怎么实现呢？

### 代码实现如下:
按照这个思路，我们通过运行时手动添加这个方法。

```  
#import <objc/runtime.h>

static NSString *nameWithSetterGetterKey = @"nameWithSetterGetterKey";   //定义一个key值
@implementation Programmer (Category)

//运行时实现setter方法
- (void)setNameWithSetterGetter:(NSString *)nameWithSetterGetter {
        objc_setAssociatedObject(self, &nameWithSetterGetterKey, nameWithSetterGetter, OBJC_ASSOCIATION_COPY);
}

//运行时实现getter方法
- (NSString *)nameWithSetterGetter {
    return objc_getAssociatedObject(self, &nameWithSetterGetterKey);
}

@end

```
### 实际使用效果
```
//通过runtime实现了setter/getter
    programmer.nameWithSetterGetter = @"有setter/getter";    //调用setter，成功
    NSLog(@"%@",programmer.nameWithSetterGetter);            //调用getter，成功
//    NSLog(@"%@",_nameWithSetterGetter); //这是调用_成员变量，错误提示为：（Use of undeclared identifier '_nameWithSetterGetter'）

```
**问题解决。**
>**但是注意，以上代码仅仅是手动实现了****`setter/getter`****方法，但调用****`_****成员变量****`****依然报错。*********


 


## 类扩展（Class Extension）

Extension是Category的一个特例。类扩展与分类相比只少了分类的名称，所以称之为“匿名分类”。
其实开发当中，我们几乎天天在使用。对于有些人来说像是最熟悉的陌生人。

### 类扩展格式：

```
@interface XXX ()
//私有属性
//私有方法（如果不实现，编译时会报警,Method definition for 'XXX' not found）
@end
```

### 作用： 
> 为一个类添加额外的原来没有变量，方法和属性
> 一般的类扩展写到`.m`文件中
> 一般的私有属性写到`.m`文件中的类扩展中
 
-------

## 类别与类扩展的区别：
>①类别中原则上只能增加方法（能添加属性的的原因只是通过`runtime`解决无`setter/getter`的问题而已）；
>②类扩展不仅可以增加方法，还可以增加实例变量（或者属性），只是该实例变量默认是@private类型的（
>用范围只能在自身类，而不是子类或其他地方）；
>③类扩展中声明的方法没被实现，编译器会报警，但是类别中的方法没被实现编译器是不会有任何警告的。这是因为**类扩展是在编译阶段被添加到类中，而类别是在运行时添加到类中**。
>④类扩展不能像类别那样拥有独立的实现部分（@implementation部分），也就是说，类扩展所声明的方法必须依托对应类的实现部分来实现。
>⑤定义在 .m 文件中的类扩展方法为私有的，定义在 .h 文件（头文件）中的类扩展方法为公有的。类扩展是在 .m 文件中声明私有方法的非常好的方式。

##[Demo地址](https://github.com/walkertop/CategoryAndExtension--Demo)

## 最后总结：
关于分类，类扩展等问题，在很多概念性的东西网上讲解的很是模糊，而且在实际应用的背后的原理上也少有展开。作者写这篇文章的目的就是想让读者对分类，类扩展等常见的问题有个清晰的认识，免了看了记不住，记住又记不对，记对了又不明白原因。
在实际开发中，很多工具类都是分类，类扩展的实际应用，所以笔者后续会在我的个人GitHub上放出工具类，欢迎start和follow。
文章是本人通过实际代码和自己的开发经验整理而成，如果你喜欢我的文章，欢迎喜欢和打赏。技术的进步成长需要交流碰撞，也期待你的留言评论，不要只做一个MARK党。







