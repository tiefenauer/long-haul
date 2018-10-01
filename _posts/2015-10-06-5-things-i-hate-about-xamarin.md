---
id: 710
title: 5 things I hate about Xamarin
date: 2015-10-06T11:54:12+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=710
categories:
  - Personal
  - Technical
tags:
  - visual studio
  - Xamarin
---
While it's probably not a terribly good idea to rant about [Xamarin](https://xamarin.com/) when you're in the middle of writing an article series about Xamarin, I just need to get this off my chest.

1. **Its lack of documentation**: Sure, there's the [official API reference](https://developer.xamarin.com/api/) for Xamarin.Android, Xamarin.iOS, Xamarin.Forms and the rest of the pack. But has anybody ever really been able to use it?  Clicking on some links leads to a 404-page and some of the descriptions are simply missing (see [this example](https://developer.xamarin.com/api/namespace/Android.Service.Media/)). It doesn't look like the missing parts are ever being delivered at a later stage. Together with the confusing layout it makes the documentation unusable for me. I often found myself searching on [Stackoverflow](http://stackoverflow.com/) rather than the official documentation, whose best use case is probably the [different tutorials](http://developer.xamarin.com/) and inspect the sample projects found there. But don't you dare to try something that's not included there... You may end up with grey hair. All in all not what I expect when signing up for an expensive membership, that has to be renewed yearly.
2. **The lack of a proper IDE**: Xamarin comes shipped with [Xamarin Studio](https://xamarin.com/studio), a kind of reduced version of [Visual Studio](https://www.visualstudio.com/). Thing is: If you're (like me) used to working in Windows, it's not really an option, because it can't be used to develop iOS apps. For Windows PCs, this is only possible with VS2012+. Visual Studio is a hugely popular among .NET developers (probably _the_ IDE for C#.NET), who won't stop praising the alleged superiority of VS over other IDEs almost religiously. But don't you get me started about VS... For my taste it is by far too slow and unresponsive to be used productively (I have VS2013 with Resharper installed). Seeing the different views pop up and populate one after each other after opening a solution is just not what a developer should get used to nowadays. VS has grown too big and complex to be used nowadays. This is also reflected in the disk space consumtion (9.64 GB (!!!) for VS2013) and the startup time (45 seconds on my not-so-old machine, making it the Godzilla of all IDEs I have come to know so far. What on earth are you doing, Microsoft?
3. **This little fellow**:

![](/assets/img/wp-content/uploads/2015/10/img_5613b3dc0b251.png)

I frequently encountered this problem when trying to debug an app in the iOS simulator. Apparently VS keeps waiting until kingdom come for something background operation to finish. The only way to get around this is kill the process in the process explorer. Just one of many examples
 that make VS2013 crash when developing with Xamarin...

4. **The lack of a mature framework**: Sure, there's [MvvmCross](https://mvvmcross.wordpress.com/) and  [Xamarin.Forms](https://xamarin.com/forms) out there. But while MvvmCross' documentation is just too rudimentary for a beginner to get started (forcing you to watch an endless series of YouTube videos and digging into the sample projects, hoping to find the solution for your problem there), Xamarin.Forms suffers the disadvantages of a <a href="https://en.wikipedia.org/wiki/Convention_over_configuration" target="_blank">Convention over Configuration</a> framework: You have to make sure the documentation is up to date, complete and easy enough to understand, even for beginners. I'm talking about general concepts here, not sample tutorials that document one specific aspect how to use the framework. And documentation is clearly not one of the points where Xamarin excels (see first point).
5. **The cryptic console output**: There are endless possibilities that can make your app crash. While most of the time this may be your fault (you probably used the framework the wrong way, because out of pure desperation and in lack of a proper documentation you had to try something out), the console output is neither formatted (syntax highlighting, links to code, ...) nor written in a way to easily find out what went wrong. There's no other way than scrolling through the whole log by hand, trying to make sense what's relevant and what isn't. After all, the cause for the crash may be buried deep inside the logged output...</ol>

I have rarely seen a combination of such an immature product with such a high price. Probably FlexBuilder (from my good ol' days with <a href="http://flex.apache.org/" target="_blank">Apache Flex</a>) is a worthy competitor, considering that Adobe even had the nerve to build its own IDE on top of Eclipse (which is open source) and sell it for more than 700 bucks. Blame it on the developer not being smart enough to handle the tool given, but the learning curve for Xamarin is far too steep for beginners to pick up. I'd rather expect products like Xamarin to be a low-threshold service – and that's clearly not the case today!

EDIT: Apparently I'm not the only one struggling with Xamarin. According to [this post](https://www.reddit.com/r/dotnet/comments/3dpqwu/how_good_is_xamarin/) a lot of fellow programmers had expectations way too high for Xamarin to fulfill. After an update, I spent the an entire afternoon trying to get a Xamarin app to work on iOS (that used to work before), without success. There's simply no efficient way to work with a product that seems to be stuck in pre-beta stadium. Dear Xamarin Developers, please finish Xamarin and do your homework before charging people hundreds of bucks for a SINGLE license (not to speak of Xamarin University, which will only set you back $2000)!!

**Conclusion:** Buggy as hell, crappy documentation and ridiculously expensive.