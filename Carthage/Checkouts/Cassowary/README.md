# Cassowary


Cassowary is a swift implement of  constraint solving algorithm [Cassowary](https://constraints.cs.washington.edu/cassowary/) which  forms the core of the OS X and iOS Autolayout . This library is heavily inspired by this c++ implement  [rhea](https://github.com/Nocte-/rhea)

### Requirements
- iOS 8.0+
- Swift 4.2

### Installation

- [Carthage](https://github.com/Carthage/Carthage):  github "https://github.com/nangege/Cassowary"
- Manually: just drag this project to your workspace

Then add Cassowary to Linked Frameworks and Libraries

```
import Cassowary
```

### Usage
```
let v1 = Variable(),v2 = Variable, v3 = Variable()
let solver = SimplexSolver()
try? solver.add(v1 + v2 == 10)
try? solver.add(v1 - v2 == 2)
solver.solve()
print(solver.valueFor(v1)).  // 6
print(solver.valueFor(v2)).  // 4
```
### Todo
- complete unit test
- performance optimization
- more example


### Lisence

The MIT License (MIT)

Copyright (c) 2017-2018 nangezao  (https://github.com/nangege/)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


