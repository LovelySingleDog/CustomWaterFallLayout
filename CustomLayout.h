//
//  CustomLayout.h
//  CollectionLayoutPractice
//
//  Created by wyzc03 on 16/12/4.
//  Copyright © 2016年 wyzc03. All rights reserved.
//









#import <UIKit/UIKit.h>
//注册区头区尾用到的字符串
extern NSString * const collectionViewHeader;
extern NSString * const collectionViewFooter;

@interface CustomLayout : UICollectionViewLayout
//区和区之间的布局情况
@property (nonatomic,assign) UIEdgeInsets sectionInsets;//默认是UIEdgeInsetsZero
//item 行间距
@property (nonatomic,assign) CGFloat lineSpace;//默认是0
//列间距
@property (nonatomic,assign) CGFloat InteritemSpace;//默认是0
//列数
@property (nonatomic,assign) NSInteger lineNumber;//默认是3
//item尺寸 根据lineNumber,InteritemSpace等参数平均分配width,只需要返回item的高度
@property (nonatomic,copy) CGFloat (^itemSize)(NSIndexPath * indexPath,CGFloat width);


//区头尺寸
//设置统一的区头高度 (区头宽度不起作用)
@property (nonatomic,assign) CGSize sectionHeaderSize;
//根据indexPath选择是否有区头//如果上下两个同事设置 以block的区头高度为准
@property (nonatomic,copy) CGSize (^sectionHeaderSizeBlock)(NSIndexPath * indexPath);

//区尾尺寸
@property (nonatomic,assign) CGSize sectionFooterSize;
@property (nonatomic,copy) CGSize (^sectionFooterSizeBlock)(NSIndexPath * indexPath);
@end

