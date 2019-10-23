---
layout: post
title:  "FLUSP"
date:   2019-10-12
categories: misceleneous
published: true
---

FLUSP

In November 2018, I wrote a post about my attempt to create a local Kernel community, since that post, I promised to write a summary of the results. Now it’s time! First of all, I will introduce the history of a Brazillian FLOSS group named FLUSP; next, I’ll describe some of the projects wherein the members are engaged, later I’ll brief the group achievements, and finally I’ll share my conclusions.

# The rise of FLOSS at USP (a.k.a FLUSP)

This history starts with Paulo Meirelles, my friend and who taught me about free software philosophy, challenging me to share my limited knowledge in Linux Kernel development with students from the University of São Paulo (USP). I have to admit that I was not comfortable with the idea of coaching a bunch of undergraduate because I knew how bound was my Linux kernel knowledge, at that time I had less than one year of experience with the Kernel. Finally, he used some compelling argument to persuade me to accept the challenge; the most important one was:

“Before you start to dig into the Linux kernel community, there wasn’t any kernel developer at USP. If you do not share your knowledge, we will lose the opportunity to foster free software at USP.”

The students which I would assist was the ones that attended a course named “Agile development methods”. This class relies on external clients that should introduce any real-world software to the students to convince them to work on their project. Clients have a five-minute presentation for trying to earn the student's heart; after all clients presentation, the students shall vote in which software they want to work along the semester. In this context, I was one of the clients that proposed a project in the IIO subsystem. I decided by IIO due to the driver's simplicity and the incredibly kind maintainer. However, I did not romanticize the work in the Linux Kernel; actually, I did my best to make clear that commitment and good C skills are mandatory. On the other hand, I also highlighted the benefits they could have from this experience. For my delight, six great and self-motivated student decided to onboard this project; none of them never contributed to any sizeable free software project.

In the first month of the project, I was close with the students by teaching them the essential contributing steps. I taught how the project is organized, how to compile and install a new kernel version, how to use git in the kernel way, how to prepare a patch, and finally, I instructed them to send their first lintian fixes to the staging. Next, we started to dive into the IIO subsystem by taking a look at its internal and their drivers in the staging area; our project goal was simple: move drivers from the staging area. In summary, at the end of the course, the students moved three drivers from staging and contributed to many other drivers in the IIO. I have to admit, at the end of the semester, I was thrilled with the results! The students learned really fast, and in a couple of months, they were totally comfortable with the IIO subsystem.

After this fantastic experience, we became good friends that share the desire of spreading the free software idea and projects with other students. As a result, we decided to create a student group for fostering free software contributions in the University of São Paulo (USP); after some discussions, we defined our values and our group name: FLOSS at USP (FLUSP). I want to highlight that our group is fully horizontal without a professor supervisor or leader and most of the time focused on code contributions. Finally, we created a logo that represents our group based on the pet (a parrot) of one of our friends; Figure X shows our logo evolution.

<<Figura com a evolução do Mr. FLUSP>>

I’m glad to say that we have a full-fledged free software group that contributes for multiple projects, such as GNU/Linux, Git, and GCC; currently, some of the members trying to get in Debian community.  We also promote special events such as kernel and git workshops.

# Projects

As aforementioned, FLUSP started focused on Linux Kernel contributions; however, our group has multiple members with different passions, which make some of them start to contribute with other communities. I want to highlight the work of four students: Matheus Tavares, Giuliano Belinassi, Marcelo Schmitt and Renato Geh.



Matheus Tavares started his contributions to the free software communities by working hard for moving a driver named ads1200 from staging to the kernel mainline. Working in the Linux kernel did not attracted him very much, however, after his experience working with git, he got curious about git community and started to dig on it. After many efforts, he started to contribute to git project and got selected as an intern to work in the Google Summer of Code (GSoC) project. He’s mission is really interesting: make git thread-safe for later parallelize some of its features. He also works hard for spread his knowledge in the git project with other students from USP.
 
Since the first time that I met Giuliano Belinassi, he showed his interest in compilers field and I tried to encourage him to focus on GCC project. He started to look in GCC with the goal of finding his own itch to scratch, first he started by working on float point operations. However, he wants more, he want to parallelize GCC! As a result, he started to dig really hard on the issue and proposed a GSoC project related with this issue, and of course, he got accepted. These days he make a lot of progress in his GSoC project, and he also teach some students how to contribute to GCC.

Finally, Renato and Marcelo kept their work in the IIO subsystem. Renato worked really obdurately for updating YYYY and move it from staging to the Linux Kernel mainline; consequently, he became the YYYY maintainer. Marcelo is the sort of guy that enjoy to work with electronic devices which make him to following in love with the IIO subsystem. After his experience by moving XXXX from staging, he decided to apply for the GSoC project with the goal to write a driver from scratch for UUUU. These days, he is totally dedicated to IIO and teach new members in the FLUSP to contribute in this subsystem.

# Achievements

