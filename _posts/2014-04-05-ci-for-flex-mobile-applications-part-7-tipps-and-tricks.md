---
id: 285
title: "CI for Flex Mobile Applications – Part 7: Tipps & Tricks"
date: 2014-04-05T11:38:55+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=285
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
In this part of the tutorial I'll collect some scripts and tipps you might find useful, after you have implemented the build script as described in the last chapters.

{% include toc.md %}

## Updating the build label automatically

If you want the `<buildLabel>` node in your application descriptor to contain the Build-ID used in Jenkins, you can use the following script:

```xml
<!-- Automatically set the build label in the app descriptor to the current Build-ID from Jenkins -->
<target name="editBuildLabel">
	<echo>Editing Build Label...</echo>
	<property name="versionLabelPattern"><![CDATA[<versionLabel>(.*?)</versionLabel>]]></property>
	<property name="substitutionPattern"><![CDATA[<versionLabel>${env.BUILD_ID}</versionLabel>]]></property>
	<echo message="Suche nach:  ${versionLabelPattern}" />
	<echo message="Ersetze mit: ${substitutionPattern}" />
	<loadfile property="desc" srcfile="${PROJECT.src}\\${PROJECT.app.desc}">
		<filterchain>
			<expandproperties/>
			<tokenfilter>
				<replaceregex pattern="${versionLabelPattern}" replace="${substitutionPattern}" flags="gs"/>
			</tokenfilter>
		</filterchain>
	</loadfile>
	<echo file="${PROJECT.src}\\${PROJECT.app.desc}">${desc}</echo>
	<echo>... done!</echo>

</target>
```

## Updating the TestRunner automatically

In case you have all your test classes in one folder (like me) you might find you wondering whether you could add all those classes to your TestRunner application each time before running the unit tests instead of having them to add manually each time you write a new test class. In short: you can! Just include the following macro in your build script and call it as the first macro before any other macros in your FlexUnit target.

```xml
<!-- update TestRunner application with unit classes to include -->
<macrodef name="update-runner">
  <!-- test classes to include -->
  <attribute name="testClassesSources" />
  <sequential>
	<!-- delete files containing import statements and array.push()-operations -->
  	<delete file="testsToRun.txt" />
  	<delete file="testsToImport.txt" />

	<!-- create import statements and array.push()-operations -->
    <for param="file">
        <path>
            <fileset refid="@{testClassesSources}"/>
        </path>
    	<sequential>
    		<local name="source"/>
    		<property name="source" value="@{file}"></property>
			<!-- convert path names to class names replacing the slashes with dots and dropping the file ending -->
    		<propertyregex property="baseDirEscaped" input="${basedir}\test\" regexp="\\" replace="/" global="true" override="true"/>
    		<propertyregex property="sourceEscaped" input="${source}" regexp="\\" replace="/" global="true" override="true"/>
    		<propertyregex property="withoutBaseDir" input="${sourceEscaped}" regexp="${baseDirEscaped}" replace="" global="true" override="true"/>
    		<propertyregex property="withoutFileExtension" input="${withoutBaseDir}" regexp="\.as" replace="" global="true" override="true"/>
    		<propertyregex property="replacedFile" input="${withoutFileExtension}" regexp="/" replace="." global="true" override="true"/>

			<!-- write import statements and array.push()-operations to separate files -->
    		<echo file="testsToRun.txt" append="true">
    			testsToRun.push(${replacedFile});</echo>
    		<echo file="testsToImport.txt" append="true">
    			import ${replacedFile};</echo>
        </sequential>
    </for>
	<!-- replace text between markers with generated import statements/array.push()-operations -->
  	<loadfile property="testsToRunInsert" srcfile="testsToRun.txt"></loadfile>
  	<loadfile property="testsToImportInsert" srcfile="testsToImport.txt"></loadfile>
	<replaceregexp file="src/TestRunner.mxml"
				   match="//UNIT_TESTS_IMPORT_START(?s)(.*)//UNIT_TESTS_IMPORT_END"
				   replace="//UNIT_TESTS_IMPORT_START${testsToImportInsert}//UNIT_TESTS_IMPORT_END"
					/>
	<replaceregexp file="src/TestRunner.mxml"
				   match="//UNIT_TESTS_ARRAY_START(?s)(.*)//UNIT_TESTS_ARRAY_END"
				   replace="//UNIT_TESTS_ARRAY_START${testsToRunInsert}//UNIT_TESTS_ARRAY_END"
					/>
  	<delete file="testsToRun.txt" />
  	<delete file="testsToImport.txt" />
  </sequential>
</macrodef>
```

Just extend your TestRunner application with code comments containing the phrases _UNIT\_TESTS\_IMPORT_START_ and _UNIT\_TESTS\_IMPORT_END _to define the start and end section where the import statements will be made.

Likewise, add two comments containing the phrases _UNIT\_TESTS\_ARRAY_START_ and _UNIT\_TESTS\_ARRAY_END_ to mark the sections where the test classes will be pushed into the array in the `currentRunTestSuite()`-function.

[Part 8]({% post_url 2014-04-06-ci-for-flex-mobile-applications-part-8-troubleshooting %}) contains some hints to consider when things go south.