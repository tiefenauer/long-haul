---
id: 252
title: "CI for Flex Mobile Applications – Part 1: Compiling your code"
date: 2014-03-18T19:21:22+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=252
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
In this first part of my tutorial on how to set up a CI process for your mobile app written with Flex I will show you how to compile your code. If you haven't already followed the steps described in [Part 0]({% post_url 2014-03-04-ci-for-flex-mobile-applications-part-0-the-setup %}) you should do so now before you start.

As a result of this second part we should get our compiled code in form of a *.swf-File which will contain the compiled classes (i.e. your application logic). This file can later be bundled together with other assets you may have (images, audio, config-files ...) as well as the AIR runtime, resulting in an *.ipa (iOS) or *.apk (Android) file for publication in the AppStore resp. PlayStore.

{% include toc.md %}

## The MXML-Compiler

To compile our *.mxml or *.as-Files we use the MXML-Compiler shipped with the AIR-SDK. You find it in the \bin-Folder of your Folder, where you store the Flex-SDK used to create your app (e.g. `C:\tools\sdk\flex\4.12.0_AIR4.0\bin`). You can run the compiler from the command line, if you like, but we will use an Ant-Target instead, which is much easier to read.

However, for the sake of completeness, here's the full command line syntax (also available from the command line by typing `amxmlc -help list`):

```
-benchmark
-compiler.accessible
-compiler.actionscript-file-encoding <string>
-compiler.advanced-telemetry
-compiler.compress
-compiler.context-root <context-path>
-compiler.debug
-compiler.enable-runtime-design-layers
-compiler.extensions.extension [extension] [parameters] [...]
-compiler.external-library-path [path-element] [...]
-compiler.fonts.advanced-anti-aliasing
-compiler.fonts.flash-type
-compiler.fonts.max-glyphs-per-face <string>
-compiler.include-libraries [library] [...]
-compiler.incremental
-compiler.library-path [path-element] [...]
-compiler.locale [locale-element] [...]
-compiler.minimum-supported-version <string>
-compiler.mobile
-compiler.mxml.compatibility-version <version>
-compiler.mxml.minimum-supported-version <string>
-compiler.namespaces.namespace [uri] [manifest] [...]
-compiler.omit-trace-statements
-compiler.optimize
-compiler.preloader <string>
-compiler.report-invalid-styles-as-warnings
-compiler.services <filename>
-compiler.show-actionscript-warnings
-compiler.show-binding-warnings
-compiler.show-invalid-css-property-warnings
-compiler.show-shadowed-device-font-warnings
-compiler.show-unused-type-selector-warnings
-compiler.source-path [path-element] [...]
-compiler.strict
-compiler.theme [filename] [...]
-compiler.use-resource-bundle-metadata
-compiler.verbose-stacktraces
-framework <string>
-help [keyword] [...]
-include-resource-bundles [bundle] [...]
-licenses.license <product> <serial-number>
-load-config <filename>
-metadata.contributor <name>
-metadata.creator <name>
-metadata.date <text>
-metadata.description <text>
-metadata.language <code>
-metadata.localized-description <text> <lang>
-metadata.localized-title <title> <lang>
-metadata.publisher <name>
-metadata.title <text>
-output <filename>
-runtime-shared-libraries [url] [...]
-runtime-shared-library-path [path-element] [rsl-url] [policy-file-url [rsl-url] [policy-file-url]
-static-link-runtime-shared-libraries
-swf-version <int>
-target-player <version>
-tools-locale <string>
-use-direct-blit
-use-gpu
-use-network
-version
-warnings
```

* For more help on the compiler options visit the [reference page](http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf69084-7a92.html)
* For general help on running the MXMLC compiler from the command line visit the [official documentation]http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf69084-7fcc.html)

## Step 1: Getting the Ant Task Definitions

In order for Ant to recognize the target we are going to use to run the MXMLC compiler we need to define the tasks first. Doing this is easy: Just add a `taskdef`-target on top of your script pointing to the `flexTasks.jar`-File lying in a sub-folder of your Flex SDK root.

```xml
<taskdef resource="flexTasks.tasks" classpath="${FLEX.root}\ant\lib\flexTasks.jar" />
```

The `FLEX_ROOT` property should be set in your `build.properties` file and point to the base directory of your Flex SDK.

## Step 2: Implementing the ANT-Script

An easier way to run the MXMLC command is via its ant target, which is syntactically similar to the command line. To compile your code with our build script we therefore simply have to include the target. The exact characteristics of the target are specific to your project. However, to give you a rough start, here's a sample of how it might look like:

```xml
<!-- MXMLC Ant target -->
<mxmlc file="${PROJECT.src.main}\${PROJECT.app.main}" output="${OUTPUT.build}\${PROJECT.app.name}.swf">
	<!-- load a configuration file with the default dependencies for mobile projects -->
	<load-config filename="${FLEX.root}/frameworks/airmobile-config.xml" />
	<!-- set the path in which to look for source files and assets of the application -->
	<source-path path-element="${PROJECT.src.main}" />
	<source-path path-element="${PROJECT.src.assets}" />
	<!-- include other source folders you may have -->

	<!-- include the following paths/libraries when compiling -->
	<library-path dir="${PROJECT.libs}" append="true">
		<include name="**/*.swc" />
	</library-path>
	<!-- include the ANE-Files (which were converted to *.swcs in initialization -->
	<library-path dir="${OUTPUT.build.ane}" append="true">
		<include name="**/*.swc" />
	</library-path>
	<!-- include any other library folders/SWCs you may use -->

	<compiler.verbose-stacktraces>true</compiler.verbose-stacktraces>
</mxmlc>
```

To find out more about the MXMLC Ant task visit the official documentation:</p>
    
* [About Flex Ant tasks](http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf678b2-7ffc.html)
* [Working with compiler options](http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf69084-7a63.html)
* [Using the mxmlc Ant task](http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf678b2-7ff3.html)
* [Adobe Flex Ant tasks](http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf678b2-8000.html)

## Step 3: Test everything out

To check whether we did everything correctly, simply run the job again. It should now run MXMLC via its Ant target and (if you don't have any syntax errors in your source code and resolved all the dependencies in the Ant script) produce a *.swf file in the _target_ folder.

## What we have done in this chapter

In this chapter we extended our build script to compile our code using  the Ant target for the MXMLC compiler. We now have a *.swf files containing the compiled classes, which can be used to package our app for development or release to different platforms.

When you're all set, continue with [Part 2: Packaging your app]({%post_url 2014-03-24-ci-for-flex-mobile-applications-part-2-packaging-your-app%}).