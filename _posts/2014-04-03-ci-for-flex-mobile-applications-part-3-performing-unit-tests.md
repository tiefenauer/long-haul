---
id: 279
title: "CI for Flex Mobile Applications – Part 3: Performing Unit Tests"
date: 2014-04-03T19:46:20+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=279
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
  - FlexUnit
  - jenkins
  - mobile
  - testing
series:
  - Continuous Integration for Flex Apps
---

In this third part of the tutorial we are going to set up our build process to perform automated unit tests. The results are the transformed into a readable format in HTML and can also be included in your job dashboard to see the status of the last build at a glance.

{% include toc.md %}

# Some background

In order to run the Unit Tests and write the results to a report in a format that can be used in Jenkins for display we need to write our own TestRunner-Application.

If you use Flash Builder as your IDE, the Premium version integrates running FlexUnit tests and displaying the results in a separate view. The method Flash Builder uses is the same: When you add your first unit test, Flash Builder automatically imports all the neccessary libraries and creates two applications: a FlexUnitApplication and a FlexUnitCompilerApplication, each one represented by a MXML file with the same name and an app descriptor with the "-app.xml"-suffix. The latter one is simply here to make sure all the test classes are taken into account when running the tests via context menu > "Execute FlexUnit Tests". It is updated automatically for each run or on request.

The first  application Flash Builder creates is the  Application which  is actually used to  run the tests. It adds an XML Listener, which produces output in XML format which is then parsed for display in the FlexUnitView.

We are going to follow a very similar aproach to run our unit tests. However, we can't use the FlexUnitApplication from FlashBuilder for CI purposes, because we need a different Listener for our purposes and then run all our tests. We are going to write a (very) simple TestRunner-Application which does exactly this: Adding a CIListener (instead of a XMLListener) and running all of our tests.

We can even extend our build script to automatically update the Application in order to run all unit tests without having to manually add them to the TestRunner-Application each time we have a new test. But this is a topic in the last chapter, where I'll provide you with some useful tips and tricks to make your CI-life easier.

But first, let's get started with getting the right tools.

# Step 1: Getting the FlexUnit libraries

