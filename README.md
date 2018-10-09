## Panda
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/PandaKit.svg?style=flat)](http://cocoapods.org/pods/PandaKit)
[![](https://img.shields.io/badge/iOS-8.0%2B-lightgrey.svg)]()
[![Swift 4.0](https://img.shields.io/badge/Swift-4.2-orange.svg)]()
## What is Panda


Panda is an asynchronous render and layout framework which can be used to achieve high performance tableview. 

Panda is combined by 3 different component:

1. [Cassowary](https://github.com/nangege/Cassowary).  Core algorithm for constraint solving
2. [Layoutable](https://github.com/nangege/Layoutable). API  for 'AutoLayout'
3. [Panda](https://github.com/nangege/Panda). Asynchronous display node.

## Why use Panda
When it comes to  asynchronous render,many developr will think about [Texture](https://github.com/texturegroup/texture/), In facet, Panda learned a lot from [Texture](https://github.com/texturegroup/texture/), Panda's render process can be seen as a simplfy version of [Texture](https://github.com/texturegroup/texture/). But Panda does have it's advantages.Panda use 'AutoLayout' for frame caculating which make it easy to learn compared to Texture's Flexbox.Panda is more lightweighted and usage is more close to system's API,it just cost little to integration. So,if you love Swift,love AutoLayout ,want a high fps tableview and do't want to cost too much,Panda is for you. 


## Feature
- [x] Asynchronous render view
- [x] AutoLayout similar API with background thread usage ability
- [x] Comparable with existing UIView subclass
- [x] Pure Swift implement

## Requirements
- iOS 8.0+
- Swift 4.2
- Xcode 10.0

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects. Install it with the following command:

`$ gem install cocoapods`

To integrate Panda into your Xcode project using CocoaPods, specify it to a target in your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
  # your other pod
  # ...
  pod 'PandaKit'
end
```
Then, run the following command:

`$ pod install`

open the `{Project}.xcworkspace` instead of the `{Project}.xcodeproj` after you installed anything from CocoaPods.

For more information about how to use CocoaPods, [see this tutorial](http://www.raywenderlich.com/64546/introduction-to-cocoapods-2).

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa application. To install the carthage tool, you can use [Homebrew](http://brew.sh).

```bash
$ brew update
$ brew install carthage
```

To integrate Panda into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "https://github.com/nangege/Panda" "master"
```

Then, run the following command to build the Panda framework:

```bash
$ carthage update
```

At last, you need to set up your Xcode project manually to add the Panda,Layoutable and Cassowary framework.

On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop each framework you want to use from the Carthage/Build folder on disk.

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following content:

```bash
/usr/local/bin/carthage copy-frameworks
```

and add the paths to the frameworks you want to use under “Input Files”:

```bash
$(SRCROOT)/Carthage/Build/iOS/Panda.framework
$(SRCROOT)/Carthage/Build/iOS/Layoutable.framework
$(SRCROOT)/Carthage/Build/iOS/Cassowary.framework
```

For more information about how to use Carthage, please see its [project page](https://github.com/Carthage/Carthage).




## Usage

1. *Basic*

  import both `Panda` and `Layoutable`,than just write like UIKit
  
  ```swift
  import Panda
  import Layoutable

  // initiallize 
  let node = ViewNode()
  let textNode = TextNode()
  
  // addSubnode
  node.addSubnode(textNode)
  
  // update properties
  textNode.text = "test"
  node.backgroundColor = .red
  

  // Layout
  node.size = (100,100)
  textNode.center = node
  
  view.addSubview(node.view)

  ```
  
  ##### UIKit compare
 
  Panda                        |  UIKit                     
  -------------------------    |  --------------------
  ViewNode                     |  UIView                    
  ImageNode                    |  UIImageView              
  TextNode                     |  UILabel                   
  ControlNode                  |  UIControl
  ButtonNode                   |  UIButton
  StackNode                    |  UIStackView
  FlowLayout                   |  No
  
  There do have some difference to make Panda easy to use.For example ControlNode provides a `hitTestSlop` to expand hittest area.ButtonNode provides `space`,`layuotAxis`,`textFirst` to make it easy to control layout of Button Image and Text

  
2. *Background thread usage*
 
  if code if running in main thread ,frame and appearance for node  will update automaticlly.But if you want to layout from background and cache frame,  call `layoutIfNeeded()` ,then `var layoutValues: LayoutValues` will be what you want if your node hierarchy is not changed,then just pass it as a parameter for `apply(_ layout: LayoutValues)` in main thread.

3. *Integrate existing UIView subclass*

  use `LayoutNode` as a placeHolder,you can use your own UIView and take advantage of node layout
  
  Example:
   
  ```swift
    // XXVideoView will be initialized in main thread when first visit
    let videoNode = LayoutNode<XXVideoView> {
      let view = XXVideoView()
      return view
    }
    let node2 = ViewNode()
    node.left == node2.left
  ``` 

4. *Layout* 
   
   visit [Layoutable](https://github.com/nangege/Layoutable) for more about Layout API    
   visit [PandaDemo](https://github.com/nangege/PandaDemo)   for a full demonstration



## Todo
- Unittest
- TextRender cache control


