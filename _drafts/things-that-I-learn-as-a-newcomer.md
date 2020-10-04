---
layout: post
title:  "Things that I learned since I started to contribute to Linux Kernel"
date:   2017-02-26
published: true
categories: "linux-kernel-basic"
---

{% include add_ref.html id="gotos"
    title="Full Explanation of Dan Carpenter About gotos"
    url="https://lkml.org/lkml/2018/3/13/611" %}

{% include add_ref.html id="msg"
    title="Daniel Baluta providing some help with commit messages"
    url="https://lkml.org/lkml/2018/2/16/349" %}

{% include add_ref.html id="firstpatch"
    title="Kernel Newbies - First Kernel Patch"
    url="https://kernelnewbies.org/FirstKernelPatch" %}

{% include add_ref.html id="fix"
    title="My mistake on Fixes tag"
    url="https://lkml.org/lkml/2018/3/24/81" %}

{% include add_ref.html id="howtowritecommitmsg"
    title="How to Write a Git Commit Message"
    url="https://chris.beams.io/posts/git-commit/" %}

{% include add_ref.html id="firstPatch"
    title="My first patch to Linux Kernel"
    url="https://lkml.org/lkml/2017/12/5/407" %}

{% include add_ref.html id="canonicalFormat"
    title="he canonical patch format"
    url="https://www.kernel.org/doc/html/v5.1/process/submitting-patches.html#the-canonical-patch-format" %}

{% include add_ref.html id="srinivas"
    title="Srinivas review"
    url="https://lkml.org/lkml/2018/3/12/669" %}

{% include add_ref.html id="docfix"
    title="Describe your changes"
    url="https://www.kernel.org/doc/html/v4.12/process/submitting-patches.html#describe-your-changes" %}

{% include add_ref.html id="namemistake"
    title="Name mistake"
    url="https://lkml.org/lkml/2018/2/20/19" %}

{% include add_ref.html id="addreviewers"
    title="Add anyone who commented your patch"
    url="https://lkml.org/lkml/2019/6/19/146" %}

{% include add_ref.html id="usecorrectrepo"
    title="Add anyone who commented your patch"
    url="https://lkml.org/lkml/2019/6/15/182" %}

A few weeks ago, I was looking at my drafts when I found an old post from 2018
entitled "Things that I Learned as a Newcomer in the Linux Kernel", although
the content represents an interesting experience narrative, I did not publish
it (until now). Since the original post represents a snapshot of my learning
process, I decided to update it and finally share my experience hoping that
this content might be useful for someone. The key trait of this article
consists of analyzing a collection of mistakes made by my friends and me during
our interactions with the Linux kernel community; before we dive into this
subject, I want to highlight some points about:

* When I started to contribute to Linux Kernel, I did not know any kernel
  developer that could provide any guidance;
* Since I was alone, my primary source of information was the mailing lists,
  kernel docs, and IRC;
* I started to work with Linux Kernel during my master's. Unfortunately,
  contribute to Linux was seen negatively by professors because they believe
  this is a distraction from the research. In other words, in the beginning, I
  had to hide my work (I had a scholarship);
* Most of my work was conducted in my free time, which includes weekends.

From December 2017 until the present day, I had had a couple of patches
accepted to Linux Kernel, and I also became a VKMS maintainer, which means that
I accumulated a lot of feedback from the community and learned a lot from my
mistakes. I also helped create a group named FLUSP (FLOSS@USP) to spread the
free software culture in my home university. Based on that, in this post, I'm
drilling down some practical things that I learned from my contributions to the
Kernel and supporting newcomers. Some of the things that I discuss here are not
directly documented, or at least not explicit, which makes me emphasizes the
"soft" characteristic of this post.

