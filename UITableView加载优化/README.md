# UITableView优化

项目可参考[VVeboTableViewDemo](https://github.com/johnil/VVeboTableViewDemo)

----

参考medium文章[Perfect smooth scrolling in UITableViews](https://medium.com/ios-os-x-development/perfect-smooth-scrolling-in-uitableviews-fd609d5275a5)，中文翻译可参考[Perfect smooth scrolling in UITableViews](https://southpeak.github.io/2015/12/20/perfect-smooth-scrolling-in-uitableviews/)

其它博文:

+ [iOS 程序性能优化](http://www.samirchen.com/ios-performance-optimization/)
+ [10个加速Table Views开发的Tips](http://www.cocoachina.com/ios/20150729/12795.html)
+ [详细整理：UITableView优化技巧](http://www.cocoachina.com/ios/20150602/11968.html)


一些要点：
1.方法`tableView:cellForRowAtIndexPath:`要尽快的返回，不要在这里绑定数据
2.在方法`tableView:willDisplayCell:forRowAtIndexPath:`中，执行数据绑定，这个方法在显示cell之前被调用
3.快速计算cell高度

视图上的优化：
1.UIView的opaque不透明时，绘图系统在渲染视图时可以做一些优化，以提高性能
2.渲染最慢的操作之一是混合(blending)。混合操作由GPU来执行，因为这个硬件就是用来做混合操作的（当然不只是混合），提高性能的方法是减少混合操作的次数

+ 选择`Color Blended Layers`，绿色区域没有混合，但红色区域表示有混合操作
+ 优化混合操作的关键点是在平衡CPU和GPU的负载

优化UITableView中绘制数据操作的要点：

+ 减少iOS执行无用混合的区域：不要使用透明背景，使用iOS模拟器或者Instruments来确认这一点；如果可以，尽量使用没有混合的渐变。
+ 优化代码，以平衡CPU和GPU的负载。你需要清楚地知道哪部分渲染需要使用GPU，哪部分可以使用CPU，以此保持平衡。
+ 为特殊的cell类型编写特殊的代码。

像素方面：

+ 对所有像素相关的数据做四舍五入处理，包括点坐标，UIView的高度和宽度。
+ 跟踪你的图像资源：图片必须是像素完美的，否则在Retina屏幕上渲染时，它会做不必要的抗锯齿处理。
+ 定期复查你的代码，因为这种情况可以会经常出现。

异步化UI：

+ 找到让你的cell无法快速返回的瓶颈。
+ 将操作移到后台线程，并在主线程刷新显示的内容。
+ 最后一招是设置你的CALayer为异步显示模式(即使只是简单的文本或图片)–这将帮你提高FPS

----

参考[iOS面试题：腾讯一、二、三面以及参考思路](http://www.cocoachina.com/ios/20171127/21331.html)

3.遇到tableView卡顿嘛？会造成卡顿的原因大致有哪些？

可能造成tableView卡顿的原因有：

1.最常用的就是cell的重用， 注册重用标识符

如果不重用cell时，每当一个cell显示到屏幕上时，就会重新创建一个新的cell

如果有很多数据的时候，就会堆积很多cell。

如果重用cell，为cell创建一个ID，每当需要显示cell 的时候，都会先去缓冲池中寻找可循环利用的cell，如果没有再重新创建cell

2.避免cell的重新布局

cell的布局填充等操作 比较耗时，一般创建时就布局好

如可以将cell单独放到一个自定义类，初始化时就布局好

3.提前计算并缓存cell的属性及内容

当我们创建cell的数据源方法时，编译器并不是先创建cell 再定cell的高度

而是先根据内容一次确定每一个cell的高度，高度确定后，再创建要显示的cell，滚动时，每当cell进入凭虚都会计算高度，提前估算高度告诉编译器，编译器知道高度后，紧接着就会创建cell，这时再调用高度的具体计算方法，这样可以方式浪费时间去计算显示以外的cell

4.减少cell中控件的数量

尽量使cell得布局大致相同，不同风格的cell可以使用不用的重用标识符，初始化时添加控件，

不适用的可以先隐藏

5.不要使用ClearColor，无背景色，透明度也不要设置为0

渲染耗时比较长

6.使用局部更新

如果只是更新某组的话，使用reloadSection进行局部更

7.加载网络数据，下载图片，使用异步加载，并缓存

8.少使用addView 给cell动态添加view

9.按需加载cell，cell滚动很快时，只加载范围内的cell

10.不要实现无用的代理方法，tableView只遵守两个协议

11.缓存行高：estimatedHeightForRow不能和HeightForRow里面的layoutIfNeed同时存在，这两者同时存在才会出现“窜动”的bug。所以我的建议是：只要是固定行高就写预估行高来减少行高调用次数提升性能。如果是动态行高就不要写预估方法了，用一个行高的缓存字典来减少代码的调用次数即可

12.不要做多余的绘制工作。在实现drawRect:的时候，它的rect参数就是需要绘制的区域，这个区域之外的不需要进行绘制。例如上例中，就可以用CGRectIntersectsRect、CGRectIntersection或CGRectContainsRect判断是否需要绘制image和text，然后再调用绘制方法。

13.预渲染图像。当新的图像出现时，仍然会有短暂的停顿现象。解决的办法就是在bitmap context里先将其画一遍，导出成UIImage对象，然后再绘制到屏幕；

14.使用正确的数据结构来存储数据。

---









