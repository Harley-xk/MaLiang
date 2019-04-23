# ![Comet](Images/img_0.png) Comet

[![CI Status](http://img.shields.io/travis/Harley-xk/Comet.svg?style=flat)](https://travis-ci.org/Harley-xk/Comet)
[![Version](https://img.shields.io/cocoapods/v/Comet.svg?style=flat)](http://cocoapods.org/pods/Comet)
[![License](https://img.shields.io/cocoapods/l/Comet.svg?style=flat)](http://cocoapods.org/pods/Comet)
[![Platform](https://img.shields.io/cocoapods/p/Comet.svg?style=flat)](http://cocoapods.org/pods/Comet)

iOS 项目的 Swift 基础库，提供大量常用组件、便利方法等。支持 **Swift 3.0+**。
1.0.0 起支持 Swift 4.x，需要支持 Swift 3.x 请使用 0.7.5 版本。
1.5.0 起支持 Swift 4.2， 需要支持 Swift 4.0/4.1 请指定 1.4.1 版本。

## 安装

支持 CocoaPods 安装：

```ruby
# for swift 4.2
pod 'Comet'
# for swift 4.0/4.1
pod 'Comet', :git => 'https://github.com/Harley-xk/Comet.git, :tag=>1.4.1'
# for swift 3.1/3.2
pod 'Comet', :git => 'https://github.com/Harley-xk/Comet.git, :tag=>0.7.5'
```

## API 清单

### 工具类

#### 1. KeyboardPlacehoder —— 键盘占位符

键盘输入是几乎每个 App 都要涉及到的内容，当输入框获得焦点，虚拟键盘弹出时，需要动态调整界面 UI 布局以适应新的界面尺寸。一般做法是通过在视图控制器中监听键盘的弹出隐藏等事件通知，根据不同的状态进行 UI 调整处理。当有多个甚至大量的界面需要处理内容输入时，需要在每个视图控制器中实现几乎相同的代码逻辑，繁琐又耗时。**键盘占位符**就是专门用来应对这个问题的。

原理：

**键盘占位符**就是键盘弹出后在实际试图中的映射。开发时只需要将占位符添加到任意视图中，设置其他视图的相对位置；当键盘弹出或者收起（任意键盘尺寸、位置发生改变）时，占位符将会自动调整自身的高度，保证实际尺寸和位置与键盘在占位符父视图中的投影相一致。

*_键盘占位符相比于原来的键盘管理器更加方便使用，推荐使用新的占位符方式处理键盘事件，键盘管理器后期将会被废除_*

#### ~~2. HairLine —— 极细的线？（已废除）~~

#### 3. Path —— 路径

文件读写是大多数 App 或多或少需要涉及的内容，路径类主要用于快速获取设备的各种文件及文件夹路径。 **Path** 类的本质是对路径字符串的封装，在此基础上提供额外的简便操作方法。详细可以查看 **Path** 类的方法注释

#### 4. CollectionGrouper

1.6 新增 `CollectionGrouper` 集合分组工具类，可以对集合进行指定元素属性进行分组，也可以通过自定义分组规则实现自定义分组，详细参考 “Grouper Sample” 实例。

#### ~~4. PinyinIndexer —— 拼音索引器（即将废除）~~

**_即将废除，新增的 `CollectionGrouper` 可以实现拼音分组需求以及更多其他自定义需求，专门的拼音索引器会在将来移除_**

遇到列表类需求时（比如联系人列表），往往需要将列表的内容按照拼音首字母进行索引排序，这是一个简单但又繁琐的工作，因此**拼音索引器**诞生了。

用法：

1. 创建需要进行索引的对象数组。~~因为索引器在获取属性时使用了 ***KVC*** 的方式来获取对象对应属性的值，因此要求数据对象必须是 NSObject 的子类。~~ 

	0.5 及以上版本更新使用协议来实现，不再要求继承 NSObject，参见第 5 点。
	
2. 创建拼音索引器，构造函数需要两个参数：***对象数组*** 和索引所依据的 ***属性键值***。
3. 索引器创建时会直接进行索引任务，对大量数据进行索引时考虑到性能问题，不建议在主线程处理。
4. 索引器创建完成后，可以通过 ***indexedObjects*** 和 ***indexedTitles*** 属性获得索引的结果
	- ***indexedObjects*** 是一个二维数组，其中是根据索引顺序排序好的对象数组
	- ***indexedTitles*** 是索引后的拼音首字母的数组

5. 0.5.0 更新：使用协议的方式代替 KVC，解除了数据对象必须为 NSObject 子类的限制。使用时，声明数据类实现`PinyinIndexable`协议，然后通过`var valueToPinyin: String { get }`这个协议方法，返回需要转换为拼音的属性即可。

#### 5. TaskRecorder —— 任务记录器

App 的基本功能就是执行各种任务，比如网络任务。正常情况下，发起的任务都能执行完毕并返回结果。在某些情况下，任务并不能或者没有必要执行完毕。比如在一个视图控制器中发起了一个网络请求来获取数据，以显示在当前界面上；但是在请求执行完毕之前，用户操作退出了该界面，此时往往没有必要再继续执行这个请求，因此需要程序作出处理，取消这个网络任务的执行。当一个界面中的网络任务较多时，手动处理这些逻辑就会变得繁琐且容易出错。
通过任务记录器可以将发起的任务关联到某个对象，并且在这个对象被销毁时，任务纪录器会将所有已纪录并且还没有执行完毕的任务都取消并销毁。

用法：

1. 需要被纪录的任务都必须实现 *TaskProtocol* 协议，只需要实现一个简单的 *cancel* 方法
2. 对需要关联的对象调用 *record(task:)* 方法，并将需要纪录的任务作为参数传入，就会自动创建一个记录器并关联到该对象
3. 对象销毁时记录器会自动执行逻辑，对未完成的任务调用 *cancel* 方法并将其销毁

#### 6. Utils —— 通用工具类

主要提供一些设备相关的工具方法，例如获取设备型号、系统版本、拨打电话等。详情参见 **Utils** 类的方法注释

### 扩展

#### 1. Date —— 日期类扩展

日期类扩展提供快速操作日期的一些方法：

1. **通过日期字符串创建日期对象**

	```swift
	public init?(string: String, format: String = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone = TimeZone.current)
	```
	*string* - 日期字符串
	
	*format* - 日期的格式，默认为"yyyy-MM-dd HH:mm:ss"
	
	*timeZone* - 时区，默认为设备当前设置的时区
	
	*将 local 参数替换为 timeZone*
	

2. **将日期转换为指定格式的字符串**
	
	```swift
	public func string(format: String = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone = TimeZone.current) -> String
	```
	*format* - 指定的字符串格式
	
	*timeZone* - 时区，默认为设备当前设置的时区

	*将 local 参数替换为 timeZone*
	
3. **日期计算**
	
	```swift
	public func add(_ value: Int, _ unit: DateUnit) -> Date
	```

	返回当前日期加上指定单位值之后的日期，会自动进位或减位
	
	例如：10月30日加上两天后会变成11月1日
	
	*value* - 对应单位的值
	
	*unit* - 计算的单位
	
4. **日期设定**

	```swift
	public func set(_ unit: DateUnit, to value: Int) -> Date
	```	
	将指定单位设置为指定的值，返回修改后的新日期
	
	如果设置的值大于当前单位的最大值或者小于最小值，会自动进位或减位
	
	*unit* - 设置的单位
	
	*value* - 设置的值
	
5. **忽略精确时间（时／分／秒）的日期**

	```swift
	public var withoutTime: Date
	```
	有时候进行日期计算需要以天为最小单位，忽略具体的时间。该属性可以获取该日期当天零点的时间对象
	
6. **获取指定日期组件的值**
	
	```swift
	public func unit(_ unit: DateUnit) -> Int
	```
	通过设置单位，可以获取某个日期的年、月、日等单个单位的值

7. **一周中的时间**

	```swift
	public var weekday: Int
	```
	获取某个日期是一周中的第几天，即周几
	
	**注：周日为一周的第一天，从 0 开始，周一为 1，依此类推**
		
#### 2. String —— 字符串扩展

1. **拼音**
	
	```swift
	public func pinyin(_ type: PinyinType = .normal) -> String
	```
	获取指定类型的拼音	
	- normal - 默认不带声调的全拼
	
	- withTone - 带声调的全拼
	
	- firstLetter - 拼音首字母
	
2. **Base64 编码／解码** 
	
	```swift
   public var base64Decode: String?
   public var base64Encode: String? 
	```

3. **RegEx 正则表达式**

	```swift
    /// 常用正则表达式
    // 邮箱
    public var regex_email: String
    // 电话号码
    public var regex_phone: String
    // 手机号码
    public var regex_mobile: String
    
    /// 判断是否匹配正则表达式
    public func match(regex: String) -> Bool
    /// 判断是否是邮箱
    public var isEmail: Bool 
    /// 判断是否是电话号码
    public var isPhone: Bool
    /// 判断是否是手机号码
    public var isMobile: Bool 
    /// 同时验证电话和手机
    public var isPhoneOrMobile: Bool 
	```
4. **URL**

	```swift
	// URL 编码
	public var URLEncode: String?
	// URL 解码
   public var URLDecode: String?
	```
5. **计算大小**

	```swift
	public func width(limitToHeight height: CGFloat, font: UIFont) -> CGFloat
	public func height(limitToWidth width: CGFloat, font: UIFont) -> CGFloat
	public func size(limitToSize size: CGSize, font: UIFont) -> CGSize
	```
	根据限定的高或者宽度，计算另一项的值

#### 3. UIColor

1. **16进制颜色**

	```swift
	public convenience init?(hex: String, alpha: CGFloat = 1)
	```
	用16进制颜色代码创建 UIColor 对象，字符串可以是 0xaaaaaa、#aaaaaa、aaaaaa 三种格式中的任何一种

#### 4. UIResponder

1. **解除任何第一响应者**

	```swift
   public class func resignAnyFirstResponder()
	```
	通过该方法可以不需要指定任何对象，直接将当前任何处于第一响应者状态的控件解除该状态
		
2. **在 IB 中设置 - 解除第一响应者**

	```swift
   @IBAction public func autoResignFirstResponder()
	```
	在 IB 中，将特定事件指派到 FirstResponder 上的 *autoResignFirstResponder* 方法，可以在事件触发后解除当前第一响应者状态的操作，如图：
	        
	<img src="Images/img_1.png" width="430" height="400">


3. **在 IB 中设置 - 指定第一响应者**

	```swift
   @IBAction public func autoBecomFirstResponder()
	```
	在 IB 中，将特定事件指派到输入框的 *autoBecomFirstResponder* 方法，可以在事件触发后使指定控件成为第一响应者，如图：
	
	<img src="Images/img_2.png" width="430" height="345">

#### 5. UIView

1. **在 IB 中快速设置属性**

	```swift
   @IBInspectable var cornerRadius: CGFloat  // 边角半径
   @IBInspectable var borderWidth: CGFloat   // 边框宽度
   @IBInspectable var borderColor: UIColor?  // 边框颜色
	```
	这些声明实现了直接在 IB 中设置 UIView 相关属性的功能：

	<img src="Images/img_3.png" width="265" height="220">

#### 6. UIStoryboard
	
1. **获取 Storyboard**
	
	```swift
	// 获取创建项目时自动创建的 Main Stroyboard
	public class var main: UIStoryboard
   // 根据名称从 MainBundle 中创建 Storyboard
   public convenience init(_ name: String = "Main") {
	```
	
2. **创建视图控制器**

	```swift
    public func create<T: UIViewController>(identifier: String? = nil) -> T
    ```
    该方法可以从 Storyboard 创建指定的视图控制器实例，*identifier* 为 IB 中设置的视图控制器 ID。
    
    *identifier* 可以省略，此时要求 IB 中设置的 ID 为 视图控制器的类名，此时写法如下：
    
    ```swift
    let controller = UIStoryboard("Auth").create() as LoginViewController
    ```

3. **入口视图控制器**
    
   ```swift
   public var initial: UIViewController?
	```
	每个 Storyboard 文件都可以设置一个入口视图控制器，该方法可以创建当前 Storyboard 文件的入口视图控制器实例
	
#### 7. GCD 扩展

扩展几个 GCD 方法以更方便地调用 GCD 的延迟函数

```swift
public func asyncAfter(delay: DispatchTimeInterval, execute work: @escaping @convention(block) () -> Swift.Void)
    
public func asyncAfter(delay seconds: TimeInterval, execute work: @escaping @convention(block) () -> Swift.Void)

public func asyncAfter(delay: DispatchTimeInterval, execute: DispatchWorkItem)
  
public func asyncAfter(delay seconds: TimeInterval, execute: DispatchWorkItem)
```

示例：

```swift
DispatchQueue.global().asyncAfter(delay: 2) {
	print("延迟两秒执行")
}
        
DispatchQueue.global().asyncAfter(delay: .nanoseconds(2)) {
	print("延迟两纳秒执行")
}
```

#### 8. KVO & 闭包
KVO 是 Foundation 框架强大的功能之一，但是由于不支持闭包，导致实现起来比较繁琐。注册和实际处理的代码需要写在不同的地方，对于一些轻量级的逻辑来说并不十分友好。

通过 NSObject+KVOHandler 扩展，可以在注册 KVO 观察者时直接提供一个闭包来实现了。比如下面的代码实现了观察 ScrollView 的 contentOffset 的变化，可以比较一下原来的实现方式和闭包形式的实现方式。

原来的实现：

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    scrollView.addObserver(self, forKeyPath: "contentOffset", context: nil)
}

override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "contentOffset" {
        // Do something
    }
}
```

使用闭包实现：

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    scrollView.addObserver(for: "contentOffset") { (_, _, _) in
        // Do something
    }
}
```

### 移除

1. 移除 MD5 编码、RC4 加密等相关内容。推荐使用更加成熟的加密框架： [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)，支持更广泛的加密协议。
2. 移除 HKUserDefaults。RC4 属于已过时的加密方式，随着 RC4 加密的移除将 KUserDefaults 一并移除了，有加密需求推荐使用更成熟的第三方加密框架。
