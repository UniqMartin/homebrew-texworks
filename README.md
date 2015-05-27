# TeXworks on OS X

The aim of this project is to ease building and developing [TeXworks](http://www.tug.org/texworks/) ([GitHub repository](https://github.com/TeXworks/texworks)) on OS X.

## Goals

* Simplify building TeXworks on OS X, focusing on OS X 10.9 and above.
* Provide an environment that makes it easier to contribute to TeXworks, thereby improving the experience on OS X.

## Status

This project is a work in progress. As it gets closer to reaching its goals, its documentation will be expanded and it will open up to external contributors.

## Known Issues

* The [Poppler](http://poppler.freedesktop.org/) libraries built by `tw-poppler-qt4.rb` and `tw-poppler-qt5.rb` contain a hard-coded path to the Poppler data that resides in the Homebrew prefix. Thus, built application bundles are not truly portable to other machines.

## License

Code is under the [BSD 2 Clause (NetBSD) license](https://github.com/UniqMartin/texworks-osx/blob/master/LICENSE.txt). Some files are adapted from [Homebrew](https://github.com/Homebrew/homebrew) as detailed in the license file.
