# About

This folder compress some of my public presentations.

## What do I use for creating presentation

I use Sphinx and Revealjs to generate my presentations; this is possible thanks
to an extension named sphinx-revealjs. If you want to know more about this,
take a look at the following links:

* https://github.com/attakei/sphinx-revealjs
* https://dev.to/attakei/sphinx-extension-to-generate-revealjs-presentation-from-plain-rest-58ip

# How to build kw presentations

You need Sphinx installed and pip installed in your system; for example, if you
are using Debian based system, just use:

```
apt install python3-docutils sphinx-doc python3-pip
```

Next, install the sphinx-revealjs extension:

```
pip install sphinx-revealjs
```

Finally, use the following command to build the documentation:

```
cd TARGET_PRESENTATION/
make revealjs
```

# How to create a new presentation

First of all, create a specific folder for the target presentation:

```
mkdir presentations/NAME
cd presentations/NAME
```

Create a simple Sphinx documentation structure:

```
sphinx-quickstart
```

Open the `config.py` file, and add the `sphinx_revealjs` extension as described
below:

```
extensions = [
    'sphinx_revealjs',
]
```
