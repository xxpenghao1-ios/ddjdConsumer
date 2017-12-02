//
//  UICollectionViewFlowLayout.swift
//  ddjdConsumer
//
//  Created by hao peng on 2017/9/12.
//  Copyright © 2017年 zltx. All rights reserved.
//

import Foundation
import UIKit
protocol WaterFlowViewLayoutDelegate:NSObjectProtocol
{
    //collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
    ///width是瀑布流每列的宽度
    func waterFlowViewLayout(waterFlowViewLayout:WaterFlowViewLayout,heightForWidth:CGFloat,atIndextPath:IndexPath)->CGFloat
}
class WaterFlowViewLayout: UICollectionViewLayout {
    
    weak var delegate:WaterFlowViewLayoutDelegate?
    
    ///所有cell的布局属性
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    ///使用一个字典记录每列的最大Y值
    var maxYDict = [Int:CGFloat]()
    /// 传入边距宽度(默认1)
    var margin:CGFloat=1
    
    ///瀑布流四周的间距
    var sectionInsert=UIEdgeInsets(top:0, left:0, bottom: 0, right: 0)
    //列间距
    var columnMargin:CGFloat = 0.0
    
    //行间距
    var rowMargin:CGFloat = 0.0
    
    ///瀑布流列数
    var column = 2
    
    var maxY:CGFloat = 0
    
    var columnWidth:CGFloat = 0
    
    ///prepareLayout会在调用collectionView.reloadData()
    override func prepare() {
        self.columnMargin=margin
        self.rowMargin=margin
        self.sectionInsert=UIEdgeInsets(top:0, left:margin/2, bottom:margin,right:margin/2)
        //设置布局
        //需要清空字典里面的值
        for key in 0..<column
        {
            maxYDict[key] = 0
        }
        //清空之前的布局属性
        layoutAttributes.removeAll()
        //清空最大列的Y值
        maxY = 0
        ///清空列宽
        columnWidth = 0
        
        //计算每列的宽度，需要在布局之前算好
        columnWidth = (UIScreen.main.bounds.width - sectionInsert.left - sectionInsert.right - (CGFloat(column) - 1)*columnMargin)/CGFloat(column)
        
        let number = collectionView?.numberOfItems(inSection: 0) ?? 0
        
        for i in 0..<number
        {
            //布局每一个cell的frame
            let layoutAttr = layoutAttributesForItem(at:IndexPath(item: i, section:0))
            layoutAttributes.append(layoutAttr!)
        }
        
        calcMaxY()
    }
    func calcMaxY(){
        //获取最大这一列的Y
        //默认第0列最长
        var maxYCoulumn = 0
        //for 循环比较，获取最长的这列
        for (key,value) in maxYDict
        {
            if value > maxYDict[maxYCoulumn]!{
                //key这列的Y值是最大的
                maxYCoulumn = key
            }
        }
        //获取到Y值最大的这一列
        maxY = maxYDict[maxYCoulumn]! + sectionInsert.bottom
        
    }
    override var collectionViewContentSize: CGSize{
        return CGSize(width: UIScreen.main.bounds.width, height: maxY)
    }
    // 返回每一个cell的布局属性(layoutAttributes)
    //  UICollectionViewLayoutAttributes: 1.cell的frame 2.indexPath
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        assert(delegate != nil,"瀑布流必须实现代理来返回cell的高度")
        let height = delegate!.waterFlowViewLayout(waterFlowViewLayout: self, heightForWidth: columnWidth, atIndextPath:indexPath)
        // 找到最短的那一列,去maxYDict字典中找
        
        // 最短的这一列
        var minYColumn = 0
        
        //通过for循环去和其他列比较
        for(key, value) in maxYDict {
            
            if value < maxYDict[minYColumn]!
            {
                minYColumn = key
                
            }
        }
        
        // minYColumn 就是短的那一列
        let x = sectionInsert.left + CGFloat(minYColumn) * (columnWidth + columnMargin)
        //最短这列的Y值 + 行间距
        let y = maxYDict[minYColumn]! + rowMargin
        //设置cell的frame
        let frame = CGRect(x: x, y: y, width: columnWidth, height: height)
        //更新最短这列的最大Y值
        maxYDict[minYColumn] = frame.maxY
        //创建每个cell对应的布局属性
        let layoutAttr = UICollectionViewLayoutAttributes(forCellWith:indexPath)
        layoutAttr.frame = frame
        return layoutAttr
    }
    //预加载下一页数据
    override func layoutAttributesForElements(in rect:CGRect) -> [UICollectionViewLayoutAttributes]{
        return layoutAttributes
    }
}
