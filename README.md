<img src="../master/images/logo.png" align="left" width="128" height="128">

# UIBezierPath+Superpowers

A one-file extension library to add several cool features to `UIBezierPath`.
<br><br>

## Getting Started

This library consists of one single file. Gettings started is as easy as copying this file to your Xcode project.

### Prerequisites

Developed with Xcode 9 and Swift 4. Tested with Swift 3+. Works with Xcode 8 with some minor adjustments.

```
Xcode 8+
Swift 3+
```

### Installing

Copy `UIBezierPath+Superpowers.swift` to your project and you're good to go.


### Demo

The repo includes a demo project which lets you try out the features with different predefined paths.
Feel free to add your own `svg` files and extend the `Demo` enum respectively.

Note: The demo project was created with Xcode 9 beta 4.

<br>

## Features

This library adds several major features to `UIBezierPath`.

### Calculating path length

`var mx_length: CGFloat`

Returns the length of the path.


### Calculating bezier points

`mx_point(atFractionOfLength: CGFloat) -> CGPoint`

Returns for a given fraction the point on the path `fraction * pathLength` in to the path.

<img src="../master/images/point_demo.gif" width="256">


### Calculating perpendicular points and distances

`mx_perpendicularPoint(for: CGPoint) -> CGPoint`

Returns the closest point on the path to a given `CGPoint`, effectively letting fall a perpendicular on the path from `point` and returning the point of intersection.

<img src="../master/images/perpendicular_demo.gif" width="256">


### Calculating path slope and tangent angles

`mx_tangentAngle(atFractionOfLength: CGFloat) -> CGFloat`

For a given fraction, returns the tangent angle of the path at the point `fraction * length` in to the path.

<img src="../master/images/tangent_demo.gif" width="256">

<br>

## How it works

The backbone of it all is a function on `CGPath` called `apply(info:, function:)`. This basically lets you iterate
all elements a given `UIBezierPath` is constructed of.

#### Short aside: 
`UIBezierPath` and its Cocoa counterpart `NSBezierPath` are descriptions of bezier curves. 
These curves are basically a clever way of feeding line drawing instructions to computers. 
Bezier paths are composed of different types of path elements. Each element is either a straight line, quadratic curve or cubic
curve. At the end of the day, these curves boil down to mathematical functions which allows us to calculate things like
line lengths, tangent angles, etc.
If you are interested in more, there is a really well written and easy to understand article on [Wikipedia](https://de.wikipedia.org/wiki/Bézierkurve).


What this library does is pull out all elements a path is constructed of and throw some geometric math at them.
Since the extraction and initial computations are quite expensive, the results are cached internally if possible.

By default however, caching is disabled because - by design - the library lives in an `extension` and not a subclass of `UIBezierPath` and with that come some limitations regarding method overriding, internal vars, etc.
In order to enable the full superpower, you'll have to call `UIBezierPath.mx_prepare()`. This performs some runtime magic
under the hood which breaks the chains of `extension` and gives you full access to all features on *any* `UIBezierPath` object.

## Contributing

Feel free to build upon this project and / or submit a PR anytime.

<br>

## Authors

* *Maximilian Kraus*

<br>

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

<br>

## Acknowledgments

* [paulwrightapps](http://www.paulwrightapps.com/blog/2014/9/4/finding-the-position-and-angle-of-points-along-a-bezier-curve-on-ios)
* [ericasadum](http://ericasadun.com/2013/03/25/calculating-bezier-points/)
