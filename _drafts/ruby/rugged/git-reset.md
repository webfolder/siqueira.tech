---
layout: post
title: "Ogo & Rugged: git reset --hard"
date: 2019-11-24
published: true
categories: "programming"
---

{% include add_ref.html id="ruggedreset"
    title="Rugged reset"
    date="2020-06-28"
    url="https://www.rubydoc.info/github/libgit2/rugged/Rugged%2FRepository:reset" %}

Ogo provides mechanisms for chaging a repository that varies from simple file removal to changes a cirurgical change in the code. As a result, we constantly have changes in the stage area that needs to be removed and in this post I want to briefly discuss how we can achieve this goal using rugged.

# Code Summary

**If you did not read this tutorial yet, skip this section. I added this
section as a summary for someone that already read this tutorial and just want
to remember a specific command.**
{: .info-box}

```bash
r = Rugged::Repository.discover('PATH/TO/REPO')
r.reset('HEAD', :hard)
```

# Overview

In the early staging of the Ogo development, I implemented a feature that removes files and directories based on a metadata file that tells Ogo how to drop some targests. For testing this feature, I have the below stpes:

1. Programatically setup a base repository;
2. For each test I need to run a setup function that prepare a fake repository to receive the action;
3. At the end of each test I need to clean up change;

Here I faced a simple problem: *How can I run `git reset --hard` in Rugged way?*. If you are working directly in a git repository, this task should not take more than 3 seconds, however, since I did not have experience with Rugged at that time, I can say that this simple task took me 20 minutes to find a solution. In the end, it is a very trivial work, however, lets discuss how use Rugged for reset changes.

# Preparing a fake repository

First of all, create or clone any repository, for example:

```bash
cd /tmp
git clone https://github.com/kworkflow/kworkflow.git
cd /kworkflow
```

Now remove a bunch of files or directories, for example:

```bash
rm README.md
rm -rf documentation
```

# Using the equivalent to git reset --hard

Since this is something simple to achieve, let's use `irb` for this tutorial.

```bash
irb
2.6.3 :001 > require 'rugged'
2.6.3 :002 > r = Rugged::Repository.discover('./')
2.6.3 :003 > r.reset('HEAD', :hard)
```

TODO: Explicar outras coisas e elaborar mais os exemplos

# Conclusion


