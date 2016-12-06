//
//  CustomLayout.m
//  CollectionLayoutPractice
//
//  Created by wyzc03 on 16/12/4.
//  Copyright © 2016年 wyzc03. All rights reserved.
//

#import "CustomLayout.h"
NSString * const collectionViewHeader = @"collectionViewHeader";
NSString * const collectionViewFooter = @"collectionViewFooter";
@interface CustomLayout ()
//用于布局的属性
//用于计算collectionViewContentSize的尺寸
@property (nonatomic,assign) CGSize contentSize;
//存放布局信息的数组
@property (nonatomic,strong) NSMutableArray * attrubutesArr;

//存放每区的item的纵坐标的字典的数组(为每区的item做准备)
@property (nonatomic,strong) NSMutableArray * itemYArr;
//记录每个区item的最大Y(为区头位置坐准备)
@property (nonatomic,assign) CGFloat maxY;
@end

@implementation CustomLayout
//初始化属性
- (instancetype)init{
    if (self = [super init]) {
        self.sectionInsets = UIEdgeInsetsZero;
        self.lineSpace = 0;
        self.lineNumber = 3;
        self.InteritemSpace = 0;
        self.sectionHeaderSize = CGSizeZero;
        self.sectionFooterSize = CGSizeZero;

    }
    return self;
}


//准备布局信息
- (void)prepareLayout{
    [super prepareLayout];
    //初始化用于布局的数据
    self.attrubutesArr = [NSMutableArray array];
    self.itemYArr = [NSMutableArray array];
    self.maxY = 0;
    //计算collectionViewContentSize的高度
    CGFloat contentSizeHeight = 0;
    //获得区的个数
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    for (int section = 0; section < numberOfSections; section ++) {
        //每个区的item个数
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        //存放每区的布局信息
        NSMutableArray *subArr = [NSMutableArray arrayWithCapacity:numberOfItems + 1];
        //将区头布局信息添加到数组中
        UICollectionViewLayoutAttributes * sectionHeaderLayoutAtt = [self layoutAttributesForSupplementaryViewOfKind:collectionViewHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        [subArr addObject:sectionHeaderLayoutAtt];
        //记录每区item的y
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        //将字典存储起来
        [self.itemYArr addObject:dic];
        //将每区的item加入到数组中
        for (int item = 0; item < numberOfItems; item ++) {
            //给字典赋值
            [dic setValue:@(CGRectGetMaxY(sectionHeaderLayoutAtt.frame) + self.lineSpace) forKey:[NSString stringWithFormat:@"%d",item]];
            
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes * attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [subArr addObject:attributes];
        }
        //将区尾加入到布局属性中
        UICollectionViewLayoutAttributes * sectionFooterLayoutAtt = [self layoutAttributesForSupplementaryViewOfKind:collectionViewFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        [subArr addObject:sectionFooterLayoutAtt];
        //将每个区的布局属性加入到总的数组中
        [self.attrubutesArr addObject:subArr];
        //寻找区尾的frame的Y的最大值
        if (section == numberOfSections - 1) {
            CGFloat NewContentSizeHeight = CGRectGetMaxY(sectionFooterLayoutAtt.frame);
            if (contentSizeHeight < NewContentSizeHeight) {
                contentSizeHeight = NewContentSizeHeight;
            }
        }
    }
    //计算内容区域(collectionViewContentSize)的尺寸
    UIEdgeInsets edgeInsets = self.collectionView.contentInset;
    
    self.contentSize = CGSizeMake(self.collectionView.frame.size.width - edgeInsets.left - edgeInsets.right, contentSizeHeight + _sectionInsets.bottom);
    
    //self.contentSize = CGSizeMake(self.collectionView.frame.size.width, contentSizeHeight + _sectionInsets.bottom);
    
    
}
//返回的是整体的尺寸(相当于collectionView的contnetSize)
- (CGSize)collectionViewContentSize{
    return _contentSize;
}


- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    //存放屏幕显示出来的布局信息
    NSMutableArray * array = [NSMutableArray array];
    for (NSMutableArray * arr in self.attrubutesArr) {
        for (UICollectionViewLayoutAttributes * attributes in arr) {
            if (CGRectIntersectsRect(attributes.frame, rect)) {
                [array addObject:attributes];
            }
        }
    }
    
    return array;
}

//返回每个item的布局信息
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes * attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    UIEdgeInsets edgeInsets = self.collectionView.contentInset;
    //计算item宽
    CGFloat itemW = (self.collectionView.bounds.size.width - (edgeInsets.left + edgeInsets.right) - (self.sectionInsets.left + self.sectionInsets.right) - (self.lineNumber - 1) * self.InteritemSpace) / self.lineNumber;
    
    //item的高度
    CGFloat itemH = 0;
    if (_itemSize != nil) {
        itemH = self.itemSize(indexPath,itemW);
    }else{
        NSAssert(itemH != 0, @"没有实现itemSize的block");
    }
    
    CGFloat orignX = 0;
    CGFloat orignY = 0;
    
    //拿到当前行的当前dic对应的Key
    NSString * item = [NSString stringWithFormat:@"%ld",indexPath.item % self.lineNumber];
   
    //拿到当前item的下标
    NSInteger index = indexPath.item % self.lineNumber;
    
    //拿到当前的Y的位置信息
    CGFloat y = [self.itemYArr[indexPath.section][item] floatValue];
    
    orignX =  self.sectionInsets.left + index * (itemW + self.InteritemSpace);
    
    orignY = y;
    
    //更新Y的位置信息为下一行做准备
    [self.itemYArr[indexPath.section] setValue:@(y + itemH + self.lineSpace) forKey:item];
    attributes.frame = CGRectMake(orignX, orignY, itemW, itemH);
    
    //寻找每个区的最远的位置用于布局区头
    CGFloat MY = CGRectGetMaxY(attributes.frame);
    if (self.maxY < MY) {
        self.maxY = MY;
    }
    return attributes;
}
//区头区尾布局信息
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes * sectionHeaderOrFooter = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    
    
    UIEdgeInsets edgeInsets = self.collectionView.contentInset;
    
    //设置区头尺寸
    if ([elementKind isEqualToString:collectionViewHeader]) {
        CGFloat height = self.sectionHeaderSize.height;
        if (self.sectionHeaderSizeBlock != nil) {
            height = self.sectionHeaderSizeBlock(indexPath).height;
        }
        
        sectionHeaderOrFooter.frame = CGRectMake(self.sectionInsets.left, _maxY + self.sectionInsets.top, self.collectionView.bounds.size.width - self.sectionInsets.left - self.sectionInsets.right - edgeInsets.left - edgeInsets.right, height);
    }else if([elementKind isEqualToString:collectionViewFooter]){
        //设置区尾尺寸
        CGFloat height = self.sectionFooterSize.height;
        if (self.sectionFooterSizeBlock != nil) {
            height = self.sectionFooterSizeBlock(indexPath).height;
        }
        sectionHeaderOrFooter.frame = CGRectMake(self.sectionInsets.left, _maxY + self.lineSpace, self.collectionView.bounds.size.width - self.sectionInsets.left - self.sectionInsets.right - edgeInsets.left - edgeInsets.right, height);
        //更新maxY 为下一区的区头做准备
        _maxY = CGRectGetMaxY(sectionHeaderOrFooter.frame) + self.sectionInsets.bottom + self.sectionInsets.top;
    }else {
        
    }
    return sectionHeaderOrFooter;
}
//滑动的时候不从新开始 布局视图
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return NO;
}

@end
