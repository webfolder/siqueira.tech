---
layout: post
title:  "FLUSP"
date:   2019-10-12
categories: misceleneous
published: true
---

{% include add_ref.html id="tavaresgsoc"
    title="GSoC"
    url="https://matheustavares.gitlab.io/posts/gsoc-final-report" %}

{% include add_ref.html id="gccparalleize"
    title="Giuliano: Prallelize GCC"
    url="https://www.phoronix.com/scan.php?page=news_item&px=Parallelize-GCC-Cauldron-2019" %}

In November 2018, I wrote a post about my attempt to create a local Kernel
community, since that post, I promised to write a reporting about this
experience. Now it’s time! First of all, I will introduce a Brazillian FLOSS
group named [FLUSP](https://flusp.ime.usp.br/); next, I’ll describe some of the projects wherein the members
are engaged, later I’ll brief the group achievements, and finally I’ll share my
view.

## The rise of FLOSS at USP (a.k.a FLUSP)

This history starts with my friend Paulo Meirelles (he introduced me to the
free software philosophy); he challenged me to share my limited knowledge in
Linux Kernel development with students from the University of São Paulo (USP).
I have to admit that I was not comfortable with the idea of coaching a bunch of
undergraduates because I knew how bound was my Linux kernel knowledge; at that
time, I had less than one year of experience with the Kernel. Finally, he used
some compelling argument to persuade me to accept the challenge; the final
argument was:

> Before you start to dig into the Linux kernel community, there wasn’t any
 kernel developer at USP. If you do not share your knowledge, we might lose
 the opportunity to foster free software at USP.

The students that I had to assist were the ones that attended a course named
"Agile development methods". This class relies on external clients that should
introduce any real-world software to convince students to work on their
project. Clients have a five-minute presentation for trying to earn the
student's heart; after all the client's presentations, students shall vote in
which software they want to work along the semester. In this context, I was one
of the clients that proposed a project in the IIO subsystem; I decided by IIO
due to the driver's simplicity and the super kind Jonathan Cameron (IIO
maintainer). However, I did not romanticize the work in the Linux Kernel;
actually, I did my best to make clear that commitment and good C skills are
mandatory for this project. On the other hand, I also highlighted the benefits
they could have from this experience. For my delight, six great and
self-motivated students decided to onboard this project; none of them
contributed to any sizeable free software project before this.

In the first month of the project, I was close to the students by teaching them
the essential contributing steps. I showed how the project is organized, how to
compile and install a new kernel from the git repository, how to use git in the
kernel context, how to prepare a patch, and finally, I instructed them to send
their first lintian fixes to the staging. Next, we started to dive into the IIO
subsystem by taking a look at its internal organization and its drivers in the
staging area; our project goal was simple: move drivers from the staging area
to the main tree. In summary, at the end of the course, the students moved
three drivers from staging and contributed to many other drivers in the IIO. I
have to admit, at the end of the semester, I was thrilled with the results!
The students learned really fast, and in a couple of months, they were totally
comfortable with the IIO subsystem; they surpassed my knowledge in the IIO!

After this fantastic experience, we became good friends that share the desire
of spreading the free software idea and projects with other students. As a
result, we decided to create a student group for fostering free software
contributions at the University of São Paulo (USP); after a lot of discussions
for defining our group, we established our values and our group name: FLOSS at
USP (FLUSP). I want to highlight that our group is fully horizontal without a
professor supervisor or leader and, most of the time, focused on code
contributions. Finally, we created our logo inspired on the pet (a parrot) of
one of the members,  our website, and our IRC bounce; Just for curiosity,
Figure X shows our logo evolution.

<<Figura com a evolução do Mr. FLUSP>>

# TODO: Falar sobre
# 1. Os membros fundadores
# 2. A data de nascimento

Currently, I’m glad to say that we have a full-fledged free software group that
contributes to multiple projects, such as GNU/Linux, Git, Debian, and GCC. We
also promote special events such as kernel and git workshops, take a look:

* [KernelDevDay Results](https://flusp.ime.usp.br/events/2019/06/14/kerneldevday-results_en/)
* [Linux Install Fest](https://flusp.ime.usp.br/events/2019/03/26/installfest/)
* [Guest lecture: Reproducible Software Builds](https://flusp.ime.usp.br/events/2019/06/05/lecture-reproducible-software-builds/)
* [Guest lecture: Continuous Integration with Linux Kernel](https://flusp.ime.usp.br/events/2019/04/11/kernelci-and-free-software-career/)

After all of our hard work, we also got recognition from the industry side. As
a result, we got some sponsors for our activities. Take a look on our sponsors:

* [Sponsors](https://flusp.ime.usp.br/sponsors/)

## Projects

As aforementioned, FLUSP started focused on Linux Kernel's contributions;
however, our group has multiple members with different passions, which make
some of them begin to contribute with other communities. I want to highlight
the work of four students that inspired me at the beginning of the FLUSP:
Matheus Tavares, Giuliano Belinassi, Marcelo Schmitt, and Renato Geh.

Matheus Tavares started his contributions to the free software communities by
working hard for moving a driver named ads1200 from staging to the kernel
mainline. Working in the Linux kernel did not attract him very much; however,
after his experience using git in the development tasks, he got curious about
the git community and started to dig on it. After many efforts, he began to
contribute to git project and got selected as an intern to work in the Google
Summer of Code 2019 (GSoC). His mission is exciting: make git thread-safe for
later parallelizing some of its features {% include cite.html id="tavaresgsoc"
%}. He also works hard to spread his knowledge in the git project with other
students from USP.

Since the first time that I met Giuliano Belinassi, he showed his interest in
compilers, and I tried to encourage him to focus on GCC project. He started to
look in GCC to find his own itch to scratch. First, he began by working on
float point operations. However, he wants more, he wants to parallelize GCC! As
a result, he started to dig really hard on this subject and proposed a GSoC
project related to this issue, and of course, he got accepted. These days he
makes a lot of progress in his task of parallelizing GCC {% include cite.html id="gccparalleize" %},
and he also teaches some students how to contribute to GCC.

Marcelo Schmitt is the sort of guy that enjoys working with electronic devices,
which makes the IIO subsystem the perfect match for him. After his experience
by moving XXXX from staging, he decided to apply for the GSoC project to write
a driver from scratch for UUUU. He did a great job in the GSoC by writing the
YYYY module, and he still around the IIO subsystem. Additionally, he also
teaches new members in the FLUSP to contribute to this subsystem.

Finally, Renato worked really obdurately for updating YYYY and move it from
staging to the Linux Kernel mainline; consequently, he became the YYYY
maintainer. Renato also embraced FLUSP ideas; he is the sort of guy that always
remembers our values and tries to keep it alive. His values and hard work
inspired the other FLUSP members and me.

They were in the FLUSP since the beginning; because of this, most of the
projects that the group is involved born from them. You can read more about the
project at: https://flusp.ime.usp.br/projects/

## Achievements

## Conclusion

{% include print_bib.html %}
