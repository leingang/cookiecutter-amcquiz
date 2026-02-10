# cookiecutter-amcquiz
Cookiecutter for an auto-multiple-choice quiz maintained as an l3build module

**This repository is archived.** The cookiecutter has been merged into [`cookiecutter-coursedocs`](https://github.com/leingang/cookiecutter-coursedocs)


# Configuration (cookiecutter.json)

This template exposes a small set of top-level keys in `cookiecutter.json` which control how a new quiz/project is generated. Below is a short explanation of each key and what the generated project expects.

- `quiz_number` (int)
    - The numeric identifier for the quiz. Default: `1`.
    - Used to generate `exam_code` and default `exam_name`.

- `exam_code` (string template)
    - Directory / project code for the exam. Default is a templated value `q01`, `q02`, etc.:
        `"{{ 'q%02d'|format(cookiecutter.quiz_number|int) }}"`.
    - This becomes the output folder name and base identifier used in filenames.

- `exam_name` (string template)
    - Human-readable exam title. Default: `"Quiz {{ cookiecutter.quiz_number }}"`.

- `exam_date` (date template)
    - Default date inserted into documents. By default it uses the current date in YYYY-MM-DD format via a Jinja `now` expression.

- `course_name`, `instructor_name`, `term_name`, `site_id` (strings)
    - Optional metadata strings used in headers/footers and in generated LaTeX sources.

- `number_copies` (int)
    - How many copies to print per student (or per version). Default: `45`.

- `has_versions` (bool)
    - When true, the template enables multiple-version generation and expects `versions_csv` to contain the version names (for example `A,B,C`). Default: `false`.

- `use_nyu_fonts` (bool)
    - Project-local option that toggles whether NYU-specific fonts/styles are enabled in the generated LaTeX. Default: `false`.
    - When true the generated project will try to include NYU-specific style files (e.g. `xcolor-nyu22.sty`) and required fonts; set to `false` for more portable builds.

- `versions_csv` (string template)
    - Comma-separated list of version identifiers to use when `has_versions` is true. The default is a simple template (A,B,C) when `has_versions` is true, otherwise empty.

- `versions_with_solutions` (string template)
    - Comma-separated list of version identifiers that should have a separate solution file generated for them. The default is the same as `versions_csv`, 
    meaning every version gets a solution file. 

- `version_randomization_groups` (string template)
    - Comma-separated list of version identifier groups 
    that have a separate random seed generated. 
    The default is the same as `versions_csv`, meaning
    every version gets a separate randomization. 
    But versions can be grouped with semicolons, indicating
    that they should have the same randomization.
    - For example, if you have versions `A`, `B`, `C`, `D` to be set in the main classroom, and you want a student
    with identifer `ms2025` to have a custom version but still version A, then `version_randomization_groups` can be set to `"A;ms2025,B,C,D"`

- `bundle_name` (string)
    - Optional output bundle name for packaging the generated materials.

- `install_dir` (string)
    - Optional installation directory used by build scripts; typically left empty for local builds.



# Testing

## Automatic testing

There are some automated tests to make sure the process works.
Just run:

    pytest

## Manual testing

There is a sample config file in the `test` directory. So
you can run:

    cookiecutter --config-file test/course.yml .

Replay files
- You can use Cookiecutter's `--replay-file` feature to render the template non-interactively in tests or CI. The tests under `test/` create a small replay JSON that supplies these keys so generation is deterministic for automated runs.


