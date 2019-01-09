---
id: 606
title: 'Mockito + PowerMock – Part 2: Using Matchers'
date: 2015-03-29T13:02:39+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=606
categories:
  - Coding
tags:
  - junit
  - mock
  - mocking
  - mockito
  - powermock
series:
  - Mockito
toc: true  
---
In this chapter you will get to know some advanced techniques of Mockito such as Argument captors, spies, exception handlers and verifying method calls.

## Simple matchers

### Matchers for class type

If you want to stub out a parameterized method and you want it to return a specific value regardless of the parameter value, you can use the _any()_-Matcher.

```java
// have fooBar.getBar(Foo) return bar1 when being called with any object of type Foo.java
when(fooBar.getBar(any(Foo.class))).thenReturn(bar1);
```

### Matcher for object reference

If you want your method to return a value only when being called with a specific object reference as parameter value, you can use the _eq()_-Matcher.

```java
// have fooBar.getBar(Foo) return bar1 when being called with object foo
when(fooBar.getBar(eq(foo))).thenReturn(bar1);
```

## Using the built-in matchers

If the autocomplete feature in Eclipse does not work with the matchers used by Mockito (`any()`, `eq()`, etc.), try adding an autoimport reference in your settings (Window > Preferences > Java > Editor > Favorites):
    
![](/assets/img/wp-content/uploads/2015/03/img_5517f16d178c3.png)

Mockito comes with a set of built-in matchers. These are basically just syntactic sugar for primitive types and some common complex types as Strings, Lists and other:

* **Mockito matchers for primitive types**: `anyInt(), anyLong(), anyBoolean(), anyByte(), anyChar(), anyDouble(), anyFloat(), anyShort()`

* **Mockito matchers for complex types:** `anyString(), anyList()/anyListOf(), anyMap()/anyMapOf(), anySet()/anySetOf(), anyCollection()/anyCollectionOf(), anyVararg()`

These matchers for complex types  are only here for convenience and could also be implemented using the standard syntax. This means the following matchers are identical:

```java
anyString()
any(String.class)
```

## Custom Matchers

Sometimes it may be necessary to create a matcher, that compares objects using a more complex logic than object type, reference or primitive value. Take a method with a parameter of type String for example. You may want the method to return a specific value only when being called with a String of two characters length. You can build a custom matcher which will resolve to true if the parameter meets this criterion. The matcher is used for comparison each time the stubbed method is called.

```java
// create a matcher that resolves to String arguments of length=2
ArgumentMatcher<String> isStringOfLength2 = new ArgumentMatcher<String>() {
  @Override
  public boolean matches(Object argument) {
    return argument != null
        && argument instanceof String
        && ((String)argument).length() == 2;
  }
};

// have foo.getByString(String) return bar only when being called with a String of length=2
when(foo.getBarByString(argThat(isStringOfLength2))).thenReturn(bar);
```

## Using matchers on methods with multiple parameters

If you want to stub out a method with multiple parameters, make sure you use matchers on either all or none of the parameters. Mixing matched and un-matched parameters does not work and will result in a runtime exception. See the following code as an example:

```java
// Correct: foo.getBarByStringAndInt(String, int) is stubbed with matchers (matchers for every parameters)
when(foo.getBar(anyString(), eq(42))).thenReturn(bar);

// Wrong: Matchers are only used for some of the parameters. This will result in an exception
when(foo.getBar(anyString(), 42)).thenReturn(bar);
```

## What we have done so far

In this chapter you have learned how to use matchers in order to stub methods with one or more parameters. You have also learned how to build custom matchers to validate parameters using a more complex logic.