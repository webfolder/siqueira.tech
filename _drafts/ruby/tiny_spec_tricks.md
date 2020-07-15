---
layout: post
title: "Some tiny useful spec tricks"
date: 2019-11-24
published: true
categories: "programming"
---

{% include add_ref.html id="ruggedreset"
    title="Rugged reset"
    date="2020-06-28"
    url="https://www.rubydoc.info/github/libgit2/rugged/Rugged%2FRepository:reset" %}

{% include add_ref.html id="specdirfiles"
    title="Rugged reset"
    date="2020-06-28"
    url="https://stackoverflow.com/questions/12435610/testing-directory-exist-with-rspec" %}

{% include add_ref.html id="comparefiles"
    title="Compare two files with spec"
    date="2020-06-28"
    url="https://stackoverflow.com/questions/17583849/how-do-i-compare-two-text-files-with-rspec" %}

In this post I am going to discuss some simple spec tricks (some time trivials) but that always came handy when I have to implement test.

# Code Summary

**If you did not read this tutorial yet, skip this section. I added this
section as a summary for someone that already read this tutorial and just want
to remember a specific command.**
{: .info-box}

```ruby
expect(AN_OBJECT).to be_a AN_OBJECT
expect(Pathname.new('file.txt')).to exist
expect(Pathname.new('file.txt')).to be_file
expect(Pathname.new('dir')).to be_directory
expect(FileUtils.compare_file(file1, file2)).to be_truthy
```

# Overview

In this post I just want to list and discuss some simple spec tricks which I believe that is useful to keep in mind. You can find some of the example explained here in the Ogo project, but I am going to provide some code snippet for illustrating some of the tricks. Keep in mind that you need to install rspec.

# 

