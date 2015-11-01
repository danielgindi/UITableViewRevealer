UITableViewRevealer
===================

A revealer for the UITableView - shows hidden views like timestamps in iMessage app. 

Usage:

* If you are on ObjC, please `#import "PROJECTNAME-Swift.h"`
* Call `tableView.setupRevealerAtPosition(.Right)` or `tableView.setupRevealerAtPosition(.Left)` (ObjC: `[self.tableView setupRevealerAtPosition:UITableViewRevealerPositionRight/Left]`)
* In `cellForRowAtIndexPath`, set the cell's `revealerViewAttached` property to `true`/`YES` if it is the cell that moves with the revealed view, or `false`/`NO` if it should be overlaid with the revealed view.
* Set the cell's `revealerView` property to any `UIView` that has a `frame` set. It will be added to the cell automatically and managed automatically, do not worry about that.

Drag you table to the left (or to the right, if you've set the opposite direction), and watch the nice views getting revealed.


## Me
* Hi! I am Daniel Cohen Gindi. Or in short- Daniel.
* danielgindi@gmail.com is my email address.
* That's all you need to know.

## Help

If you like what you see here, and want to support the work being done in this repository, you could:
* Actually code, and issue pull requests
* Spread the word
* 
[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CHRDHZE79YTMQ)

## License

All the code here is under MIT license. Which means you could do virtually anything with the code.
I will appreciate it very much if you keep an attribution where appropriate.

    The MIT License (MIT)
    
    Copyright (c) 2013 Daniel Cohen Gindi (danielgindi@gmail.com)
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
