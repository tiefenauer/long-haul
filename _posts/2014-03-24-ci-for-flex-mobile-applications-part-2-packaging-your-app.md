---
id: 276
title: "CI for Flex Mobile Applications – Part 2: Packaging your App"
date: 2014-03-24T09:50:33+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=276
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
In this part of the tutorial we are going to package the compiled classes together with other external, non-compiling assets (e.g. image, audio, configuration files, ...) to get a package that is ready to be installed on mobile devices such as smartphones or tablets.

If you haven't done already, follow the steps described in [the first part of the tutorial]({% post_url 2014-03-18-ci-for-flex-mobile-applications-part-1-compiling-your-code%}) to get the compiled classes as an *.swf-File.

{% include toc.md %}

## The ADT Tool

ADT (Adobe AIR Developer Tool) is used to package the SWF and other, non-compilable assets together to an executable file. Its command line syntax is pretty straightforward and also consistent with the Ant task we are going to use. Again, for completness here's the command line syntax (also available by typing `adt -help` from the command line).

If you want to know more about the ADT command line syntax, have a look at the [official documentation](http://help.adobe.com/en_US/air/build/WS5b3ccc516d4fbf351e63e3d118666ade46-7fd9.html)
    
## Packaging for development or for release
If you want to test your application on individual devices before releasing them in the AppStore or the PlayStore, you can create an ad-hoc IPA file resp. a devloper version of your APK. This file can be installed on a limited set of devices for test purposes, without having the user visit the App- or PlayStore.

If you want to package your app for public release in one of the stores, you create an release version of your IPA respectively a release version of your APK. The only difference in the Build script is that you'll use different certificates for the two types. Additionally, you also need a separate provisioning profiles (<code>*.mobileprovision-</code>Files) to install application on files without having them released in the AppStore.

In this tutorial we assume you want a developer version of your app for installation on single devices. If you plan to build for release, simply  set up a new job or script which packages the files for release in the AppStore resp. PlayStore, just replace the paramters values for <code>OUTPUT.keystore.android</code>  and <code>OUTPUT.keystore.ios</code> in the <code>build.properties</code> file so that they point to the release certificates/provisioning profile.

You could also add new variables for release parameters (e.g. <code>OUTPUT.keystore.ios.release</code>) so you can keep both developer and release values. Or you could have separate <code>build.properties</code> files for developer-builds and release-builds. Whatever approach you may take, just make sure you don't forget to update the Passwords in the <code>build.properties</code> file and also set the path to the provisioning profile correctly.

## Step 1: Implementing the Ant task to package for Android
Unfortunately, there is no Ant task for the ADT command. But that's not a problem, since we can call any executable file with Ant's built-in <code>&lt;exec&gt;</code>-task. That's the approach we are going to use to call our ADT executable, which makes the Ant target for this step syntactically identical to its command-line counterpart.

Again, to give you a rough start, here's an Ant script to include in your build script. Just add any other assets folders you may have (and of course make sure the variables exist in your <em>build.properties</em> file and are correctly set).

## Step 2: Implementing the Ant task to package for iOS

This step is more or less the same as for Android.  The main difference is the different variable values for the certificates in the `build.properties` file (see above) as well as a <code>-provisioning-profile</code> parameter pointing to the <code>*.mobileprovision</code> file , which is only needed when packaging for iOS.

```xml
<!-- Package IPA file for iOS -->
<exec executable="${AIR.adt}" dir="${OUTPUT.build}" failonerror="true">
	<arg value="-package" />
	<!-- set the target to the type of package you want -->
	<arg value="-target" />
	<arg value="ipa-ad-hoc" />
	<!-- set the path to the *.mobileprovision file -->
	<arg value="-provisioning-profile" />
	<arg value="${OUTPUT.provisioning.adhoc}" />
	<!-- set the certificate type -->
	<arg value="-storetype" />
	<arg value="${OUTPUT.storetype.ios}" />
	<!-- set the path to the certificate -->
	<arg value="-keystore" />
	<arg value="${OUTPUT.keystore.ios}" />
	<!-- provide the password for the certificate -->
	<arg value="-storepass" />
	<arg value="${OUTPUT.storepass.ios}" />
	<!-- define file name of the generated IPA file -->
	<arg value="${OUTPUT.root}/${OUTPUT.name.ios}" />
	<!-- set the path to the application descriptor containing the reference to the *.swf file we created -->
	<arg value="${OUTPUT.build}/${PROJECT.app.name}-app.xml" />
	<!-- define the directory containing the Native Extensions (*.ane files) -->
	<arg value="-extdir"/>
	<arg value="${PROJECT.libs.ane}" />
	<!-- set the path to the *.swf file we created -->
	<arg value="${PROJECT.app.name}.swf" />
	<arg value="assets"/>
	<!-- add any other folders containing assets that were copied to the build directory during initialization -->
</exec>
```

## Step 3: Test everything out

As always, let's run our script to see if we get an APK and an IPA file. If you did everything correctly, you should have  two Apps in your target folder that are ready to be installed (more about how to set up links for test users to downlad and installs these files under Tipps and Tricks).
**Be aware: The packaging process for iOS file takes significantly longer than for Android (up to 20 minutes or even more, depending on the size of your app), so don't worry, if your job keeps hanging at "Packaging for iOS..." for a while.**

## What we did so far
In this chapter we extended our build script to package our compiled classes together with other assets into an executable file suitable for installation on Android or iOS devices.

When you're all set, continue with [Part 3: Performing Unit Tests]({% post_url 2014-04-03-ci-for-flex-mobile-applications-part-3-performing-unit-tests%}).