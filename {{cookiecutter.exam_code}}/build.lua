#!/usr/bin/env texlua

module = "{{cookiecutter.exam_code}}"
{% if cookiecutter.bundle_name -%}
bundle = "{{cookiecutter.bundle_name}}"
maindir = ".."
{%- else -%}
maindir = "."
{%- endif %}

version = "0.0"
versiondate = "{% now 'local', '%Y-%m-%d' %}"


unpackfiles  = {"*.dtx"}
unpackexe    = "latex" -- required because of the \ProvidesFile

supportdir = "support"
typesetfiles = {"*.*.tex"}
typesetexe = "lualatex"
typesetsuppfiles = {"*.png", "*.pdf", "*.sty"}

tagfiles = {"*.dtx", "*.lua"}

-- print if the debug options is set
function print_debug(s)
    if options['debug'] then
        print(s)
    end
end

-- capture the output from a shell command
-- Thanks Norman Ramsey https://stackoverflow.com/a/326715/297797
-- there is also the shell() function from l3build-upload.lua
-- it doesn't trim leading/training whitespace.
function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

-- TYPESET FILES

-- Run the vc script before generating
table.insert(typesetsuppfiles,"vc*")
function docinit_hook()
    local cmd = "sh ./vc -f -m"
    print("Running '" .. cmd .. "'")
    errorlevel = run(typesetdir,cmd)
    assert(errorlevel == 0, 
        "Failed with status " .. errorlevel .. ": " .. cmd)
    return errorlevel
end

-- Typeset with latexmk
table.insert(typesetsuppfiles,"latexmkrc")
function typeset(file)
    local name = jobname(file)
    local cmd = "latexmk -r latexmkrc " .. file
    print("Running '" .. cmd .. "'")
    errorlevel = run(typesetdir,cmd)
    assert(errorlevel == 0, 
        "Failed with status " .. errorlevel .. ": " .. cmd)
    return errorlevel
end

-- TAG FILES
-- decorator to only run if repo is clean
function only_if_clean(f)
    return function(x)
        assert(os.capture("git status --porcelain") == "",
            "Repository is dirty")
        print_debug("Repository is clean")
        return f(x)
    end 
end

-- tag = only_if_clean(tag)
target_list.tag.pre = only_if_clean(target_list.tag.pre)

-- Bump version LaTeX style:
-- 0.1 -> 0.1a -> 0.1b -> 0.2 -> ... -> 1.0 -> 1.1 -> 1.1a -> ...
function next_version_latex(parts)
    -- parts is an array of arguments; we want the first if it exists
    local part = nil
    if parts then
        part = parts[1]
    end
    local version = version or "0.1"
    local patches = "abcdefghijklmnopqrstuvwxyz"
    major, minor, patch = string.match(version, "^v?(%d+)%.(%d+)(%a?)")
    print_debug("current version = " .. version)
    print_debug(string.format("major=%d, minor=%d, patch=\"%s\"",major,minor,patch))
    if (part == "major") then
        major = major + 1
        minor = 0
        patch = ""
    elseif (part == "minor" or part == nil) then
        minor = minor + 1
        patch = ""    
    elseif (part == "patch") then
        if (patch == "") then
            patch = "a"
        else
            -- get next letter in the sequence
            -- https://stackoverflow.com/q/23120266/297797
            patch = patches:match(patch .. '(.)')
        end
    else    
        print("bad version part!")
        return
    end
    version = string.format( "%i.%i%s", major,minor,patch)
    print_debug("new version = " .. version)
    return version
end 

function bump_version(part)
    tagname = next_version(part)
    if options['dry-run'] then
        print("- l3build tag " .. tagname)
    else
        main("tag",{tagname})
    end
end

target_list.bump = {
    func = bump_version,
    help = "Bump the version, tag, and commit"
}

function update_tag(file,content,tagname,tagdate)
    -- TeX dates are in yyyy/mm/dd format.  tagdate is in yyyy-mm-dd format.
    tagdate_tex = string.gsub(tagdate,'-','/')
    if string.match(file, "%.dtx$") then
        content = string.gsub(content,
            "\n *%[%d%d%d%d/%d%d/%d%d v.- ",
            "\n  [" .. tagdate_tex .. " v" .. tagname .. " "
        )
        content = string.gsub(content,
            "\n%% \\changes{unreleased}",
            "\n%% \\changes{v" .. tagname .. "}"
        )
    elseif string.match(file,"%.lua") then
        content = string.gsub(content,
            '\nversion = ".-"',
            '\nversion = "' .. tagname .. '"'
        )
        content = string.gsub(content,
            '\nversiondate = ".-"',
            '\nversiondate = "' .. tagdate .. '"'
        )
    end
    return content
end


function git_tag(version,tagdate)
    -- create the name of the git tag from the version and tagdate
    local module = module or nil
    if (module) then
        -- module version with name prepe
        return string.format("%s-v%s",module,version)
    else
        -- calver
        return tagdate
    end
end

function tag_hook(version,tagdate)
    -- tag repository
    tagname = git_tag(version,tagdate)
    os.execute("git add .")
    os.execute("git commit -m \"Log changes for version " .. version .. "\"")
    return os.execute("git tag -a -m \"Tag version " .. tagname .. "\" " .. tagname)
end

next_version = next_version_latex


-- l3build install --full will install the pdfs in the directory below
options['texmfhome'] = maindir .. '/../Share/'
-- TODO set sourcefiles to nil only during installation
tdslocations = {'*.*.pdf',"*.dtx"}


