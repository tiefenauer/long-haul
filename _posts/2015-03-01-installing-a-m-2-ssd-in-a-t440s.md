---
id: 538
title: Installing a M.2 SSD in a T440s
date: 2015-03-01T16:47:51+00:00
author: admin
layout: post
guid: http://www.tiefenauer.info/?p=538
categories:
  - Technical
tags:
  - lenovo
  - m.2
  - ssd
  - storage
  - t440s
  - upgrade
toc: true  
---
When I recently came to the point of upgrading the storage in my Lenovo T440s, I was looking for ways to do so. Luckliy, the T440s has an additional M.2 slot which allows for inserting various devices, including SSD hard drives. I followed [the instructions from a LaptopMag blog post](http://blog.laptopmag.com/install-m2-ssd-lenovo-t440s) for a large part. Since in my case upgrading storage meant replacing the built-in WWAN adapter, I wrote this blog post as an addendum to the one from LaptopMag.

## Step 1: Choosing the SSD

The first step – obviously – was buying an appropriate SSD. M.2 SSDs are pretty new to the game yet and therefore not as widely sold as their predecessors, the mSATA-SSDs. M.2-Disks come in various sizes and form factors, the T440s, however, only supports drives of 42mm width. **Make sure you choose the right form factor, since 42mm-drives are the <strong>only</strong> ones supported by the T440s!**

After reading various reviews though, it became clear, that [MyDigitalSSD](http://mydigitalssd.com/) would be the disk manufacturer of my trust, not only in terms of reputation or disk speed, but also because the prices were really competitive. I eventually went for the [MyDigitalSSD 256GB Super Boot Drive](http://mydigitalssd.com/sata-m2-ngff-ssd.php) and ordered it on [Amazon](http://www.amazon.com/MyDigitalSSD-256GB-Super-Boot-Drive/dp/B00NY4VIPA).

### Unboxing

The drive came in a box containing the drive itself along with a tiny screwdriver and a screw (which I didn't use since the T440s already has a screw inside holding the WWAN adapter). Thinking I've seen it all, I was still surprised how small and light the drive actually is. Only slightly larger than an ordinary SD card and weighing only a few grams, you will never notice the drive after updating – apart from the augmented disk space, of course ;-).

Below is a picture of the box the disk came in and a disk ontop of a credit card sized plastic. Unbeliavble how small these things have become...

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/box.jpg' | prepend: site.baseurl }}" alt="">
	<figcaption>The unopened box.</figcaption>
</figure>

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/unboxing.jpg' | prepend: site.baseurl }}" alt="">
	<figcaption>The opened box and its content</figcaption>
</figure>

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/2015-02-20-13.45.17.jpg' | prepend: site.baseurl }}" alt="">
	<figcaption>Size does not always matter: The M.2 SSD is **tiny**! SD card for comparison.</figcaption>
</figure>

## Step 2: Opening the case

**Before opening the case, make sure you have disabled the internal battery in the BIOS/UEFI and removed the external battery!**

To open the case I had to loosen the six screws indicated in [the LaptopMag post](http://blog.laptopmag.com/install-m2-ssd-lenovo-t440s).  Opening the case proved to be much harder than expected ("if you feel resistance, make sure all screws are completely loose"). What I didn't know is that the screws had tiny nuts on the inside of the case. These are meant to  prevent the screws from falling out of their holes and thus staying together with the bottom part of the case. This is actually a good thing meaning you can't really lose the screws. However, should you (like me) still manage to entirely remove the screws, you can/should re-attach their bolts before continuing. After all, you don't want to end up missing one of those tiny screws after upgrading your laptop.

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/screw.jpg' | prepend: site.baseurl }}" alt="">
	<figcaption>One of the screws to loosen...</figcaption>
</figure>

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/inside.jpg' | prepend: site.baseurl }}" alt="">
	<figcaption>The inner parts of the T440s</figcaption>
</figure>

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/wwan_adapter.jpg' | prepend: site.baseurl }}" alt="">
	<figcaption>WWAN adapter next to the WLAN adapter</figcaption>
</figure>


## Step 3: Removing the WWAN adapter and installing the disk

After prying open the case, I first had to remove two cables from the WWAN adapter. Luckily, those were not soldered to the device itself, so that I had no problem removing them using a pair of tweezers. I am not sure what the cables are for, but judging from their color (blue and red) I suspect for some sort of power source (or antenna?). So I covered the ends with duct tape for insulation, and stuck them to the black foil, since I didn't want to have loose power chords dangling around on the inside of my beloved T440s. After loosening one final screw and pulling out the WWAN-adapter I had a free M.2 slot. Installing the SSD was a breeze after that, requiring only inserting the disk into the slot and tightening the screw (the SSD is powered by the M.2 slot). That kind of flexibility is one thing I particularily like about Lenovo T-series laptops.

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/installed_disk.jpg' | prepend: site.baseurl }}" alt="">
	<figcaption>The M.2 SSD in its slot</figcaption>
</figure>

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/insulation.jpg' | prepend: site.baseurl }}" alt="">
	<figcaption>Make sure you insulate the ends of the cables and stick them to the laptop so they don't hang around freely</figcaption>
</figure>

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/wwan_adapter_removed.jpg' | prepend: site.baseurl }}" alt="">
	<figcaption>The removed WWAN adapter</figcaption>
</figure>

## Step 4: Formatting

After screwing the cover back to the laptop I came to restarting the computer and see if things worked as expected. I pushed the power button and... nothing happened. The screen stayed black and there was no sign of the computer booting up. I double checked the battery, which I had inserted after screwing everything together. After an initial panic attack (short circuit?)  I decided to put the laptop back into the docking station and booting up from there. To my relief, that did the trick and Windows booted normally. After consulting the UEFI one last time, it became clear that the internal battery would be re-enabled automatically after connecting the charger to the laptop. Seems like the laptop can only boot with the internal battery enabled... **Should your laptop remain dead after upgrading storage, plug in the power chord and try booting again by pressing the power button.**

Because the disk is brand new and not formatted for a particular file system, I had to do this myself by opening disk management (see <a href="http://pcsupport.about.com/od/tipstricks/f/open-disk-management.htm" target="_blank">this page </a>for instructions how to do so). There it way, the newly installed SSD. Before formatting I had to choose the partitioning style. I choose GPT and one click and two seconds later I was proud owner of a 512GB SSD T400s laptop. ***GPT is MBR's successor and has many advantages. You should choose GPT over MBR under any circumstances, unless you really know you still need MBR. See [this post](http://www.howtogeek.com/193669/whats-the-difference-between-gpt-and-mbr-when-partitioning-a-drive) for a more detailed explanations.**

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/MBR_or_GPT-150x150.png' | prepend: site.baseurl }}" alt="">
	<figcaption>Choose GPT in any case!</figcaption>
</figure>

## Step 5: Measuring performance

The first thing you want to do after installing a super-fast SSD is of course measuring its real performance and comparing it the the specs printed onto the packaging. The disk showed up as a 223GB drive in windows, so it is 33GB smaller than advertised (in terms of usable disk space) and almost 15GB smaller than the built in SSD  the T440s came with. Reviewing the photos for this post the reason became obvious immediately: They used a 240GB storage chip (as written on the sticker on the back), and not a 256GB one!

Before you start posting comments about the issue: **I know that the 256GB on the package are based on measuring using the decimal system.** The "real" usable disk space is usually measured in binary, meaning the 256 gigabytes (10-based) equal to approximately 238 gibibytes (2-based). I think manufacturers should really start using the binary system to indicate the disk space of their drives, since the discrepancy between the value on the package and the value shown by the operating system only leads to confusion of a lot of buyers.

I am a bit disappointed by the fact that the usable disk space is more than 6 percent smaller than indicated (and almost 13% smaller than printed on the package, taking that value for granted!).

In terms of speed, however, the disk pretty much lived up to the <a href="http://mydigitalssd.com/sata-m2-ngff-ssd.php" target="_blank">official measurement values </a>from the Homepage, performing sligthly better with bigger chunks and a bit slower on smaller chunks. Considering I had a few programs open while conducting the measurements, this drive should be blazing fast when reading and perform very well in most laptops. However, the writing speeds were somewhere around 190MB/s, never reaching the 430mB/s for any chunk size. This is also consistent with the official benchmark values from MyDigitalSSD.

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/performance.png' | prepend: site.baseurl }}" alt="">
	<figcaption>Benchmark results from CrystalMark 3.0.3</figcaption>
</figure>

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/performance_lenovo.png' | prepend: site.baseurl }}" alt="">
	<figcaption>The CrystalMark results of the built-in drive that came with the T440s. In my case it's a Samsung drive (MZ7TD256HAFV-000L9)</figcaption>
</figure>

<figure>
	<img src="{{ '/assets/img/wp-content/uploads/2015/03/mydigitalssd_benchmark.jpg' | prepend: site.baseurl }}" alt="">
	<figcaption>Official results for the 256GB Super Boot Drive</figcaption>
</figure>

## Conclusion

The Super Boot Drive sure is blazing fast when reading and also quite fast when writing, but never even coming close to the advertised 430MB/s writing speed. I don't know why MyDigitalSSD claim such high speeds when they can't even prove them in their own benchmarks.

_Update: I got a response from the manufacturer. The benchmark results are based on [ATTO](http://www.attotech.com/disk-benchmark/), not CrystalDiskMark. Considering the fact that the disk was even faster than advertised (see pictures above) using CrystalDiskMark as a benchmark tool, this disk performs as fast as promised._

On the other hand, the built-in Samsung drive that came with the T440s already seems to be reasonably fast, showing generally more balanced writing values over all chunk sizes than the MyDigitalSSD drive, sometimes even surpassing them. However, when writing small chunks the MyDigitalSSD outperforms the built-in drive.

What strikes me the most is the fact that MyDigitalSSD sell a drive as a 256GB when they evidentially attached a 240GB chip on it. Together with the falsy 10-based disk space (which manufacturers should do away with anyway) this leads to a significantly lower usable storage space than expected.

The decreased disk space is the result of a process called _overprovisioning_, which means a part of the disk is reserved to make up for broken storage cells. According to the manufacturer, this is common across all manufacturers nowadays. I'm still a bit disappointed thought, because I think when you buy a 256GB disk you should also get 256GB of usable disk space (as was the case with the built-in drive).

All in all, the Super Boot Drive is still an interesting option for people who want to upgrade their notebook storage without adding too much to the weight (and without their wallet losing too much weight :wink: ).

## Sources

* [Instructions from LaptopMag](http://blog.laptopmag.com/install-m2-ssd-lenovo-t440s)
* [MyDigitalSSD homepage](http://mydigitalssd.com/http://mydigitalssd.com/)
* [Drive on Amazon.com](http://www.amazon.com/MyDigitalSSD-256GB-Super-Boot-Drive/dp/B00NY4VIPA)
* [Difference between MBR and GPT](http://www.howtogeek.com/193669/whats-the-difference-between-gpt-and-mbr-when-partitioning-a-drive)
* [How to open disk management in windows](http://pcsupport.about.com/od/tipstricks/f/open-disk-management.htm)