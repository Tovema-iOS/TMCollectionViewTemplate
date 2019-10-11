//
//  TMViewController.m
//  TMCollectionViewTemplate
//
//  Created by lxb_0605@qq.com on 10/11/2019.
//  Copyright (c) 2019 lxb_0605@qq.com. All rights reserved.
//

#import "TMViewController.h"
#import "TestCollectionViewController.h"

@interface TMViewController ()

@end

@implementation TMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if 1
#warning 测试
    self.autoClickIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
#endif
}

- (NSArray<TestSection*> *)createSections {
    NSMutableArray<TestSection *> *sections = [NSMutableArray array];
    
    [sections addObject:[self createTestSection]];
    
    return sections;
}

- (TestSection *)createTestSection {
    NSMutableArray<TestCell *> *array = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [array addObject:[TestCell cellWithTitle:@"Test" operation:[NSBlockOperation blockOperationWithBlock:^{
        TestCollectionViewController *ctrl = [[TestCollectionViewController alloc] init];
        [weakSelf.navigationController pushViewController:ctrl animated:YES];
    }]]];
    
    return [TestSection sectionWithTitle:@"Test" items:array];
}

@end
