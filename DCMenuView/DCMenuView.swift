//
//  DCMenuView.swift
//  DCMenuView
//
//  Created by admin on 2018/12/24.
//  Copyright © 2018 ape.zhang. All rights reserved.
//

import UIKit

@objc public protocol DCMenuViewDelegate: class {
    ///是否允许被选中
    @objc optional func menuView(menu:DCMenuView, shouldSelectedAt index:Int) -> Bool
    ///已经被选中
    @objc optional func menuView(menu:DCMenuView, didSelectedAt index:Int)
    
    ///对应项的宽度
    @objc optional func menuView(menu:DCMenuView, widthForItemAt index:Int) -> CGFloat
    ///对应项的间距
    @objc optional func menuView(menu:DCMenuView, marginForItemAt index:Int) -> CGFloat
}

public protocol DCMenuViewDataSource: class {
    ///有多少项
    func numbersOfTitles(in menu:DCMenuView) -> Int
    ///对应项的标题
    func menuView(menu:DCMenuView, titleAtIndex index:Int) -> String
}

///默认tag，用来获取index
private let ItemDefualtTag = 6622

public class DCMenuView: UIView {
    
    ///容器
    private let containerView = UIScrollView(frame: CGRect.zero)
    ///进度条
    private let progressView = UIView()
    ///是否已经加载
    private var didLoad = false
    ///被选中的Item
    private var selectedItem: UIButton?
    ///所有Items的Frame
    private var itemsFrame = [CGRect]()
    
    public weak var delegate : DCMenuViewDelegate?
    public weak var dataSource : DCMenuViewDataSource?
    
    ///所有标题名称
    private var menuTitles = [String]()
    
    ///是否自动计算标题宽度
    public var autoCaculateItemsWidth = false
    
    ///每一项的宽度
    public var itemsWidth: CGFloat = 65
    ///每一项的间距
    public var itemsMargin: CGFloat = 10
    ///未选中字体颜色
    public var normalColor = UIColor.lightGray
    ///未选中字体
    public var normalFont = UIFont.systemFont(ofSize: 16)
    ///已选中字体颜色
    public var selectedColor = UIColor.red
    ///已选中字体
    public var selectedFont = UIFont.boldSystemFont(ofSize: 18)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView.showsHorizontalScrollIndicator = false
        containerView.showsVerticalScrollIndicator = false
        containerView.bounces = false
        containerView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        containerView.contentSize = containerView.bounds.size
        addSubview(containerView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ///加载到SuperView，会调用多次，didLoad控制单次加载
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard didLoad == false else { return }
        didLoad = true
        
        addItems()
        
        addProgressView()
    }
    
    //MARK: - Public API
    ///刷新Menu
    public func reloadData() {
        itemsFrame.removeAll()
        for (_, subView) in containerView.subviews.enumerated() {
            subView.removeFromSuperview()
        }
        
        progressView.removeFromSuperview()
        
        addItems()
        
        addProgressView()
    }
    
    //MARK: - Private
    ///添加ProgressView
    private func addProgressView() {
        progressView.backgroundColor = .purple
        containerView.insertSubview(progressView, at: 0)
    }
    
