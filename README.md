BOTableViewControllerHelper
===========================

BOTableViewControllerHelper allows you to quickly setup table views without having to directly deal with delegates and data sources.

Requirements
============

BOTableViewControllerHelper works on any iOS version, non-ARC projects.

Usage
=====

The usage is very simple. Take a look at the bundled demo project and you'll realize how it works.

Installation
============

The simplest way is to directly add the `BOTableViewControllerHelper.h` and `BOTableViewControllerHelper.m` source files to your project.

1. Download the latest code version from the repository (you can simply use the Download Source button and get the zip or tar archive of the master branch).
2. Extract the archive.
3. Open your project in Xcode, than drag and drop `BOTableViewControllerHelper.h` and `BOTableViewControllerHelper.m` to your Classes group (in the Groups & Files view). 
4. Make sure to select Copy items when asked. 

If you have a git tracked project, you can add BOTableViewControllerHelper as a submodule to your project. 

1. Move inside your git tracked project.
2. Add BOTableViewControllerHelper as a submodule using `git submodule add git://github.com/boherna/BOTableViewControllerHelper.git BOTableViewControllerHelper`.
3. Open your project in Xcode, than drag and drop `BOTableViewControllerHelper.h` and `BOTableViewControllerHelper.m` to your Classes group (in the Groups & Files view). 
4. Don't select Copy items and select a suitable Reference type (relative to project should work fine most of the time).

License
=======

This code is distributed under the terms and conditions of the MIT license. 

Copyright (c) 2012 Bohdan Hernandez Navia

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.