Finally, in this article, I do not describe how to send patches or other basic
things. If you want to learn how to contribute, I strongly recommend you to
read a tutorial from kernelnewbies named
["First Kernel Patch"](https://kernelnewbies.org/FirstKernelPatch).

**Info:**
If you find any problem with this text, please let me know. I will be glad to
fix it.
{: .info-box}

# Do not send a new patch version as a reply to the old patch

**Quick Answer:**
If you got any feedback and prepared a new patch version, always send the latest version in a new thread.
{: .warning-box}

## Discussion:

When I got my first patch review {% include cite.html id="firstPatch" %} I
knew that I had to create another version of it and send it again to the
maintainer. Then I was tortured by the question: Should I reply to the original
patch or should I start a new thread? The Kernel Newbies tutorial gives a hint
that you should send a new email, but you know... when you are a newcomer, you
feel afraid of making mistakes, and you also suffer a little bit due to the lack of confidence (super normal). My second approach was looking at the Kernel mailing list
for finding some examples, for my surprise I found both cases! At this point, I was
more confused than ever. Then I decided to ask about this in kernelnewbies IRC; fortunately, someone gave me the final answer:

```
"USER> don't reply to the first one
5:28 PM people don't like that"
```

End of the topic! Simple like that.

# If you use goto, take care with labels

**Quick Answer:**
Do not add labels for direct return and do not use a large name for them.
{: .warning-box}

## Discussion:

When I was working on a patchset for trying to move a module out of staging, I
wrote the following code:

```c
...
static int ad2s1210_write_raw(struct iio_dev *indio_dev,
			      struct iio_chan_spec const *chan, int val,
			      int val2, long mask)
{
...
	switch (mask) {
	case IIO_CHAN_INFO_FREQUENCY:
		switch (chan->channel) {
		case FCLKIN:
			if (clk < AD2S1210_MIN_CLKIN ||
			    clk > AD2S1210_MAX_CLKIN) {
...
				ret = -EINVAL;
				goto error_ret;
...
		case FEXCIT:
			if (clk < AD2S1210_MIN_EXCIT ||
			    clk > AD2S1210_MAX_EXCIT) {
...
				ret = -EINVAL;
				goto error_ret;
...
	}
	ret = ad2s1210_update_frequency_control_word(st);
	if (ret < 0)
		goto error_unlock_mutex;
	ret = ad2s1210_soft_reset(st);
error_unlock_mutex:
	mutex_unlock(&st->lock);
error_ret:
	return ret;
}
...
```
{% include add_caption.html
  caption="Code 1: Excessive use of labels" %}

You can see the full patchset at {% include cite.html id="gotos" %}. Take a
careful look at the `goto` and the `case` statements. Instead of trying to elaborate
about this problem, I prefer to quote Dan Carpenter explanation in this issue:

> "[..]
This is a do-nothing goto.  I normally consider do-nothing gotos and
do-everything gotos basically cousins but in this case it's probably
unfair since it already has other labels.
>
> Do-everything gotos are the most error prone way of doing error
handling. I've reviewed a lot of static checker warnings and it really
is true. I can't give you like a percent figure but do-everything error
handling is a lot buggier than normal kernel style.
>
> This style of error handling is supposed to prevent returning without
unlocking bugs. I once looked through the git log and counted missing
unlock bugs and my conclusion was that it basically doesn't work for
preventing bugs. The kind of people who just add random returns will do
it regardless of the error handling style. There was even one driver
that indented locked code like this:
>
>	lock(); {
		blah blah blah;
	} unlock();
>
> When the driver was first submitted, it already had a missing unlock
bug. I don't think style helps slow people down who are in a hurry.
>
> The other thing about do-nothing gotos is that you introduce the
possibility of "forgot to set the error code" bugs which wasn't there
before.
[..]" {% include cite.html id="gotos" %}

Really nice explanation, hum?

# Take care with commit messages

**Quick Answer:**
Try your best to write a good commit messages
{: .warning-box}

## Description:

At the beginning of my interactions with Linux Kernel, I did not care as much
as I should with my commit messages. After some interactions with the
community, Daniel Baluta gave a feedback {% include cite.html id="msg" %} about
the way that I was writing my commit messages, and he helped me by
sharing a great post {% include cite.html id="howtowritecommitmsg" %} that describes how to write good commit messages. From his advice and the link, I
want to highlight my favorite rule of thumbs:

> The trick of "If applied, this commit will your subject line here".

There is one final advice which a newcomer should take care, see the comment
below:

> Use prefix tags to indicate the driver that is changed. Here
> iio:pressure:ms5611. {% include cite.html id="msg" %}

This comment aligns with the documentation since it recommends to use ":" for
separating the subsystem path {% include cite.html id="canonicalFormat" %};
however, this is not a strict rule. If you look at the Kernel mailing list you
will see a lot of variations about this rule. For example, take a look at
patches sent to the DRM subsystem, and you will notice the use of "/" instead
of ":". In this case, before you submit your patch, take a look at how other
developers send their contributions to the target subsystem and try to follow
the same pattern.

# Revise and revise your patch over and over again

**Quick answer:**
Review your own patch before sending it.
{: .warning}

## Discussion:

Sometimes, I was in a hurry to send a patch. You know... after you start to
contribute to Linux you get excited for sending more and more
patches. If you are a newcomer, avoid to hurry your patches submission;
Seriously, take a breath, wait a little bit, reread the patch line by line, eat some fruits... If
you're anxious that someone could send a similar patch, just relax, it is not
that common that someone posts a similar work for the same thing that you are
working on; it can happen, but seriously, this is really uncommon. If you carefully review your patch, you increase your chances to get your patch
accepted. I made this mistake a couple of sometimes, one of the best examples of this slip
can be verified in the code below:

```c
-	}, {
-		.type = IIO_ROT,
-		.modified = 1,
-		.channel2 = IIO_MOD_NORTH_TRUE_TILT_COMP,
-		.info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
-		.info_mask_shared_by_type = BIT(IIO_CHAN_INFO_OFFSET) |
-		BIT(IIO_CHAN_INFO_SCALE) |
-		BIT(IIO_CHAN_INFO_SAMP_FREQ) |
-		BIT(IIO_CHAN_INFO_HYSTERESIS),
-	}, {
-		.type = IIO_ROT,
-		.modified = 1,
-		.channel2 = IIO_MOD_NORTH_MAGN,
-		.info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
-		.info_mask_shared_by_type = BIT(IIO_CHAN_INFO_OFFSET) |
-		BIT(IIO_CHAN_INFO_SCALE) |
-		BIT(IIO_CHAN_INFO_SAMP_FREQ) |
-		BIT(IIO_CHAN_INFO_HYSTERESIS),
-	}, {
-		.type = IIO_ROT,
-		.modified = 1,
-		.channel2 = IIO_MOD_NORTH_TRUE,
-		.info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
-		.info_mask_shared_by_type = BIT(IIO_CHAN_INFO_OFFSET) |
-		BIT(IIO_CHAN_INFO_SCALE) |
-		BIT(IIO_CHAN_INFO_SAMP_FREQ) |
-		BIT(IIO_CHAN_INFO_HYSTERESIS),
-	}
+	HID_SENSOR_MAGN_3D_AXIS_CHANNEL(IIO_MAGN, IIO_MOD_X),
+	HID_SENSOR_MAGN_3D_AXIS_CHANNEL(IIO_MAGN, IIO_MOD_Y),
+	HID_SENSOR_MAGN_3D_AXIS_CHANNEL(IIO_MAGN, IIO_MOD_Z),
+	HID_SENSOR_MAGN_3D_AXIS_CHANNEL(IIO_ROT, IIO_MOD_NORTH_MAGN_TILT_COMP),
+	HID_SENSOR_MAGN_3D_AXIS_CHANNEL(IIO_ROT, IIO_MOD_NORTH_TRUE_TILT_COMP),
+	HID_SENSOR_MAGN_3D_AXIS_CHANNEL(IIO_ROT, IIO_MOD_NORTH_MAGN),
+	HID_SENSOR_MAGN_3D_AXIS_CHANNEL(IIO_ROT, IIO_MOD_NORTH_MAGN),
 };
```
{% include add_caption.html
  caption="Code 2: Diff of the patch with problem" %}

Take a careful look at the above diff; you do not need extra information to
find the error. :)

