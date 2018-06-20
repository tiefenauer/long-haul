---
id: 85
title: 'Windows 8.1: Move Libraries up'
date: 2013-08-13T13:24:25+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=85
cleanretina_sidebarlayout:
  - default
frutiful_posts_template:
  - "2"
categories:
  - Troubleshooting
tags:
  - "8.1"
  - explorer
  - library
  - windows
---
In Windows 8.1 Explorer, the "Libraries" node has moved below "This PC". Nobody knows why, but here's how to move them up again:

  1. Open Registry: Windows + R: regedit
  2. Edit Key: 
     `HKEY_CLASSES_ROOT\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}`
  3. Change value SortOrderIndex from `0x44` (54) to `0x38` (54)
  4. Done :smile:

&nbsp;