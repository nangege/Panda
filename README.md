## What is Panda


Panda is a asynchronous render and layout framework which can be used to achieve high performance tableview. 

Panda is combined by 3 different component:

1. [Cassowary](https://github.com/nangege/Layoutable).  Core algorithm for constraint solving
2. [Layoutable](https://github.com/nangege/Layoutable). API  for 'Autolayout'
3. [Panda](https://github.com/nangege/Layoutable). Asynchronous display node.

## Why Panda
When it comes to  asynchronous render,many developr will think about [Texture](https://github.com/texturegroup/texture/), In facet, Panda learned a lot from [Texture](https://github.com/texturegroup/texture/), Panda's render process can be seen as a simplfy version of [Texture](https://github.com/texturegroup/texture/). But Panda does have it's advantages.Panda use 'Autolayout' for frame caculating which make it easy to learn compared to Texture's Flexbox.Panda is more lightweighted and usag is more close to system's API,it just cost little to integration. So,if you like swift,like autolayout ,want a high fps tableview and do't want to cost too much,Panda is for you. 


## Feature
- [x] Asynchronous render view
- [x] Autolayout Similar API with background thread usage ability
- [x] Comparable with existing UIView subclass
- [x] Pure swift implement

## Requirements
- iOS 8.0+
- Swift 4.2
- xcode 10.0

## Installation
[Carthage](https://github.com/Carthage/Carthage):  github "https://github.com/nangege/Panda" "master"

Add Cassowary , Layoutable and Panda to  to Linked Frameworks and Libraries



## Usage
You need to import both `Layoutable` and `Panda`,than just treat ViewNode as UIView,TextNode as UILabel,ButtonNode as UIButton ...

```swift
import Panda
import Layoutable

let node = ViewNode()
let textNode = TextNode()
node.addSubnode(textNode)
textNode.text = "test"

node.size = (100,100)
textNode.center = node
view.addSubview(node.view)

```

visit demo project [PandaDemo](https://github.com/nangege/PandaDemo) for more information.

## Know issuse
- There is some problem with touch handling
- remove node is not support yet,try hidden as a replacement

## Todo
- Unittest
- Node removable
- TextRender cache control


