# ![](icon-32.png) MaLiang

[![CI Status](http://img.shields.io/travis/Harley-xk/MaLiang.svg?style=flat)](https://travis-ci.org/Harley-xk/MaLiang)
[![Version](https://img.shields.io/cocoapods/v/MaLiang.svg?style=flat)](http://cocoapods.org/pods/MaLiang)
[![License](https://img.shields.io/cocoapods/l/MaLiang.svg?style=flat)](http://cocoapods.org/pods/MaLiang)
[![Platform](https://img.shields.io/cocoapods/p/MaLiang.svg?style=flat)](http://cocoapods.org/pods/MaLiang)

MaLiang is a painting framework based on OpenGL ES. The name of "MaLiang" comes from a boy who had a magical brush  in Chinese ancient fairy story.

[Simplified Chinese](https://www.jianshu.com/p/13849a90064a)

<img src="sample.png" width=450></img>

## Requirements

iOS 9.0+, Swift 4.1+ </br>

The core painting module is based on OpenGL ES 3.0</br>

You can simply make it compatible with lower version of iOS and swift by changing only serval lines of code.

## Installation

MaLiang is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MaLiang'
```

## Usage

MaLiang is simple to use.
1. import MaLiang
3. enjoy painting!

### Canvas

```swift
open class Canvas: MLView
```

A `Canvas` is the basic component of `MaLiang`. You will paint all things on it.
`Canvas` extends from `MLView`, whitch extends from `UIView`. `MLView` handles all the logic with OpenGL and hides them from you.

`Canvas` can be simply created with xib or code.

- with xib or storyboard, simply drag and drop an `UIView` object into your view controller and change it's class to `Canvas` and module to `MaLiang`
- with code, just create with `init(frame:)` as any `UIView` you do before.

Now, all things necessary is done!

#### Snapshot
You can take snapshot on canvas now. Just call `snapshot` function on `Canvas` and you will get an optional `UIImage` object.

### Brush

With all things done, you can do more with `Brush`!

`Brush` is the key feature to `MaLiang`. It holds textures and colors, whitch makes it possiable to paint amazing things.

`Brush` can be created with a image:

```swift
let image = UIImage(named: "pencil.png")
let pencil = Brush(texture: image)
canvas.brush = pencil
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
```

With all these properties, you can create you own brush as your imagination.

#### Force & 3D Touch

MaLiang supports automatically adjustment of stroke size with painting force. 3D Touch is supported by default, and simulated force will be setup on devices those are not supporting this.

`forceSensitive` is the property that force affects the storke size. It should be set between `0` to `1`. the smaller the value is, the less sensitive will be. if sets to `0`, then force will not affects the stroke size.

### Document

`Document` is not required. It holds all the data on the `Canvas`, and makes the **undo** and **redo** actions to be possiable. </br>
And you can implement your own **saving logic** with the data holds by `Document`.

To enable the `Document` for `Canvas`, there needs only one line of code: 

```swift
canvas.setupDocument()
```

The operation above may be failed if there's not enough disk rooms. Because we need rooms to keep textures and painting datas on disk.</br>
Use `do-catch` to process the error when it appears:

```swift
do {
    try canvas.setupDocument()
} catch {
    // do somthing when error occurs
}
```

## TODO
- [x] Undo & Redo
- [x] Export to image
- [ ] Text element
- [ ] Image element
- [ ] Texture rotation

## License

MaLiang is available under the MIT license. See the LICENSE file for more info.

