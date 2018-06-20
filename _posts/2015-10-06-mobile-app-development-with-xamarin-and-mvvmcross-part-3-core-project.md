---
id: 633
title: 'Mobile App Development with Xamarin and MvvmCross – Part 3: Core project'
date: 2015-10-06T10:18:29+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=633
categories:
  - Coding
  - Mobile
tags:
  - Android
  - iOS
  - mobile
  - MvvMCross
  - Storyboard
  - Xamarin
series:
  - Mobile App Development with Xamarin and MvvMCross
---

In this article we are going to add some classes to our PCL project. These classes will contain the business logic for our app.

{% include toc.md %}

## Create new ViewModel

ViewModels are the foundation for MvX-based apps and represent the connection between the views in the UI projects and the business logic. To do their task, ViewModels often rely on the help of services, which contain shared logic between different ViewModels, such as reading and writing from/to a database. Additionally, ViewModels are at the core of navigation: Navigation in MvX is done over ViewModels, not views (we will see that this can be changed by using Storyboards in a later article). For each view in a UI project there is a corresponding ViewModel. MvX connects these two parts over reflection based on the class name. That means that for each view class called MyView.cs there must be a corresponding ViewModel class called MyViewModel.cs, which must inherid from MvxViewModel. in MvX, a view in a UI project can not be used without corresponding ViewModel.

A new ViewModel can be created by creating a class that extends MvxViewModel. This class can hold additional logic, properties and methods as required. The following class is just an example:

```csharp
public class MyViewModel : MvxViewModel
{
    /// <summary>
    /// A property
    /// </summary>
    public String MyProperty { get; set; }
    /// <summary>
    /// Another Property which will raise an event when changed
    /// </summary>
    private List<string> _myList;
    public List<string> MyList
    {
        get { return _myList; }
        set
        {
            _myList = value;
            RaisePropertyChanged(() => _myList);
        }
    }
    /// <summary>
    /// A public method
    /// </summary>
    /// <returns>a return value</returns>
    public String Foo()
    {
        return "Bar";
    }
    /// <summary>
    /// A private method
    /// </summary>
    /// <returns>a return value</returns>
    private int doSomething()
    {
        // Code here
        return -1;
    }

}
```

## Define app start

You can define as many ViewModels as needed. One specific ViewModel however must be defined as the main ViewModel and serve as central point of entry for the first app start. After adding MvvmCross as NuGet package you should have a file called App.cs in your PCL project. In this class you register the ViewModel used when starting the app as follows:

```csharp
public class App : Cirrious.MvvmCross.ViewModels.MvxApplication
 {
     public override void Initialize()
     {
         RegisterAppStart<ViewModels.MyViewModel>();
     }
 }
 ```

This will result in MvX selecting MyViewModel.cs as the main ViewModel for the first app start. MvX will load this ViewModel and search for a view called MyView.cs, which must exist in each of the UI projects. Lookup will be done in the MyProject.Droid or MyProject.iOS project, depending on the target platform, but a class with this name must exist, otherways app start will fail. We will see in the following articles, how such a view can be defined in each UI project.

## What we have done so far

In this article we have created our first ViewModel and defined it as the main ViewModel for app starts.