//
//  ViewController.m
//  TestRuntime
//
//  Created by malong on 15/4/26.
//  Copyright (c) 2015年 SanFenXian. All rights reserved.
//

#import "ViewController.h"
#import "TestClass.h"
#import <objc/runtime.h>
//#import <objc/message.h>
@import AVFoundation;
@import MediaPlayer;
@interface ViewController ()
{
    float  myFloat;

}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self Objc];
//    [self addMethodToClass];
    [self getInstanceVar];
//    [self getVarType];
//    [self exchangeMethod];
//    [self methodSetImplementation];
//    [self replaceMethod];
//    [self addNewClass];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 1、更改对象的类／获取对象的类
- (void)Objc{
    UILabel * label = [UILabel new];
    //获取类名
    NSString * className = [NSString stringWithUTF8String:object_getClassName(label)];
    NSLog(@"className = %@",className);

    //根据类名获取类
   Class objClass = objc_getClass(object_getClassName(label));
    NSLog(@"objClass = %@",objClass);
    
    //根据类的实例获取类
    Class aClass = object_getClass(label);
    NSLog(@"aClass = %@",aClass);
    //更改对象的类
    Class bClass = object_setClass(label, [UIImageView class]);
    NSLog(@"bClass = %@",bClass);
    NSLog(@"lebel = %@",label);

    
}

-(void) printddd:(NSString *)str {
    NSLog(@"%@", str);
}

#pragma mark 2、给类添加方法
- (void)addMethodToClass{
    
    
    //添加方法
    class_addMethod([TestClass class], @selector(sayHello2), (IMP)sayHello, "v@:");
    //添加只有一个参数的方法
    class_addMethod([TestClass class], @selector(ocMethod:), (IMP)cFunction, "v@:@");

    //添加有两个参数的方法
    class_addMethod([TestClass class], @selector(twoMethod::), (IMP) twoFunction, "i@:@@");

    //验证
    TestClass * testInstance = [[TestClass alloc] init];
    [testInstance performSelector:@selector(sayHello2) withObject:nil];
    

    
    int a = (int)[testInstance performSelector:@selector(ocMethod:) withObject:@"我是一个OC的method，C函数实现"];
    SEL ddd = NSSelectorFromString(@"printddd:");
    objc_msgSend(self, ddd, @"dddd");
    
//    int b = (int)[testInstance performSelector:@selector(twoMethod::) withObject:@"第一个参数" withObject:@"第二个参数"];
//    [self getAllClassMethod];

//    [self getAllProperties];
    
}

//无返回值，无参数
void sayHello(id self, SEL _cmd){
    NSLog(@"hello");
}

//int 返回值，一个参数
int cFunction(id self, SEL _cmd, NSString * str){
    
    NSLog(@"str = %@",str);
    
    return 10;
    
}

//int 返回值，两个参数

int twoFunction(id self, SEL _cmd, NSString * str1, NSString * str2){
    NSLog(@"str1 = %@ \n str2 = %@",str1, str2);
    return 20;
}

#pragma mark 3、获取一个类的所有方法

#pragma mark .cxx_destruct 编译器插入的释放实例变量的方法
- (void)getAllClassMethod
{
    unsigned methodCount;
    
    Method * classMethods = class_copyMethodList([TestClass class], &methodCount);
    
    for (int i = 0; i < methodCount; i++) {
        SEL methodName = method_getName(classMethods[i]);
        
        NSString * strName = [NSString stringWithUTF8String:sel_getName(methodName)];
        NSLog(@"strName %d = %@",i,strName);
    }
    
}

#pragma mark 4、获取一个类的所有属性
- (void)getAllProperties{
    unsigned propertyCount;
    
    objc_property_t * properties = class_copyPropertyList([TestClass class], &propertyCount);
    
    for (int i = 0; i<propertyCount; i++) {
        objc_property_t property = properties[i];
        const char * propertyName = property_getName(property);
        
        NSString * strProperty = [NSString stringWithUTF8String:propertyName];
        
        NSLog(@"strProperty %d = %@",i,strProperty);
        
    }
    
}


#pragma mark 5、获取／设置类的属性变量

- (void)getInstanceVar
{
    Ivar myfloat = class_getInstanceVariable(object_getClass(self), "myFloat");
    object_getIvar(self, myfloat);
    
    float newValue = 10.0;
    
    unsigned int addr = (unsigned int)&newValue;
    
    object_setIvar(self, myfloat,@"10");
    
    
    NSLog(@"object_getIvar(self, myfloat) = %@",object_getIvar(self, myfloat));
    NSLog(@"myfloat = %f",myFloat);

}