Srinivas {% include cite.html id="srinivas" %}, highlighted the error:

> It should be 
> HID_SENSOR_MAGN_3D_AXIS_CHANNEL(IIO_ROT, IIO_MOD_NORTH_TRUE)

Look again at the diff, but now pay attention to the last part. I made this error because I was
excited about the code reduction, and I want to send it as soon as possible for
no reason. If I waited one day, reviewed it again, probably I could notice the
problem.

# Every time you work in a driver, add the author in the email

**Quick Answer:**
Try to find the macro MODULE_AUTHOR or
take a look in the comments on top of the files to figure out who is the
original author. Always add the module author when submitting a patch.
{: .warning-box}

## Discussion:

Normally we work in someone else driver, and before we send the patch, we
can use the `get_maintainer.pl` to identify to whom we have to send the patch.
However, there's situation wherein the original author does not pop up from
`get_maintainer` script; because of this, it is a good idea to take a look at MODULE_AUTHOR macro.

Just to illustrate this situation, retake a look to the patch that I sent to
Srinivas (previous section), and you will note that I did not add him. Fortunately, Jonathan, the IIO subsystem maintainer, told me:

> Whilst this looks fine to me, I'd like Srinivas to take a look before
I apply it as this is his driver.  Please do make sure to cc the author.
Whilst many such email addresses bounce as they have moved on they
don't always.

