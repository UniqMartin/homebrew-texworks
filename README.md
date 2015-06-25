# TeXworks on OS X

The aim of this project is to ease building and developing [TeXworks](http://www.tug.org/texworks/) ([GitHub repository](https://github.com/TeXworks/texworks)) on OS X.

## Goals

* Simplify building TeXworks on OS X, focusing on OS X 10.9 and above.
* Provide an environment that makes it easier to contribute to TeXworks, thereby improving the experience on OS X.

## Status

This project is a work in progress. As it gets closer to reaching its goals, its documentation will be expanded and it will open up to external contributors.

## Known Issues

* The [Poppler](http://poppler.freedesktop.org/) libraries built by `tw-poppler-qt4.rb` and `tw-poppler-qt5.rb` contain a hard-coded path to the Poppler data that resides in the Homebrew prefix. Thus, built application bundles are not truly portable to other machines.

### Qt 4 Build

* While still being functional, Qt 4 is no longer in active development. This results in various visual glitches and many smaller annoyances in recent OS X releases and on systems with a Retina Display.

### Qt 5 Build

* Closing all windows removes the “Quit TeXworks” menu item from the TeXworks menu. Quitting TeXworks is still possible via, e.g., the menu of the Dock icon.

* The toolbar control for selecting the typesetting tool shows visual artifacts. Functionality is not affected.

* The proxy icon in both the source and PDF preview window titles is not functional. It neither shows the correct path in the context menu nor can it be dragged.

## License

Code is under the [BSD 2 Clause (NetBSD) license](https://github.com/UniqMartin/texworks-osx/blob/master/LICENSE.txt). Some files are adapted from [Homebrew](https://github.com/Homebrew/homebrew) as detailed in the license file.
