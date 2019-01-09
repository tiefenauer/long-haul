---
layout: default
title: Contact Me
---

<div id="contact">
  <h1 class="pageTitle">Contact Me</h1>
  <div class="contactContent">
    <p class="intro"><span class="dropcap">H</span>owdy, fellow traveller! Through the wondrous ways of the world wide web you have found your way to my blog. Want to get in touch? Drop me a line!</p>
  </div>
  <form action="http://formspree.io/daniel@tiefenauer.info" method="POST">
    <label for="name">Name</label>
    <input type="text" id="name" name="name" class="full-width"><br>
    <label for="email">Email Address</label>
    <input type="email" id="email" name="_replyto" class="full-width"><br>
    <label for="message">Message</label>
    <textarea name="message" id="message" cols="30" rows="10" class="full-width"></textarea><br>
    <input type="submit" value="Send" class="button">
  </form>
</div>


<script>
$( document ).ready(function() {
	// DropCap.js
	var dropcaps = document.querySelectorAll(".dropcap");
	window.Dropcap.layout(dropcaps, 2);
});
</script>