#pragma mark 6、获取某个属性的类型
- (void)getVarType
{
    TestClass * obj = [TestClass new];
    Ivar ivar = class_getInstanceVariable(object_getClass(obj), "varTest1");
    
    const char * varTypeEncoding = ivar_getTypeEncoding(ivar);
    
    NSString * stringType = [NSString stringWithUTF8String:varTypeEncoding];
    NSLog(@"stringType = %@",stringType);

    
    if ([stringType hasPrefix:@"@"]) {
        NSLog(@"class type");
    }else if ([stringType hasPrefix:@"f"]){
        NSLog(@"float type");
    }else if ([stringType hasPrefix:@"i"]){
        NSLog(@"int type");
    }
}

#pragma mark 7、通过属性的值来获取其属性的名字（反射机制）

- (NSString *)nameOfInstance:(id)instance
{
    unsigned int ivarNumbers = 0;
    NSString * key = nil;
    
    Ivar * ivars = class_copyIvarList(object_getClass(self), &ivarNumbers);
    
    for (int i = 0; i<ivarNumbers; i++) {
        Ivar thisIvar = ivars[i];
        
        const char * typeEncoding = ivar_getTypeEncoding(thisIvar);
        NSString * stringType = [NSString stringWithUTF8String:typeEncoding];
        
        if (![stringType hasPrefix:@"@"]) {
            continue;
        }
        
        if (object_getIvar(self, thisIvar) == instance) {
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}

#pragma mark 8、系统类的方法实现部分替换

- (void)exchangeMethod{
    
    //这儿如果类中没有替换的两个方法，则替换方法失效，但不会crash
    Method m1 = class_getInstanceMethod([NSString class], @selector(lowercaseString));
    Method m2 = class_getInstanceMethod([NSString class], @selector(uppercaseString));
    
    method_exchangeImplementations(m1, m2);
    
    NSLog(@"lower = %@",[@"aaAAaa" lowercaseString]);
    NSLog(@"upper = %@",[@"aaAAaa" uppercaseString]);

}

#pragma mark 9、自定义类的方法实现部分替换

- (void)testFun1{
    NSLog(@"testFun1");
    
}

- (void)testFun2{
    NSLog(@"testFun2");
    
}

- (void)methodSetImplementation
{
    Method m1 = class_getInstanceMethod(object_getClass(self), @selector(testFun1));
    IMP imp1 = method_getImplementation(m1);
    
    Method m2 = class_getInstanceMethod(object_getClass(self), @selector(testFun2));
    
    
    method_setImplementation(m2, imp1);
    
    [self testFun2];
}

#pragma mark 10、覆盖系统方法
IMP cFuncPointer;

NSString * customUppercaseString(id self, SEL _cmd){
    NSLog(@"customUppercaseString");
    return @"customUppercaseString";
}

NSArray * CustomComponentsSeparatedByString(id self, SEL _cmd, NSString * str){
    NSLog(@"CustomComponentsSeparatedByString = %@",str);
    return @[@"CustomComponentsSeparatedByString"];
}

bool CustomIsEqualToString(id self,SEL _cmd,NSString * str){
    printf("真正起作用的是本函数CustomIsEqualToString\r\n");
    return NO;
}

- (void)replaceMethod
{
    class_replaceMethod([NSString class], @selector(uppercaseString), (IMP)customUppercaseString, "@@:");
    class_replaceMethod([NSString class], @selector(componentsSeparatedByString:), (IMP)CustomComponentsSeparatedByString, "@@:@");
    class_replaceMethod([NSString class], @selector(isEqualToString:), (IMP)CustomIsEqualToString, "b@:@");
    
    NSString * testString = @"aaBBcc";
    [testString uppercaseString];
    
    [testString componentsSeparatedByString:@"BB"];
    
    [testString isEqualToString:@"dd"];

}

#pragma mark 11、添加新类

void ReportFunction(id self , SEL _cmd)
{
    NSLog(@"tReportFunction");
    
    
    
}


- (void)addNewClass
{
    Class newClass = objc_allocateClassPair([NSString class], "NSStringSubClass", 0);
    class_addMethod(newClass, @selector(report), (IMP)ReportFunction, "v@:");
   BOOL isOk = class_addIvar(newClass, "name", sizeof(id), log2(sizeof(id)), "@");
    objc_registerClassPair(newClass);

    Ivar ivar = class_getInstanceVariable(newClass, "name");

    id instanceOfNewClass = [[newClass alloc]init];
    [instanceOfNewClass performSelector:@selector(report) withObject:nil];
    object_setIvar(instanceOfNewClass, ivar, @"nameValue");
    
    id nameValue = object_getIvar(instanceOfNewClass, ivar);
    
}


@end
