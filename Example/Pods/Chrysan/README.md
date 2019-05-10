
<h1>
<img src="Images/icon.png" height=35>  Chrysan</img>
</h1>

[![CI Status](http://img.shields.io/travis/Harley-xk/Chrysan.svg?style=flat)](https://travis-ci.org/Harley-xk/Chrysan)
[![Version](https://img.shields.io/cocoapods/v/Chrysan.svg?style=flat)](http://cocoapods.org/pods/Chrysan)
[![Language](https://img.shields.io/badge/language-Swift%205-orange.svg)](https://swift.org)
[![License](https://img.shields.io/cocoapods/l/Chrysan.svg?style=flat)](http://cocoapods.org/pods/Chrysan)
[![Platform](https://img.shields.io/cocoapods/p/Chrysan.svg?style=flat)](http://cocoapods.org/pods/Chrysan)
[![twitter](https://img.shields.io/badge/twitter-Harley--xk-blue.svg)](https://twitter.com/Harley86589)
[![weibo](https://img.shields.io/badge/weibo-%E7%BE%A4%E6%98%9F%E9%99%A8%E8%90%BD-orange.svg)](https://weibo.com/u/1161848005)
> Chrysan 是一个简单易用的 HUD 库，基于我较早之前写的 HKProgressHUD，使用 Swift 进行了重构和优化。使用 iOS 自带的 UIBlurEffect 毛玻璃特效。

<img src="Images/sample_2.png" height=350></img>
<img src="Images/sample_3.png" height=350></img>
<img src="Images/sample_4.png" height=350></img>
<img src="Images/sample_1.png" height=350></img>
<img src="Images/sample_0.gif" height=350></img>

### 适配

Chrysan 最新版支持 iOS 9.0+，已针对 Swift 5 以及 iOS 12 适配。

### 安装

通过 CocoaPods 安装：

```ruby
# for swift 4.2
pod 'Chrysan'
# for swift 4.0/4.1/ iOS 8.0+
pod 'Chrysan', :git => 'https://github.com/Harley-xk/Chrysan.git, :tag=>1.3.0'
```

**_Swift 5 请使用 1.5.0 及以上版本_**

### 使用

每个 View 都有一个 chrysan 属性，可以获取当前 View 的独立的菊花。只有当第一次访问 chrysan 属性时才会真实地创建 ChrysanView 实例，避免不必要的开销和内存占用。

通过访问 ViewController 的 chrysan 属性，可以访问 ViewController 的根 View 的菊花并自动创建。~~通过 ViewController 创建的菊花会自动设置向上 64 个 pt 的距离位移，以优化视觉效果。~~

#### <span style="color:#1296db">显示自定义动画</span>

**<span style="color:#1296db">1.3.0 加入新特性，现在可以通过全局配置项来显示自定义的加载动画了</span>**

`chrysanStyle` 属性修改为 `ChrysanStyle` 类型，新增了 `animationImages` 关联枚举类型，可以指定一个 UIImage 的数组，作为自定义动画的循环帧图片播放，具体用法参考示例项目及注释。
`ChrysanConfig` 类型新增 `frameDuration` 属性，用来控制自定义动画的播放速度。

#### 显示

```swift
public func show(_ status: Status = .running, message: String? = nil, hideDelay delay: Double = 0)
```
这个方法用来显示一个菊花，各参数说明如下：

***status*** - 显示菊花的状态，属于 Status 枚举类型，可以控制显示不同的状态

```swift
/// 菊花的状态，不同的状态显示不同的icon
    public enum Status {
        /// 无状态，显示纯文字
        case plain
        /// 执行中，显示菊花
        case running
        /// 进度，环形进度条
        case progress
        /// 成功，显示勾
        case succeed
        /// 错误，显示叉
        case error
        /// 自定义，显示自定义的 icon
        case custom
    }
```

***message*** - 显示在图标下方的说明文字，说明文字支持多行文本

***hideDelay*** - 自动隐藏的时间，传入0则表示不自动隐藏


#### 显示菊花

```swift
// 由于 show 方法的各个参数都支持默认值
// 因此可以调用所有参数都是默认值的最简形式
// 此时显示一个单纯的不会隐藏的菊花
chrysan.show()

// 显示一个带文字的菊花
chrysan.show(message: "正在处理")
```

#### 显示纯文本

```swift
// 显示纯文字
chrysan.show(.plain, message:"这是一段纯文字")
// 显示纯文字，1 秒后隐藏
chrysan.show(.plain, message:"这是一段纯文字", hideDelay: 1)
```

#### 显示图案

```swift
// 任务完成后给予用户反馈
chrysan.show(.succeed, message: "处理完毕", hideDelay: 1)
// 显示自定义图案
let image = UIImage(named: "myImage")
chrysan.show(customIcon: image, message: "自定义图案", hideDelay: 1)
```

#### 显示任务进度

```swift
// 显示环形的任务进度，会在中心显示进度百分比，progress 取值 0-1
chrysan.show(progress: progress, message: "下载中...")
```

### 自定义样式

`1.2` 版本开始引入 `ChrysanConfig` 配置类，方便进行全局配置以及快速样式切换。原 Chrysan 的样式属性全都移入 `ChrysanConfig`。

#### 全局样式

```swift
let config = ChrysanConfig.default()
```

`ChrysanConfig` 提供了一个默认全局样式，所有的 `Chrysan` 创建时都默认使用全局样式，你可以在创建之后为它指定其他样式。
你也可以直接修改全局样式，这样所有使用该样式的 `Chrysan` 都将同步获得修改。

#### 修改样式

修改样式现在需要修改 `Chrysan` 的 `config` `属性。ChrysanConfig` 与之前相同，支持有限的自定义样式。

菊花背景支持 `UIBlurEffect` 的所有样式

```swift
/// 菊花背景样式，使用系统自带的毛玻璃特效，默认为黑色样式
public var hudStyle = UIBlurEffectStyle.dark
```

菊花使用系统的 `UIActivityIndicatorView，支持` `UIActivityIndicatorViewStyle` 的所有类型，默认为 `whiteLarge`

```swift
public var chrysanStyle = UIActivityIndicatorViewStyle.whiteLarge
```


颜色，影响 `icon`（不包含菊花）、说明文字、进度条和进度数值的颜色

```swift
/// icon 及文字颜色，默认为白色
public var color = UIColor.white
```

支持自定义图片，图片会被强制转换成 Template 渲染模式，因此必须使用包含 `alpha` 通道的图片

```swift
/// 自定义的 icon 图片 
public var customIcon: UIImage? = nil
```

弹出 HUD 时，可以设置遮罩以遮住背景的内容，遮罩的颜色可以自定义，默认为全透明

```swift
/// 遮罩颜色，遮挡 UI 的视图层的颜色，默认透明
public var maskColor = UIColor.clear
```

可以自定义 HUD 在视图中央的偏移，以应对某些情况下 HUD 不在中心的情况

```swift
/// 菊花在视图中水平方向上的偏移，默认为正中
public var offsetX: CGFloat = 0
/// 菊花在视图中竖直方向上的偏移，默认为正中
public var offsetY: CGFloat = 0
```

<p style="color:red">
注意：修改使用默认样式的 Chrysan 会影响所有其它同样使用默认样式的 Chrysan
</p>

更多内容请查看示例以及代码注释。
