---
id: 114
title: Updating WordPress on a Synology NAS
date: 2014-02-16T11:49:45+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=114
frutiful_posts_template:
  - "2"
categories:
  - Troubleshooting
tags:
  - synology
  - wordpress
---
If you are running WordPress on your own Synology NAS (such as this website is) you may encounter problems when trying to update a plugin, theme or WP itself.If your update process hangs during the "unpacking"-step, this may likely have to do with file ownership.

As in my case, I entered my FTP-Credentials correctly and the update process could download the update for a specific plugin. However, the process somehow stopped and never finished (no error, no page update, just somehow stuck in "unpacking update...").

![wordpress update hangs](/assets/img/wp-content/uploads/2014/02/wp1-300x56.png)

This is how I fixed it:

* ssh as **root** into your NAS
* change file-ownership of your WordPress-instance to 'nobody'

```
chown -R nobody:nobody /volume1/web/wordpress
```


After that, updating anything worked like a charm:

<a href="/assets/img/wp-content/uploads/2014/02/wp2.png" rel="lightbox[114]"><img src="/assets/img/wp-content/uploads/2014/02/wp2-300x170.png" alt="wordpress update success" width="300" height="170" /></a>

The problem is with the file/folder owner. By default the web server software uses 'nobody' as the file/folder owner, when you install wordpress using a network share(like I did) the system assumes resets the name of the file owner to that of the login you used to access the share preventing the web server software making any changes, that's the reason why the automatic update feature doesn't work, even if you input the correct FTP login information in wordpress.