[FlexUnit](https://github.com/flexunit/flexunit) is an open source project, which is still actively developed. Just clone the repository into a directory of your choice and run the build script by navigating to the root repository with a command line and typing "ant". This will compile and tests all of the sub-projects into separate libraries. In some cases, this can be quite cumbersome, because you need to have an environment variable pointing to a Flex SDK of your choice (possibly the latest one) and you need to have the Debugger version of Flash Player set as the default application to open *.swf files. You might also need to open the command line as an Administrator and run the build script repeatedly.

However, since we're only going to need a part of the FlexUnit project, just make sure you get the following two *.swc-libraries:

* [flexunit-cilistener-4.1.0-x.y.y.y.y.swc](https://github.com/tiefenauer/FlexCITutorial/blob/master/flexUnit/libs/FlexUnitAIRcilistener.swc)
* [FlexUnitAIRCIListener.swc](https://github.com/tiefenauer/FlexCITutorial/blob/master/flexUnit/libs/flexunit-cilistener-4.1.0-x-y.y.y.y.swc)

I won't go through the hassle of describing every single step needed to compile the FlexUnit projects, but should you not be able to get the two libraries mentioned above, you can always get them from my GitHub repository by clicking the links above. However you have to take into account that these files might be outdated by the time you're reading this!

## Step 1: Writing a TestRunner Application

As stated above, our TestRunner-Application is a simple application along with the application descriptor with the following structures:

```xml
<?xml version="1.0" encoding="utf-8"?>
<s:Application xmlns:fx="http://ns.adobe.com/mxml/2009"
			   xmlns:s="library://ns.adobe.com/flex/spark"
			   creationComplete="application1_creationCompleteHandler(event)"
			   >
	<fx:Script>
		<![CDATA[
			import mx.events.FlexEvent;

			import org.flexunit.listeners.AirCIListener;
			import org.flexunit.runner.FlexUnitCore;

			import test.MyUnitTest;
			//... (import more tests here)

			private var core:FlexUnitCore;
			protected function application1_creationCompleteHandler(event:FlexEvent):void
			{
				core = new FlexUnitCore();
				core.addUncaughtErrorListener( systemManager.loaderInfo );
				core.addListener(new AirCIListener());

				core.run( currentRunTestSuite() );
			}

			public function currentRunTestSuite():Array
			{
				var testsToRun:Array = new Array();
				testsToRun.push(MyUnitTest);
				// ... (add more tests here)
				return testsToRun;
			}

		]]>
	</fx:Script>

</s:Application>
```

What this application does is simply registering a CI-Listener, take a number of classes, add them to a test suite and then run that test suite with the CI-Listener producing the output. Just make sure you add all your Test Classes, that you want to include, in the `currentRunTestSuite()`-function.

In [Part 5: Tipps&Tricks]({% post_url 2014-04-05-ci-for-flex-mobile-applications-part-7-tipps-and-tricks %}) I'll show you how to automate this step so that all test classes inside a certain folder are automagically included in your test runner!

## Step 2: Defining the FlexUnit Tasks

In order to get ant to recognize `<flexUnit>` as a valid ant task, we need to import the task definitions (as we did with the mxmlc-Task).

```xml
<!-- Task definition for FlexUnit -->
<taskdef resource="flexUnitTasks.tasks">
    <classpath>
        <fileset dir="${TEST.build}">
            <include name="flexUnitTasks*.jar" />
        </fileset>
    </classpath>
</taskdef>
```

The value of the `${TEST.build}`  variable is defined in our `build.properties` file.

## Step 3: Adding to the build the script

In order to keep the build script readable, we are going to separate the steps needed to perform the unit tests into the following steps, whereas each step is represented as a separate macro in the build script:

* Compile our TestRunner application (`compile-runner` macro)
* Execute the tests using our TestRunner application (`execute-tests` macro)
* Generating HTML reports (`generate-html-reports` macro)

### Compiling the TestRunner application (macro)

This macro simply compiles our TestRunner application together with all the test classes into a *.swf file, which can then be executed with the `<flexunit>`-target. You'll notice that this macro contains another mxmlc-target, which is structurally identical with the one we use to compile our app.

```xml
<!-- Compile a TestRunner application -->
<macrodef name="compile-runner">
  <!-- MXML file to compile -->
	<attribute name="runner" />
	<!-- output file name -->
	<attribute name="swf" />

	<sequential>
		<mxmlc file="@{runner}" output="@{swf}" static-link-runtime-shared-libraries="true" >
			<load-config filename="${FLEX_HOME}/frameworks/airmobile-config.xml" />

			<source-path path-element="${basedir}/src" />
			<source-path path-element="${basedir}/assets" />
			<!-- include any other directories that contain assets used in the test classes here -->

			<!-- include libraries used in the test classes -->
			<library-path dir="${basedir}\libs" append="true">
				<include name="**/*.swc" />
			</library-path>
			<!-- also include the converted native extensions, if they are used in the test classes -->
			<library-path dir="${OUTPUT.build.ane}" append="true">
				<include name="**/*.swc" />
			</library-path>

			<!-- include other libraries that are used by a FlexUnit application-->
			<library-path dir="${TEST.lib}" append="true">
				<include name="@{include}" />
				<include name="*cilistener*.swc" />
				<include name="fluint*.swc" />
				<include name="*flexcoverlistener*.swc" />
				<include name="FlexUnit1Lib.swc" />
				<include name="hamcrest-as3*.swc" />
				<include name="mock-as3.swc" />
				<include name="mockolate*.swc" />
			</library-path>

			<!-- some other compiler options -->
			<compiler.verbose-stacktraces>true</compiler.verbose-stacktraces>
			<compiler.headless-server>true</compiler.headless-server>
		</mxmlc>
	</sequential>
</macrodef>
```

### Executing the unit tests (macro)

This macro executes the Ant-target for FlexUnit, taking our compiled TestRunner-swf as an input and producing the output in the directory specified in _reportdir_.

```xml
<!-- execute a TestRunner application -->
<macrodef name="execute-tests">
  <!-- path to the compiled application SWF file -->
	<attribute name="swf" />
	<!-- directory in which to write the reports -->
	<attribute name="reportdir" />
	<sequential>
	  <!-- execute the Ant task for FlexUnit -->
		<flexunit swf="@{swf}" timeout="180000" player="air" toDir="@{reportdir}" haltonfailure="false" verbose="true" />
	</sequential>
</macrodef>
```

### Generating the HTML reports (macro)

When the _execute-tests_-macro has finished running its test, it has produced a number of XML files in the specified directory. These files can now be converted to HTML, which is much more user-friendly to read.

```xml
<!-- Generate a test report in HTML -->
<macrodef name="generate-html-report">
  <!-- source directory containing the XML files -->
	<attribute name="dir" />
	<!-- target directory which will contain the HTML files -->
	<attribute name="todir" />
	<sequential>
	  <!-- execute Ant target to create test report -->
		<junitreport todir="@{dir}">
			<fileset dir="@{dir}">
				<include name="TEST-*.xml" />
			</fileset>
			<report format="frames" todir="@{todir}" />
		</junitreport>
	</sequential>
</macrodef>
```

## Step 4: Putting it all together

Now that we split our unit test task into single steps using the macros above, combining them is simple. Just add the following script under the unit tests task which we prepared earlier and which is still empty:

```xml
<!-- Collect Unit Test classes -->
<fileset dir="test" id="unit-test-classes">
     <include name="**/*Test.*"/>
     <include name="**/*TestSuite.*"/>
</fileset>

<!-- compile TestRunner-application with unit test classes -->
<compile-runner runner="src/TestRunner.mxml" swf="${OUTPUT.flexUnit.bin}/TestRunner.swf" include="flexunit*flex*.swc" useflex="true" />
<!-- execute compiled TestRunner-application -->
<execute-tests swf="${OUTPUT.flexUnit.bin}/TestRunner.swf" reportdir="${OUTPUT.flexUnit.results}" />
<!-- convert generated report XML-files to HTML -->
<generate-html-report dir="${OUTPUT.flexUnit.results}" todir="${OUTPUT.flexUnit.results}/html" />
```

Note that we first need to define the classes to be included in the TestRunner application. Luckily , using Ant's built-in `<fileset>`-task makes this part a breeze. Just make sure all your test classes end with ..._Test_.


# Step 5: Test everything out

As before (you may have guessed it), we're going to see if what we did actually works by executing the build script with ant. This should produce a number of files in the flexUnit output directory.

## What we did so far

In this chapter, we wrote a simple application to run our unit tests, compiled it together with the test classes and ran it to get the test report in both XML and HTML.

When you're all set, continue with [Part 4: Generating ASDOC]({%post_url 2014-04-03-ci-for-flex-mobile-applications-part-4-generating-documentation%}).