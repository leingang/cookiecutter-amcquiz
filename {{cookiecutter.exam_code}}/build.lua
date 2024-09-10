#!/usr/bin/env texlua

bundle = "{{cookiecutter.bundle_name}}"
module = "{{cookiecutter.exam_code}}"
maindir = ".."

version = "0.0"
versiondate = "{% now 'local', '%Y-%m-%d' %}"


unpackfiles  = {"*.dtx"}
unpackexe    = "latex" -- required because of the \ProvidesFile

supportdir = "support"
typesetfiles = {"*.*.tex"}
typesetexe = "lualatex"
typesetsuppfiles = {"*.png", "*.pdf", "*.sty"}

tagfiles = {"*.dtx", "*.lua"}

dofile(maindir .. "/config.lua")
next_version = next_version_latex


-- l3build install --full will install the pdfs in the directory below
options['texmfhome'] = maindir .. '/../Share/'
-- TODO set sourcefiles to nil only during installation
tdslocations = {'*.*.pdf',"*.dtx"}


