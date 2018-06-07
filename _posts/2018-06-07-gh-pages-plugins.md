---
title: GitHub Pages with custom plugins
layout: post
---

It has been some time since [I moved my blog from Wordpress to Jekyll]({{ site.baseurl }}{% post_url 2018-02-22-bye-bye-wordpress-hello-jekyll %}). This blog is now hosted on [GH pages](https://pages.github.com/) and jusing [Jekyll](http://jekyllrb.com). Unfortunately, GH pages only supports a [limited subset](https://pages.github.com/versions/) of the many Jekyll plugins there are out there. This was not a problem until today, where I wanted to use the [Jekyll-Maps plugin](https://ayastreb.me/jekyll-maps/) to display post locations on a map. I need this plugin for my new category  [Swiss Frenzy](switzerland) on which I am placing locations from various posts on a map.

Installing the plugin on my computer and running the server locally was no problem - the map showed up and everything else still worked nice too. However, pushing the changes to GH caused the build to break which resulted in the Blog not being updated. The URL under [http://www.tiefenauer.info](http://www.tiefenauer.info) still showed the version before the changes.

Until today I could live with the few plugins that were supported. However, this might only be one of many plugins that I might want to use in the future. So I started looking for ways to mitigate the problem. Of course the easiest solution would be to build the site locally and only push the compiled files to GH. This would work since then GH would not recognize the repository as a Jekyll project, but merely a bunch of static HTML files - no building needed on GitHub.

I started looking for ways to do this and found [this post](https://www.sitepoint.com/jekyll-plugins-github/) by David Lyons, suggesting keeping source and compiled (site) files in separate directories and manually copying the files over from one directory to the other. However, this would most likely mean keeping the source files also in separate repositories. But I don't want maintain two repositories for what  actually belongs together. Luckily I found [this question](https://stackoverflow.com/questions/28249255/how-do-i-configure-github-to-use-non-supported-jekyll-site-plugins) (linked from [this question](https://stackoverflow.com/questions/36377865/locally-building-and-pushing-jekyll-site-to-github-pages)) on StackOverflow. In the accepted answer the steps are required to keep both source and compiled files in the same directory and repository. The process is roughly as follows:

1. Initialize an new repository with a remote pointing to your GH repository. You are now on master branch. Checkout a new branch `sources`
1. Set up a new Jekyll project. Add some content (blog posts or the like).
1. Build the Jekyll project. A new folder `_site` is created containing the compiled site ready to be served. Ignore this directory by putting it in a `.gitignore` file.
1. Commit the files. Since `_site` is ignored the `sources` branch will now contain only the source files, but no compiled files. You can now push this branch to GH pages. Since GH pages only serves from the master branch, you will not see anything when navigating to _http://username.github.io_.
1. Change to the newly created `_site` folder and initialize another repository with **the same remote** as in the first step. You are again in the master branch.
1. create a `.nojekyll` file inside the `_site` folder preventing GH pages to build anything. While still in the `_site` folder, commit and push this file together with the compiled source files (already there from the build in step 3). Since nothinng was commited before, the master branch now only contains the compiled files.The site will now be served from _http://username.github.io_.

That way, you can keep working on the source files in your `source` branch (in the root directory) and push the files from the `master` branch (in the `_site` directory). You only have to take care not to switch to the `master` branch in your root directory and accidentally commit any source files as this might trigger a Jekyll build on GH again.

Although this method involves keeping separate branches of the same repository being checked out in different folder, this seemed the easies method for me. Unfortunately, the steps apply only when setting up a brand new blog with Jekyll. In my case, I already had a lot of source files on the `master` branch. I therefore had to adjust the steps a bit:

1. Ignore the `_site`-folder (if not already done). Checkout a `source`-branch and push it to GH (no changes made). The master and the source branch in the remote repository are now identical. The master branch might trigger build errors, but we will solve that in the next steps.
1. In the project root directory checkout the `master` branch again: Trigger a new Jekyll build to update the site files in `_site`.
1. In the `_site` directory: add a `.nojekyll` file but do not initialize a repository here.
2. In the root directory: delete everything except the `.gitignore` file, the `_site` folder and some IDE-specific metafiles (which were gitignored in my case)
1. Copy all files from `_site` one level up to the project root directory. The `_site` folder should now be empty and can be deleted.
1. Commit the changes (actually we have replaced the entire project) and push them to GitHub. Since the `master` branch now only contains the compiled files, no builds are made and the newest site version (built in step 2) will be served. Because the build was run locally, there are no problems with unsupported plugins on GH.
1. Copy all the compiled site files **including the `.git` folder** to a backup folder on your hard drive. Since we changed the commit history, we must also include the  `.git` folder.
1. Still in your project root directory: Switch back to the `sources` branch. All the source files should be there again.
1. Make sure there is no `_site` folder (delete it, if there is). Create the folder manually and copy the compiled site files including the commit history from your backup folder. You now have the repository on `sources` branch in your project root folder and the same repository on the `master` branch in your `site` folder.

## The new workflow

Rebuilding the project on `sources` branch in the project root will update the files in the `_site` directory and therefore provide changes for the `master` branch. Those changes can now be committed and pushed by changing to the `_site` directory and committing/pushing from there. It is not as conveniend as always working in the same directory, but I think this effort is manageable. In detail, when writing new posts, the workflow is as follows from now on:

1. Create the post, including assets etc.
1. In the project root directory: build the site and commit everything to the `sources` branch
1. Change to the `_site` directory and commit/push the changes generated in the previous step to the `master` branch
