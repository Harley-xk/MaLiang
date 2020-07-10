# ![Banner](Images/banner.png)

[![CI Status](http://img.shields.io/travis/Harley-xk/MaLiang.svg)](https://travis-ci.org/Harley-xk/MaLiang)
[![Platform](https://img.shields.io/cocoapods/p/MaLiang.svg?style=flat)](http://cocoapods.org/pods/MaLiang)
[![Version](https://img.shields.io/cocoapods/v/MaLiang.svg)](http://cocoapods.org/pods/MaLiang)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Language](https://img.shields.io/badge/language-Swift%205-orange.svg)](https://swift.org)
[![codebeat badge](https://codebeat.co/badges/438159fd-b5f9-43d4-a1d5-b07ba5e6cf03)](https://codebeat.co/projects/github-com-harley-xk-maliang-metal)
[![License](https://img.shields.io/cocoapods/l/MaLiang.svg?style=flat)](http://cocoapods.org/pods/MaLiang)
[![twitter](https://img.shields.io/badge/twitter-Harley--xk-blue.svg)](https://twitter.com/Harley86589)
[![weibo](https://img.shields.io/badge/weibo-%E7%BE%A4%E6%98%9F%E9%99%A8%E8%90%BD-orange.svg)](https://weibo.com/u/1161848005)

![icon](Images/icon-32.png) **MaLiang** is a painting framework based on [**Metal**](https://developer.apple.com/metal/). It supports drawing and handwriting with customized textures.
The name of "MaLiang" comes from a boy who had a magical brush in Chinese ancient fairy story.

[Simplified Chinese](https://me.harley-xk.studio/posts/201805072231)

☕️ If I have saved your time, [buy me a cup of coffee](DONATE.md)

📱 App based on MaLiang is now avaliable on the [App Store](https://apps.apple.com/cn/app/id1462615532)

## Features

- [x] Lines with **Bezier Curve**
- [x] Texture **Rotation**
- [x] **Glowing** Lines
- [x] **Chartlet** element (for image and any other content from an UIView snapshot)
- [x] **Force** based Adjustment for stroke size
- [x] ** Pencil** supported
- [x] **3D Touch** supported
- [x] **Undo** & **Redo**
- [x] **Zoom** & **Scale**
- [x] **Export** to image
- [x] **Save** vector contents to disk
- [x] support macOS **Catalyst**

## Requirements

iOS 9.0, Swift 5 </br>

The core painting module is based on Metal</br>

You can simply make it compatible with lower version of iOS and swift by changing only serval lines of code.

## Installation

### CocoaPods

MaLiang is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```ruby
pod 'MaLiang'
```

To use the old OpenGL ES verion:

```ruby
pod 'MaLiang', '~> 1.1'
```

### Carthage

To integrate MaLiang into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ruby
github "Harley-xk/MaLiang"
```

Run `carthage update` to build the framework and drag the built `MaLiang.framework` into your Xcode project.

**Make sure to add `MaLiang.framework` to your target's `Embedded Binaries`**

## Usage

MaLiang is simple to use.

1. import MaLiang
2. enjoy painting!

### Canvas

```swift
open class Canvas: MetalView
```

A `Canvas` is the basic component of `MaLiang`. You will paint all things on it.
`Canvas` extends from `MetalView`, whitch extends from `MTKView`. `MetalView` handles all the logic with MetalKit and hides them from you.

`Canvas` can be simply created with xib or code.

- with xib or storyboard, simply drag and drop an `UIView` object into your view controller and change it's class to `Canvas` and module to `MaLiang`
- with code, just create with `init(frame:)` as any `UIView` you do before.

Now, all things necessary is done!

#### Snapshot

You can take snapshot on canvas now. Just call `snapshot` function on `Canvas` and you will get an optional `UIImage` object.

### Brush

With all things done, you can do more with `Brush`!

`Brush` is the key feature to `MaLiang`. It holds textures and colors, whitch makes it possiable to paint amazing things.

Register a `Brush` with image data or file to Canvas and paint with it:

```swift
let path = Bundle.main.path(forResource: "pencil", ofType: "png")!
let pencil = try? canvas.registerBrush(with: URL(fileURLWithPath: path))
pencil?.use()
```

`Brush` have serval properties for you to custmize:

```swift
// opacity of texture, affects the darkness of stroke
// set opacity to 1 may cause heavy aliasing
open var opacity: CGFloat = 0.3

// width of stroke line in points
open var pointSize: CGFloat = 4

// this property defines the minimum distance (measureed in points) of nearest two textures
// defaults to 1, this means erery texture calculated will be rendered, dictance calculation will be skiped
open var pointStep: CGFloat = 1

// sensitive of pointsize changed from force, from 0 - 1
open var forceSensitive: CGFloat = 0

/// color of stroke
open var color: UIColor = .black

// indicate if the stroke size in visual will be scaled along with the Canvas
// defaults to false, the stroke size in visual will stay with the original value
open var scaleWithCanvas = false
```

With all these properties, you can create you own brush as your imagination.

#### Force & 3D Touch

MaLiang supports automatically adjustment of stroke size with painting force. 3D Touch is supported by default, and simulated force will be setup on devices those are not supporting this.

`forceSensitive` is the property that force affects the storke size. It should be set between `0` to `1`. the smaller the value is, the less sensitive will be. if sets to `0`, then force will not affects the stroke size.

### Chartlet

Chartlet elements are supported from 2.1.0. A chartlet must be registered to canvas with its' texture data. You can simply get image data from its' `pngData()` method.

```swift
let data = UIImage(named: "chartlet").pngData()
let texture = try canvas.makeTexture(with: data)
```

You can apply **rotation** to chartlet by passing a counter clockwise angle in radius when adding it to the canvas:

```swift
canvas.renderChartlet(at: location, size: chartletSize, textureID: texture.id, rotation: angle)
```

#### Text

Text element can be rendered to canvas by the Chartlet feature. MaLiang leaves the work of text layout and styles to your self.

- Firtst, put your text content to a label, a text view or any other customized views
- Second, make it properly styled and layouted
- Then Third, take a snapshot from that view.
- Finally, now you shoud have an image to your text content, render this image to canvas using the Chartlet apis.

Refer to the samples for more details.

### CanvasData

`CanvasData` is now configured by default. It holds all the data on the `Canvas`, and makes the **undo** and **redo** actions to be possiable. </br>
And you can implement your own **saving logic** with the data holds by `CanvasData`.

### Saving

🎉 You can save your paintings to disk now.

```swift
// 1. create an instance of `DataExporter` with your canvas:
let exporter = DataExporter(canvas: canvas)
// 2. save to empty folders on disk:
exporter.save(to: localPath, progress: progressHandler, result: resultHandler)

// also you can use another synchronous method to do this work Synchronously
exporter.saveSynchronously(to: locakPath, progress: progressHandler)
```

Then, contents of canvas and some document infomations will be saved to files in the directory you provided.

**`MaLiang` does not zip the folders, you can implement your own archive Logics refer to the sample project**

### Reading

Use `DataImporter` to read data saved by `MaLiang` to your canvas:

```Swift
DataImporter.importData(from: localPath, to: canvas, progress: progressHandler, result: resultHandler)
```

Also, the localPath passed into DataImporter must be a folder where your contents files place. If you are using your own archive logic, unzip the contents first by your own.

## License

MaLiang is available under the MIT license. See the LICENSE file for more info.
