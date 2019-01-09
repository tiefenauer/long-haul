---
id: 500
title: 'Mockito + PowerMock – Part 0: Introduction'
date: 2014-12-16T18:08:30+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=500
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
When running Unit Tests, a class under test usually has a lot of dependencies. Since Unit Tests are [meant to test a class in isolation](http://en.wikipedia.org/wiki/Unit_testing "Wikipedia: Unit Tests"), these dependencies often make it hard to test a class, since the dependencies have an influence on the state of an object. In some cases, these dependencies make unit testing impossible alltogether. But what if you could replace these dependencies and have them hehave exactly how you want in each tests? This is where Mockito and its bigger brother PowerMock come in. Both frameworks are described in this series.

The series consists of 6 parts:

* [Part 1: Simple Stubbing and Mocking](http://www.tiefenauer.info/mockito-powermock-part-1/ "Mockito + PowerMock: Part 1")
* [Part 2: Using Matchers](http://www.tiefenauer.info/mockito-powermock-part-2/ "Mockito + PowerMock: Part 2")
* Part 3: Advanced Stubbing and mocking
* Part 4: Spying and verifying assumptions
* Part 5: Mocking final, static and private methods
* Part 6: Triggering Exceptions

[Mockito](https://github.com/mockito/mockito) is hosted on GitHub. [PowerMock](https://code.google.com/p/powermock/) is hosted on Google Code, but is expected to change to GitHub too since Google [has decided to shut down their code hosting service](http://google-opensource.blogspot.ch/2015/03/farewell-to-google-code.html).

Some sample code for the steps in this tutorial can be found in my [own GitHub repository](https://github.com/tiefenauer/MockitoExample). It is an Eclipse project with two sample classes that are being tested using Mockito and PowerMock. The project comes with an included distribution of Mockito and PowerMock. This means that tests can be run out-of-the-box, but there may be newer versions of Mockito and/or PowerMock available. Feel free to fork and improve this project. Feedback is always welcome.

All set? Then let's start with some basic mocking.