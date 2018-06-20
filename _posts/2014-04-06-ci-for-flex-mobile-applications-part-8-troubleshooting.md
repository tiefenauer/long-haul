---
id: 288
title: "CI for Flex Mobile Applications – Part 7: Troubleshooting"
date: 2014-04-06T12:02:49+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=288
frutiful_posts_template:
  - "2"
  - "2"
categories:
  - Coding
  - Technical
tags:
  - ant
  - as3
  - continuous integration
  - flex
  - jenkins
  - mobile
series:
  - Continuous Integration for Flex Apps
---
Here are some common problems you may run into when trying to set up a CI process for Flex Mobile Applications with Jenkins and Ant.

{% include toc.md %}

# My job keeps running and never finishes. After some time I get an Error "ERROR: Timeout after ... minutes"

This error can happen if your git client is not set up correctly. To fix it follow these steps:

1. First of all. Try if you can clone/fetch from your Github repository using git bash `git clone git@github.com:username/Project.git.` If this does not work, you must fix it by creating a new SSH key pair and adding the key to your Github account.
2. If your job still loops infinetely,  make sure, you added the path to your Git executable correctly under Jenkins > Manage Jenkins > Configure System
3.If your job still fails it is likely that Jenkins does not find the credentials you provided. Although your git client may work from a CLI, Jenkins runs under an own user and hence needs to know where the keys are. To do this you must create an environment variable called `HOME` pointing to your own Home directory (e.g. `C:\Users\Daniel`)

# In the packaging target I get an error "error 105: application.initialWindow.content contains an invalid value"

This is probably because you are using FlashBuilder as an IDE. When debugging or exporting a release package with FlashBuilder, FB replaces the `<initialContent>`-node in the application descriptor dynamically with the name of the *.SWF file it generated in its internal build process. You can see this when looking at the node in the application descriptor, containing the following value:

<pre>&lt;content&gt;[This value will be overwritten by Flash Builder in the output app.xml]&lt;/content&gt;</pre>

To get the packaging to work in Jenkins, the node in the application descriptor must contain the same name that is used as output in the compile-step (usually ${PROJECT.name}.swf). Otherwise, ADT won't know which SWF-File to link with the Application container. Simply change the node content to this value, and the packaging step should also work:

<pre>&lt;content&gt;MyApp.swf&lt;/content&gt;</pre>