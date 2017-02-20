//
//  XGTestViewController.m
//  SCTouchDemo
//
//  Created by 小广 on 2017/1/19.
//  Copyright © 2017年 小广. All rights reserved.
//

#import "XGTestViewController.h"
#import "SCSearchView.h"

@interface XGTestViewController ()
@property (nonatomic, strong) SCSearchView  *searchView;
@end

@implementation XGTestViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"init========");
    }
    return self;
}

- (void)loadView {
    [super loadView];
    NSLog(@"loadView========");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad========");
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)setupUI {
    self.searchView = [SCSearchView loadNibView];
    self.searchView.frame = CGRectMake(0.0, 0.0, ScreenWidth, 44.0f);
//    self.searchView.searchType = SCSearchTypeAddress;
    self.searchView.searchTypeString = @"身份证号";
    self.searchView.showScan = YES;
    self.searchView.searchType = SCSearchTypeNormal;
    [self.searchView searchBarAction:^(UIButton *button, SCButtonType buttonType) {
        NSLog(@"按钮点击的tag是==%zd==", buttonType);
        [self.view endEditing:YES];
        self.searchView.searchType = SCSearchTypeScan;
        self.searchView.searchTypeString = @"业主房号";
        self.searchView.searchText = @"";
    }];
    
    [self.searchView gainSearchText:^(NSString *text) {
        NSLog(@"搜索到的内容是==%@==", text);
        [self.view endEditing:YES];
    }];
    [self.view addSubview:self.searchView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
SharkORM使用个人小结
SharkORM地址 https://github.com/sharksync/sharkorm
1. AppDelegate配置一下
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
 // 设置代理
 [SharkORM setDelegate:self];
 // myDatabase 数据库名字
 [SharkORM openDatabaseNamed:@"myDatabase"];
 return YES;
 }
2.SharkORM的model的建立
 
 #import "SharkORM.h"
 @interface Person : SRKObject
 
 @property NSString*         name;
 @property int               age;
 @property int               payrollNumber;
 
 // to create a relationship, you add a property as another SRKObject class
 // 有依赖关系的属性object，也必须是SRKObject类型的
 @property Department*       department;
 
 @end
 
 // Source File : Person.m
 // .m必须使用@dynamic，后面修饰各个属性值
 #import "Person.h"
 
 @implementation Person
 
 @dynamic name,age,payrollNumber, department;
 
 @end
 
*/

@end
