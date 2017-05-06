# ipynb_git
Scripts for setting up a git repository for better collaboration on Jupyter Notebooks using Git.

# Why?

Jupyter Notebooks are great for literate programming, especially in data science context. There are numerous tools in place that help data scientists share their results using Jupyter Notebooks. However, collaborating on notebooks is still cumbersome due to the mix of document structure, code and output within a single file. This makes merging a terrible task. There are approaches that provide remedies (e.g. [nbdime](https://github.com/jupyter/nbdime), diffing and merging on cell level) and tendencies to (optionally) separate code and output for Jupyter Notebooks in the future.

Why not using nbdime: 
1. I'm generally not a fan of commiting (editable) code and output in a mixed form.
2. Could not get it running stable in my Windows Cygwin environment. Had no time to fiddle with it too long.

# How?

Using post-save hooks in Jupyter Notebooks and post-checkout, post-merge hooks of git:
- Each time the notebook is saved a rst (reStructureText) and a html version is exported using [nbconvert](https://github.com/jupyter/nbconvert)
- Each time there is a git checkout or git merge (also applies to git pull/rebase without a merge actually happening) occurs the ipynb-file is reconstructed from the rst-file using [rst2ipynb](https://github.com/nthiery/rst-to-ipynb)

# Install

The solution currently is targeted to Windows 10 Pro using the WSL (Windows Subsystem for Linux), Anaconda 3 and requires the Notebook Server to be started from Bash on Ubuntu on Windows. Same applies to the Git client. 

Setup instructions are included in ipynb_git_config.sh, each repository can be configured using ipynb_repo_setup.sh which creates the required hooks. 

I guess it can be easily applied on Linux-only systems as well.

I resorted to WSL since I wasn't able to get rst2ipynb up and running using my Windows Anaconda installation and Cygwin.

# Maturity

Just created the first version that runs on my laptop. No intense testing happened yet. 

# Things to consider

- Currently ipynb is added to .gitignore