    ///添加所有Item
    private func addItems() {
        
        calculateItemsFrame()
        
        for i in 0..<titlesCount() {
            let title = itemTitle(at: i)
            let itemBtn = UIButton(type: .custom)
            itemBtn.tag = ItemDefualtTag + i
            itemBtn.titleLabel?.font = normalFont
            itemBtn.setTitle(title, for: .normal)
            itemBtn.setTitleColor(normalColor, for: .normal)
            itemBtn.setTitleColor(selectedColor, for: .selected)
            itemBtn.addTarget(self, action: #selector(didSelectedItem(item:)), for: .touchUpInside)
            containerView.addSubview(itemBtn)
            itemBtn.frame = itemsFrame[i]
            
            if i == 0 {
                progressView.bounds = CGRect(x: 0, y: 0, width: 20, height: 2)
                progressView.center = CGPoint(x: itemBtn.center.x, y: self.frame.size.height - 1)
                didSelectedItem(item: itemBtn)
            }
        }
    }
    
    ///处理所有选项的Frame，以及contentSize
    private func calculateItemsFrame() {
        var contentWidth = itemMargin(at: 0)
        let itemHeight = containerView.bounds.size.height
        
        for i in 0..<titlesCount() {
            let width = itemWidth(at: i)
            let itemFrame = CGRect(x: contentWidth, y: 0, width: width, height: itemHeight)
            itemsFrame.append(itemFrame)
            contentWidth += width + itemMargin(at: i + 1)
        }
        
        if contentWidth < containerView.bounds.size.width {
            let distance = (containerView.bounds.size.width - contentWidth)
            let gap = distance / CGFloat(titlesCount() + 1)
            for i in 0..<itemsFrame.count {
                var itemFrame = itemsFrame[i]
                itemFrame.origin.x += gap * CGFloat(i + 1)
                itemsFrame[i] = itemFrame
            }
            contentWidth = containerView.bounds.size.width
        }
        containerView.contentSize = CGSize(width: contentWidth, height: itemHeight)
    }
    //MARK: - Helper
    ///选项数
    private func titlesCount() -> Int {
        
        var count = dataSource?.numbersOfTitles(in: self)
        
        if count == nil {
            count = menuTitles.count
        }
        
        return count ?? 0
    }
    ///对应选项的标题
    private func itemTitle(at index:Int) -> String {
        var title = dataSource?.menuView(menu: self, titleAtIndex: index)
        if title == nil, index < menuTitles.count  {
            title = menuTitles[index]
        }
        return title ?? "None"
    }
    ///对应选项的宽度
    private func itemWidth(at index:Int) -> CGFloat {
        
        guard autoCaculateItemsWidth == false else {
            return caculateTitleWidth(at:index)
        }
        
        let width = delegate?.menuView?(menu: self, widthForItemAt: index)
        
        return width ?? itemsWidth
    }
    
    ///对应选项的间距
    private func itemMargin(at index:Int) -> CGFloat {
        let margin = delegate?.menuView?(menu: self, marginForItemAt: index)
        return margin ?? itemsMargin
    }
    ///对应选项的标题文字宽度
    private func caculateTitleWidth(at index:Int) -> CGFloat {
        let title = itemTitle(at: index)
        let attri = NSAttributedString(string: title, attributes: [.font : selectedFont])
        let size = attri.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
        return size.width
    }
    
    //MARK: - Action
    @objc func didSelectedItem(item:UIButton) {
        
        guard item != selectedItem else { return }
        
        let index = item.tag - ItemDefualtTag
        
        guard delegate?.menuView?(menu: self, shouldSelectedAt: index) == true else {
            return
        }
        
        let fromIndex = (selectedItem?.tag ?? ItemDefualtTag) - ItemDefualtTag
        willScroll(from: fromIndex, to: index)

        selectedItem?.isSelected = false
        selectedItem?.titleLabel?.font = normalFont
        item.isSelected = true
        item.titleLabel?.font = selectedFont
        selectedItem = item
        
        delegate?.menuView?(menu: self, didSelectedAt: index)
        scrollToCenter()
    }
    
    private func scrollToCenter() {
        
        guard let item = selectedItem else { return }
        
        let itemX = item.frame.origin.x
        let itemWidth = item.frame.size.width
        let selfWidth = containerView.bounds.width
        let contentWidth = containerView.contentSize.width
        
        var offsetX:CGFloat = 0;
        
        if itemX > selfWidth / 2.0 {
            if contentWidth - itemX <= selfWidth / 2.0 {
                offsetX = contentWidth - selfWidth
            }else {
                offsetX = itemX - selfWidth / 2.0 + itemWidth / 2.0
            }
            if offsetX + itemWidth > contentWidth {
                offsetX = contentWidth - selfWidth
            }
        }else {
            offsetX = 0
        }
        containerView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        UIView.animate(withDuration: 0.25) {
            self.progressView.center = CGPoint(x: item.center.x, y: self.frame.size.height - 2)
        }
    }
    
    private func willScroll(from:Int, to:Int) {
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
