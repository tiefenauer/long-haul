---
title: STT-Engine for Forced Alignment
layout: post
tldr: Some takeaway points from my Master Thesis. You can find the code <a href="https://github.com/tiefenauer/ip9" target="_blank">here</a> and the project report <a href="https://github.com/tiefenauer/ip9/raw/master/doc/p9_tiefenauer.pdf" target="_blank">here</a>. A short version is also available as a paper draft <a href="https://github.com/tiefenauer/ip9/raw/master/paper/p9_tiefenauer_paper.pdf" target="_blank">here</a>.
---

Forced Alignment is the name for the process of aligning chunks of text (e.g. parts from a transcript) with parts of a corresponding audio signal. This involves enriching the textual data with temporal data. The process is usually very time consuming because it is often done by hand. In my Master Thesis I introduce a method that reduces said time by producing alignments automatically. The result can be used as-is or with little manual adjustments. The method uses a pipeline which automatically detects voiced segments, transcribes them and aligns the partial transcript with the full transcript using Global Sequence Alignment. Transcriptions are produced by a Speech-To-Text (STT) engine building upon simplified architecture of the [DeepSpeech](https://github.com/mozilla/DeepSpeech) architecture. The main idea beind this is that Global Alignment can be done even if the partial transcripts match the ground truth only poorly. 

It has been shown that such transcripts can be obtained from a STT engine trained on as little as 80 minutes of training data. Funny enough, it is even possible to use a STT engine trained on another language and still get decend alignments.

I put all information on GitHub:

* [Code](https://github.com/tiefenauer/ip9)
* [Paper](https://github.com/tiefenauer/ip9/raw/master/paper/p9_tiefenauer_paper.pdf)
* [Project Report](https://github.com/tiefenauer/ip9/raw/master/doc/p9_tiefenauer.pdf)