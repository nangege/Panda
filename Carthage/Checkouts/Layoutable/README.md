## Layoutable 

Layoutable is a swift reimplement of apple's Autolayout. It uses the same [Cassowary ](https://constraints.cs.washington.edu/cassowary/) algorithm as it's core and provides a set of api similar to Autolayout. The difference is Layouable is more flexable and easy to use.Layoutable don't rely on UIView, it can be used in any object that conform to Layoutable protocol and can be used in background thread which is the core benefit of Layoutable. Layoutable also provides high level api and syntax sugar to make it easy to use.

## Requirements
- iOS 8.0+
- Swift 4.2 

## Installation

[Layoutable](https://github.com/nangege/Layoutable) rely on   [Cassowary](https://github.com/nangege/Cassowary) library,you need to and both of the to your projetc.

- [Carthage](https://github.com/Carthage/Carthage) : github "https://github.com/nangege/Layoutable"

- Manually: drag Layoutable and [Cassowary](https://github.com/nangege/Cassowary) project file to your workspace 

Then add Layoutable and Cassowary framework to Linked Frameworks and Libraries

import Layoutable


## Usage

1. Define your own Layout Object
    ```swift
     import Layoutable
	
    class TestNode: Layoutable{
	  
	    public init() {}
	  
	    var size = CGSize.zero
	  
	    func addSubnode(_ node: TestNode){
	      subItems.append(node)
	      node.superItem = self
      }
	  
	  
	    // needed by Layoutable protocol
	    var manager: LayoutManager = LayoutManager()
	  
	    var intrinsicContentSize: CGSize {
	      return size
	    }
	  
	    weak var superItem: Layoutable? = nil
	  
	    var subItems = [Layoutable]()
	  
	    var frame: CGRect = .zero
	
	    func layoutSubnode() {}
	  
	    func updateConstraint() {}
	  
	    func contentSizeFor(maxWidth: CGFloat) -> CGSize {
	      return .zero
       }
     }

    ```

2. Use Layout object to Layout
    
    ```swift
    import Layoutable   
    
    // Layout node1 and node2  horizontalally in node,space 10 and equal center in Vertical
    
    let node = TestNode()
    let node1 = TestNode()
    let node2 = TestNode()
    
    node.addSubnode(node1)
    node.addSubnode(node2)
    
    node1.size == (30,30)
    node2.size == (40,40)
	  
    [node,node1].equal(.centerY,.left)  
    [node2,node].equal(.top,.bottom,.centerY,.right)
    [node1,node2].space(10, axis: .horizontal)
	  
    node.layoutIfEnabled()
	
    print(node.frame)       //  (0.0, 0.0, 80.0, 40.0)
    print(node1.frame)      //  (0.0, 5.0, 30.0, 30.0)
    print(node2.frame)      //  (40.0, 0.0, 40.0, 40.0)
    
    ```
    
## Operation

1. Basic attributes
  
    Like Autolayout, Layoutable support both Equal, lessThanOrEqual and greatThanOrEqualTo

    ```swift
     node1.left.equalTo(node2.left)
     node1.top.greatThanOrEqualTo(node2.top)
     node1.bottom.lessThanOrEqualTo(node2.bottom)
    ```
     or
	
    ```swift
     node1.left == node2.left   // can bve write as node1.left == node2  
     node1.top >= node2.top     // can bve write as node1.top >= node2
     node1.bottom <= node2.bottom // can bve write as node1.bottom <= node2
    
    ```
2. Composit attribute

   beside basic attribute such as  left,right, Layoutable also provide some Composit attribute like size ,xSide,ySide,edge
   
   ```swift
    node1.xSide.equalTo(node2,insets:(10,10))
    node1.edge(node2,insets:(5,5,5,5))
    node.topLeft.equalTo(node2, offset: (10,5))
      
   ```
   or
   
   ```swift
    node1.xSide == node2.xSide + (10,10) 
    //node1.xSide == node2.xSide.insets(10)
    //node1.xSide == node2.xSide.insets((10,10))
   
    node1.edge == node2.insets((5,5,5,5))
    // node1.edge == node2 + (5,5,5,5)
    
    node.topLeft == node2.topLeft.offset((10,5))
    
   ```
 
3. Set Priority

     ```swift 
     node1.width == 100 ~.strong 
     node1.height == 200 ~ 760.0
      ``` 
4. Update constant

    ```swift
    let c =  node.left == node2.left + 10
    c.constant = 100
    
    ```   
 
## Supported attributes


Layoutable                   |  NSLayoutAttribute
-------------------------    |  --------------------------
Layoutable.left              |  NSLayoutAttributeLeft
Layoutable.right             |  NSLayoutAttributeRight
Layoutable.top               |  NSLayoutAttributeTop
Layoutable.bottom            |  NSLayoutAttributeBottom
Layoutable.width             |  NSLayoutAttributeWidth
Layoutable.height            |  NSLayoutAttributeHeight
Layoutable.centerX           |  NSLayoutAttributeCenterX
Layoutable.centerY           |  NSLayoutAttributeCenterY
Layoutable.size              |  width and height
Layoutable.center            |  centerX and centerY
Layoutable.xSide             |  left and right
Layoutable.ySide             |  top and bottom
Layoutable.edge              |  top,left,bottom,right
Layoutable.topLeft           |  top and left
Layoutable.topRight          |  top and right
Layoutable.bottomLeft        |  bottom and left
Layoutable.bottomRight       |  bottom and right


## Todo
- complete unit test
- more convenice API
- playground example


