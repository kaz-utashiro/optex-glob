
# NAME

glob - optex filter to glob filenames

# SYNOPSIS

optex -Mglob \[ option \] pattern -- command

# DESCRIPTION

This module is used to select filenames given as arguments by pattern.

For example, the following will pass only files matching `*.c` from
`*/*` as arguments to `ls`.

    optex -Mglob '*.c' -- ls */*

There are several unique options that are valid only for this module.

- **--exclude**

    Option `--exclude` will mean the opposite.

        optex -Mglob --exclude '*.c' -- ls */*

- **--regex**

    If the `--regex` option is given, it is evaluated as a regular
    expression instead of a glob pattern.

        optex -Mglob --regex '\.c$' -- ls */*

- **--path**

    With the `--path` option it matches against the entire path, not just
    the filename.

        optex -Mglob --path '\.c$' -- ls */*

Multiple options can be specified at the same time.

    optex -Mglob --exclude --regex --path '^/.*\.c$' -- ls */*

# CONSIDERATION

You should also consider using the **extglob** feature of [bash(1)](http://man.he.net/man1/bash).

For example, you can use `!(*.EN).md` would specify files matching
`*.md` minus those matching `*.EN.md`.

# AUTHOR

Kazumasa Utashiro

# LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
