---
layout: post
title: "kw source code overview"
date: 2020-05-21
published: true
categories: "linux-kernel-basic"
---

{% include add_ref.html id="bashdoc"
    title="libguestfs: tools for accessing and modifying virtual machine disk images"
    date="2020-05-18"
    url="https://www.gnu.org/software/bash/manual/bash.pdf" %}

{% include add_ref.html id="shunit2"
    title="Shunit2 project"
    date="2020-05-22"
    url="https://github.com/kward/shunit2/" %}

Since the day that we started to develop `kw` we discipline ourselves to make
it valuable for a large set of kernel developers, as a direct consequence of
this engagement, we tried to embrace the best software development practices
(in our view, of course). In this post, we are going to see how `kw` is
organized, and I hope that after reading this page you feel encouraged to send
patches :)

# First thing first, why Bash?

I will not beat around the bush in this section, follows the main point why I
decided to adopt Bash instead of any other language:

0. Most of the kernel developers write Bash script for automating some of their
   daily tasks, which make easy for us to get inspiration for new features;
1. Bash is extremely portable between modern Distros;
2. It is easy to take advantage of other tools when we use Bash;
3. In my view, Bash is a very robust and simple language;
4. Bash is well documented, take a look at the official documentation
   {% include cite.html id="bashdoc" %} and you will notice that we have less
   than 100 pages of effective content for the entire language;

Despite the above advantages, we had to accept the following drawbacks:

0. The unit test is not something well adopted and documented;
1. Lack of documentation tool;
2. We don't have a native way to handle file inclusion;
3. Native support float point manipulation;

# Code organization

After cloning the project, you will find the majority of `kw` code inside
`src` directory and the rest inside the `kw` file in the root directory. You
will also find a directory named `tests` that comprises all available unit
tests, and the documentation.

> After you clone the repository you will see the `kw` file; for the rest of
this text pay attention in the context, because we going to refer to the file
multiple times.
{: .info-box}

## Features implementation

`kw` file is the entry point for all features, this file looks like this:

```bash
#!/bin/bash

# Set required variables
...
kw_cache_dir=${kw_cache_dir:-"$HOME/.cache/kw"}
...

function kw()
{
  action=$1
  shift

  mkdir -p "$kw_cache_dir"

  case "$action" in
    init)
      (
        . "$src_script_path/init.sh" --source-only

        init_kw
        return "$?"
      )
      ;;

    [..]

    build|b)
    (
      . "$src_script_path"/mk.sh --source-only

      mk_build
      local ret=$?
      alert_completion "kw build" "$1"
      return $ret
    )
...
```

From the above code you can see that we split all features in a different file,
for example, `kw init` is implemented in `src/init.sh` and `kw build` is
available at `src/mk.sh`. Let's take a close look at `deploy`:

```bash
deploy|d)
(
  . "$src_script_path"/mk.sh --source-only

  kernel_deploy "$@"
  local ret=$?
  alert_completion "kw deploy" "$1"
  return $ret
)
```

Every time that you type `kw deploy`, the above code is the first one to get
executed and our first action consists of opening a new subshell with `(...)`
and load the file `mk.sh`. This approach allows us to retrieve all code related
to the `deploy` feature in the user terminal but avoiding to load variables and
function on it; in other words, this mechanism preserves the current terminal
state. Finally, notice that we call `kernel_deploy` which is a management
function that handles user parameters and based on that select the appropriate
function to be executed.

`kw` pattern for handle specific features can be summed up as:

0. Each component has its start point defined inside the case feature in the
   `kw` file;
1. Each operation has a management function for handling user parameters.
2. Each file feature is implemented in a single file under `src`.

A good way to view `kw` code, it is to imagine it as a bunch of small software
dedicated to a specific task but well integrated with other parts. For example,
all code related to `.config` file management is kept inside
`config_manager.sh` and code related to code style validation belongs to
`checkpatch_wrapper.sh`file. During the development processes, we identified
some parts of the code that could be shared which led us to isolate them in
some tiny library such as `kwlib.sh` and `kwio.sh`.

> It is important to highlight that some functions have more than one
management function but this is a mistake kept for historical reason. The
file `mk.sh`, for example, has more than one management function; in the
future we want to fix it.
{: .info-box}

In summary, If you want to fix a bug or enhance a feature already available,
your first step should be to identify the correct file to work on (at this
point you already know how to do it). If you want to introduce a totally new
feature, isolate it in a single file and add the callback in the `kw` file.

## Easy way to test kw code

After you change something in `kw` you can test it via unit test or by
installing your change. We left the former option for the next section and we
are going to discuss only the latter form which requires the use of the
`setup.sh` script. Basically, after change the code you only need to install it
with:

```bash
./setup -i
```

If you are implementing your feature in a separate branch, you can use `kw
version` to check if it was correctly installed. After install, you can test
your change and see if it work as expected. Notice that you don't need to
uninstall anything, `./setup -i` already handle the update for you.

## About test

We want to make `kw` useful for a large set of users and also maintain the
development cycle sane. For this reason we embody the unit test as a viable
mechanism for keep `kw` scalable and easy to maintain. At the beginning of `kw`
development, we did not have a test, this scenario changed thanks to Matheus
Tavares and Renato Geh, both from the University of Sao Paulo, when they
introduced the use of `shunit2` {% include cite.html id="bashdoc" %} as our
unit test framework.

All tests can be seen in the `tests` directory alongside samples used inside
some specific tests. Usually, when we implement a test, we have two approaches
for handling the issue:

0. **Correct operation**: Some features can be tested by creating samples that
   mock real files, in these cases we can make our target function use the
   sample version. Take a look at `configm_test.sh` or `explore_test.sh` for a
   practical example.
1. **Command sequence**: Other features are hard to test and require
   integration tests, such as `kw deploy`. In this case, we have a special
   option in the function `cmd_manager()` named `TEST_MODE` which just prints
   the target command and does not execute it; this option enables us to test
   the command sequencing. Take a look at `mk_test.sh`.

Unfortunately, some of our tests are not well organized for historical reasons;
I can say that we improved a lot, but we need to rework some of the tests and
increase the coverage. If you want to run all tests, you can use:

```bash
./run_tests
```

If you want to run a specific test use `test` option, for example:

```
./run_test test mk_test
```

Take a look at ["About Tests"](https://siqueira.tech/doc/kw/content/tests.html)
page for information related to run tests. We have a label dedicated to test
improvements, you can search for
["tests"](https://github.com/kworkflow/kworkflow/issues?q=is%3Aopen+is%3Aissue+label%3Atests)
label.

## About documentation

We try our best to keep the code documented in two different fronts: code and
manual. If you take a look at the code under `src` directory, you will notice
that we document most of the function following the sphinx style; if you want
to see the user/developer documentation, take a look at `documentation`.

> We adopt the Sphinx documentation style with the hope that one day Sphinx
will support Bash documentation. If it takes to long, one day I should get my
hands dirty and try to implement it myself.
{: .info-box}

Our documentation is generated by Sphinx with the command `./setup --docs`. We
always need help to improve it, patches are extremely welcome in this part.

# Contribute

In this post I tried to provide an overview of how the `kw` code is organized,
and how you can start to contribute to it. Keep in mind that `kw` is developed
only on the spare hours of the developers, which means that we have narrow
bandwidth to work on new features and bug fixes (but we try our best). For this
reason, I wish that you get a better view of the `kw` code, and maybe, became a
contributor! Finally, if you want to go to the next step and send a patch take
a look at
["How to contribute"](https://siqueira.tech/doc/kw/content/howtocontribute.html).