# If you have to send someone work, you have to think who is the proper author of the patch carefully

**Quick Answer**
You have to examine if you modified the original patch or not. If you make
considerable changes in the original work, then you are the author otherwise
keep the original author. In any case, always ask the original author.
{: .warning}

## Discussion:

One day, Jonathan sent an email to the mailing list saying that he will drop a
driver named "meter" from staging because the chip is "Not Recommended for New
Designs". John Syne replied by saying that he had some fixes for the module, and
he also wants to help to improve/test the module. Finally, he added that he
could share his patches with anyone interested in updating the meter driver
with the goal of upstream it.

Since I was working in this module, I mailed him for talking about his patches.
In summary, I analyzed his work and updated some of his patches. Before
upstream the new code, I had to face the question: "Who is the author? John, or
me?". After a long time trying to figure out, I read the following statement
in the kernelnewbies documentation:

> Make sure that the email you specify here is the same email you used to set
up sending mail. The Linux kernel developers will not accept a patch where the
"From" email differs from the "Signed-off-by" line, which is what will happen
if these two emails do not match. {% include cite.html id="firstpatch" %}

After reading the quote above, I decided to send the patch with me as the
author and add John's signed-off-by. This decision was a __mistake__ because
John was the original author of the patch and I did not ask him about it. As a result, I had to prepare a new
version with John as the author of the original patches.

Sometimes it is obvious which approach to take, but another time, it is tough to decide it due to the
thin line between what makes you the author or not. Usually, if I'm in this
situation, I never change the original author unless he/she asks for it; I
think this 'rule' help me to stay out of troubles. Keep in mind, that I
probably overthink this issue due to my academic background wherein authorship
and correct use of reference is something essential from the ethical point of
view.

# Add "Fixes" tag if you fix a bug

**Quick Answer**
If you fixes something, do not forget to add the fixes tag
{: .warning-box}

## Discussion:

When I was working on John Syne patchset, I organized it by sending bug fixes
first. As a result of this bug fix series, Jonathan (IIO maintainer),
gave me the following feedback:

> [..] Also for these fixes ideally include a 'fixes' tag to the original
commit. It makes life easy for the scripts the stable maintainers use to work
out when things should apply.

Instead of going back to the documentation and carefully read about the Fixes
tag, I moved to git log and tried to find examples.  As a result, I sent
another patchset with the wrong way to handle Fixes; then, Jonathan said to me:

> Please look at the Submitting patches documentation.  This is not what a
fixes tag is about!  I'll fix it up this time but please look at it.
{% include cite.html id="fix" %}

I felt a little bit ashamed because I made the same
mistakes twice and also wasted Jonathan's time. Although my silly slips, now I
understand what I did wrong; basically I had to add something like this {%include cite.html id="docfix" %}:

> Fixes: <hash of previous commit fixes> ("message")

In my specific case, Jonathan added:

```
Fixes: 8d97a5877 ("staging: iio: meter: new driver for ADE7754 devices")
```

# Always add a cover letter in the patchset

**Quick Answer:**
Add a cover letter to all patchset you send
{: .warning-box}

## Discussion:

When I started to contribute, I sent a lot of simple cleanups patches, because of the simplicity of
this type of series, I had the following question in mind: "Do I really need to add a
cover letter for this simple patchset?". Before sending the patch without the
cover letter, I asked again in the kernelnewbies channel on IRC, the answer was
unanimous: sending patchset with cover-letter is always the right thing to do.

# Correctly configure your name in the gitt

**Quick Answer:**
Before sending a patch, check if your name and email are correct in your git setup.
{: .warning-box}

## Discussion:

My first Kernel patch has the author name written as "rodrigosiqueira". I did
not pay attention to this, maybe because it does not look wrong for me at first
glance. Then, Dan Carpenter alerts me about it {% include cite.html id="namemistake" %}. I fixed it by setting my name in my git global
configuration.

# If you resend patches, it is a good practice to add anyone who commented on it

**Quick Answer:**
If you resend patches, add everyone involved in the patch discussion
{: .warning-box}

I was working on a patch that changed the error status returned to the user
space; this sort of adjustment needs to be made carefully because it can break
the user space application. This sort of change is essential to get as much
feedback as possible, and fortunately, I got many comments; after that, I
prepared a new version and resend my patch. However, I did not add all people
who commented on the patch, which could increase my chances of getting my patch
ignored in the next review. Fortunately, Daniel gave the following feedback:

> when resending patches it's good practice to add anyone who commented
on it (or who commented on the igt test for the same patch and other way
round) onto the explicit Cc: list of the patch. That way it's easier for
them to follow the patch evolution and do a quick r-b once they're happy.
> 
> If you don't do that then much bigger chances your patch gets ignored.
> {% include cite.html id="addreviewers" %}

# Submit patches against the appropriate tree

**Quick Answer:**
Before you start to work in a new patch, make sure that you are using the
correct subsystem repository.
{: .warning-box}

Keep in mind that the Linux Kernel is divided into multiple subsystems where
each one has its independent repository. For example, the IIO subsystem
development happens at
https://git.kernel.org/pub/scm/linux/kernel/git/jic23/iio.git and the DRM at
https://anongit.freedesktop.org/git/drm/drm-misc.git. In other words, you have
to prepare your patch using the recommended repository for the specific
subsystem; otherwise, you may waste your time working in some outdated code. In
the example below, my friend Charlie send a patch to the networking subsystem,
but he was using Torvalds branch, see:

> This is already fixed in the 'net' GIT tree, please always submit networking
> patches against the appropriate tree. {% include cite.html id="usecorrectrepo" %}

# Conclusion

As I said at the beginning of this post, I had written most of this post a
couple of years ago, but I still believe that the information comprised here
can be useful for newcomers. I know that I left many other interesting topics
out of this discussion, but maybe in the future, I can compile another set of
things that I learned; or even better, perhaps one day you can write a similar
post but sharing your view.

{% include print_bib.html %}
