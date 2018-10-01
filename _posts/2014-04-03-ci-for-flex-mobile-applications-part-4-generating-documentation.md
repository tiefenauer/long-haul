---
id: 282
title: "CI for Flex Mobile Applications – Part 4: Generating documentation"
date: 2014-04-03T20:21:21+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=282
frutiful_posts_template:
  - "2"
  - "2"
categories:
  - Coding
  - Technical
tags:
  - ant
  - as3
  - asdoc
  - continuous integration
  - flex
  - FlexUnit
  - jenkins
  - mobile
series:
  - Continuous Integration for Flex Apps
---
Now that we have compiled, packaged and tested our app, it is high time we create a documentation for our app – automatically of course. For this step to work you should have commented your classes, functions and variables with the ASDOC syntax. Otherwise, the ASDOC-compiler will not recognize the comments and not be able to produce the documentation.

The good thing is that if you dutifully described your code with ASDOC comments, you get the documentation virtually for free – and it's also **very** similar to compiling the code as we did in [the first part]({%post_url 2014-03-18-ci-for-flex-mobile-applications-part-1-compiling-your-code%}) of this tutorial, since it's only a special way of compiling the code not into a \*.swf or \*.swc file but in a set of HTML documents to put in a directory (or Jenkins in our case). That's the reason why this part of the tutorial is the shortest of all.

{% include toc.md %}

## The ASDOC command line tool

The command line syntax of asdoc is very similar to the mxmlc syntax. You can always get this list by typing `asdoc -help list`:

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
-date-in-footer
-doc-classes [class] [...]
-doc-namespaces [uri] [...]
-doc-sources [path-element] [...]
-examples-path <string>
-exclude-classes [class] [...]
-exclude-dependencies
-exclude-sources [path-element] [...]
-footer <string>
-framework <string>
-help [keyword] [...]
-include-all-for-asdoc
-left-frameset-width <int>
-lenient
-licenses.license <product> <serial-number>
-load-config <filename>
-main-title <string>
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
-package-description-file <string>
-packages.package <string> <string>
-runtime-shared-libraries [url] [...]
-runtime-shared-library-path [path-element] [rsl-url] [policy-file-url] [rsl-url
] [policy-file-url]
-static-link-runtime-shared-libraries
-swf-version <int>
-target-player <version>
-templates-path <string>
-tools-locale <string>
-use-direct-blit
-use-gpu
-use-network
-version
-warnings
-window-title <string>
```

If you want to know more information about the asdoc command line tool and its options, visit [the official documentation](http://help.adobe.com/en_US/flex/using/WSd0ded3821e0d52fe1e63e3d11c2f44bc36-7ffa.html). For general help on commenting code using the ASDOC syntax, visit [the official documentation](http://help.adobe.com/en_US/flex/using/WSd0ded3821e0d52fe1e63e3d11c2f44bb7b-7fe7.html).

## The ASDOC Ant task

As with the mxmlc compiler, the ant task is very similar to its command line counterpart.

```xml
<!-- generate documentation from ASDOC formatted comments -->
<asdoc output="${OUTPUT.doc}" lenient="true" failonerror="true" warnings="false"
		strict="false" locale="en_us" fork="true"
		window-title="${DOC.title}" main-title="My App" footer="${DOC.footer}"
	>
	<!-- load default libraries used in mobile projects -->
	<load-config filename="${FLEX.root}/frameworks/airmobile-config.xml" />
	<!-- specify the path to the root package of the classes you want to create documentation for -->
	<doc-sources path-element="${PROJECT.src}" />
	<!-- ... add more paths here if needed -->

	<!-- specify the path to the classes for the asdoc compiler to resolve dependencies referenced in your documented classes -->
	<compiler.source-path path-element="${PROJECT.src}" />
	<!--... add more paths here if needed -->

	<!-- add paths to directories containing libraries used by your project -->
	<external-library-path dir="${PROJECT.libs}" >
		<include name="*.swc" />
	</external-library-path>
	<!-- ... add more paths here if needed -->

	<!-- this library is needed by some applications and not included by default by airmobile-config.xml -->
	<external-library-path dir="${FLEX.root}/frameworks/libs/air">
		<include name="airglobal.swc"/>
	</external-library-path>

</asdoc>
```

For more information on the ASDOC Ant task, visit [the official documentation](http://help.adobe.com/en_US/flex/using/WSda78ed3a750d6b8f4ce729f5121efe6ca1b-8000.html).

## Test everything out

Now let's run our build script. If we did everything correct, we should get a nice doc-folder in our target directory containing a bunch of HTML files. Just open index.html to see an overview.

## What we did so far

In this chapter we extended our script to run the ASDOC-compiler, which generates a code documentation in the HTML format instead of a *.swf file.

When you're all set, continue to [Part 5: Static Code Analysis]({% post_url 2014-04-04-ci-for-flex-mobile-applications-part-5-static-code-analysis %})