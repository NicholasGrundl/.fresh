# Justfile Cheat Sheet

> By linux_china via [cheatography.com/141366/cs/30282/](https://cheatography.com/141366/cs/30282/)
>
> Published 22nd December, 2021. Last updated 8th January, 2025.

## Simple justfile

```just
#!/usr/bin/env just --justfile
# hello is recipe's name
hello:
    echo "Hello World!"
```

**Attention:** Don't use keywords as recipe name, such as "import", "export", "alias" etc.

---

## Default Recipe

```just
default: lint build test
```

```just
# default recipe to display help information
default:
    @just --list
```

**Note:** If no default recipe is defined, the first recipe will be default.

---

## Aliases

```just
alias t := test
alias c := check
```

---

## Settings

### Shell Configuration

```just
set shell := ["zsh", "-cu"]
#set shell := ["bun", "exec"]
```

### Environment Variables

```just
set dotenv-required
set dotenv-load := true

serv:
    echo "$DATABASE_ADDRESS from .env"
```

### Positional Arguments

```just
set positional-arguments := true

foo:
    echo $0
    echo $1
```

---

## Strings - Escape with Double-quoted

```just
string-with-tab := "\t"
string-with-newline := "\n"
escapes := '\t\n\r\"\\'

# shell-expanded path
shell-expanded-path := x'~/$FOO/${BAR}'

# this string will evaluate to `foo\n bar\n`
x := '''
foo
bar
'''
```

---

## just Command Line

```bash
# run recipe
$ just hello param1

# list recipes in alphabetical order
$ just --list
$ just --summary

# Show full information about recipe
$ just --show test

# select recipes to run interactively
$ just --choose

# shell completion
$ just --completions zsh
```

---

## GitHub Actions

```yaml
- uses: extractions/setup-just@v1
  with:
    just-version: 1.38.0
```

---

## IDE Integration

- **VS Code:** https://marketplace.visualstudio.com/items?itemName=skellock.just
- **JetBrains:** https://plugins.jetbrains.com/plugin/18658-just

---

## Just module/import

```just
# load bar/justfile, bar/.justfile, bar.just
mod bar

# include the contents of another justfile
import 'foo/bar.just'
```

```bash
$ just --unstable bar::hello
```

---

## Recipe with Parameters

### Basic Parameter

```just
filter PATTERN:
    echo "{{PATTERN}}"
```

### Parameter with Default Value

```just
email address='master@example.com':
    echo "{{address}}"
```

### Parameter with Expression

```just
test triple=(arch() + "-unknown-unknown"):
    ./test "{{triple}}"
```

### Variadic Parameters

```just
# variadic param: '+' accept one or more values
[doc('Backup files')]
backup +FILES:
    scp {{FILES}} me@example.com

# variadic param with *: zero or more values
commit MESSAGE *FLAGS:
    git commit {{FLAGS}} -m "{{MESSAGE}}"
```

**Tip:** If possible, please put param in quotation mark and friendly for syntax highlight.

---

## Recipe with Environment Variable for Command

```just
# recipe param as env variable with $ sign
hello $name:
    echo $name
```

---

## Recipe Dependencies - Before, After & Around

### Sequential Dependencies

```just
# execution sequence: a -> b -> c -> d
b: a && c d
```

### Around Pattern

```just
# execute recipe 'a' around
b:
    echo 'B start!'
    just a
    echo 'B end!'
```

### Dependencies with Parameters

```just
# depend with params by expression
default: (build "main")

build target:
    @echo 'Building {{target}}...'
```

---

## Command Annotate: quiet(@), suppress(-), invert(!)

### Quiet (@) - Don't Echo Command

```just
hello:
    @echo "command will not be echoed"
```

### Suppress (-) - Ignore Exit Status

```just
hello:
    -echo "ignore none-zero exit status and continue"
```

### Combined

```just
@hello2:
    echo "command will not be echoed"
```

### Invert (!) - Shell Feature

```just
# Invert command exit status by ! - shell feature
hello3:
    # if command succeeds (exit status is 0), exit just
    ! git branch | grep '* master'
```

---

## Recipe with Other Languages

### Bash with Shebang

```just
bash-test:
    #!/usr/bin/env bash
    set -euxo pipefail
    hello='Yo'
    echo "$hello from bash!"
```

### Bash with Script Attribute

```just
[script("bash")]
bash-test2:
    set -euxo pipefail
    hello='Yo'
    echo "$hello from bash!"
```

---

## Private Recipes - Name Starts with `_`

```just
test: _test-helper
    ./bin/test

# omitted from 'just --list'
_test-helper:
    ./bin/super-secret-test-helper-stuff
```

---

## Recipes as Shell Alias

```bash
for recipe in `just -f ~/.justfile --summary`; do
    alias $recipe="just -f ~/.justfile -d. $recipe"
done
```

---

## Recipe with Python venv

```just
venv:
    [ -d .venv ] || uv venv

run: venv
    ./.venv/bin/python3 main.py
```

---

## Variables

### Basic Variables

```just
version := "0.2.7"
tardir := "awesomesauce-" + version
tarball := tardir + ".tar.gz"
```

### Path Joining

```just
path := "a" / "b" # join path
```

### Logical Operators

```just
var1 := '' && 'goodbye'        # ''
var2 := 'hello' && 'goodbye'   # 'goodbye'
var3 := '' || 'goodbye'        # 'goodbye'
var4 := 'hello' || 'goodbye'   # 'hello'
```

### Using Variables

```just
test:
    echo "{{version}}"
```

### Override Variables from Command Line

```bash
# set/override variables from just command line
$ just --set version 1.1.0
```

**Key Features:**
- Substitutions: `{{NAME}}`
- Logical Operators: `||` `&&`
- Joining Path: `/`

---

## Environment Variable for Commands

```just
export RUST_BACKTRACE := "1"

test:
    # will print a stack trace if it crashes
    cargo test
```

---

## Backtick - Capture Output from Evaluation

### Simple Backtick

```just
JAVA_HOME := `jbang jdk home 11`
```

### Backtick Code Block

```just
stuff := ```
    foo="hello"
    echo $foo "world"
```

### Backtick in Recipe Parameters

```just
done BRANCH=`git rev-parse --abbrev-ref HEAD`:
    git checkout master
    sloc:
        > @echo "`wc -l *.c` lines of code"
```

**Note:** Backtick works anywhere: string/variable/params

---

## Just Functions

### Using Functions

```just
hello name:
    echo "{{os()}}"
    echo "{{uppercase(name)}}"
```

### Function Categories

- System Information
- Environment Variables
- Justfile and Justfile Directory
- String Manipulation
- Path Manipulation

### String Concatenation

```just
# String contact: (key + ":" + value)
```

---

## Conditional Expressions: if, loop and while

### Regular Expression Match

```just
fo := if "hi" =~ 'h.+' { "match" } else { "mismatch" }
```

### If Statement

```just
test:
    if true; then echo 'True!'; fi
```

### For Loop

```just
test:
    for file in `ls .`; do echo $file; done
```

### While Loop

```just
test:
    while `server-is-dead`; do ping -c 1 server; done
```

### Conditional in Recipe

```just
foo bar:
    echo '{{ if bar == "bar" { "hello" } else { "bye" } }}'
```

---

## Attention / Important Notes

### Command Execution

- Each command line is executed by a new shell.
- If a command line failed, just will exit, and subsequent command lines will not be executed.

### Working Directory

```just
change-working-dir:
    cd bar && pwd
```

### Multi-line Construct

```just
# Escape newline with slash
test:
    if true; then \
        echo 'True!'; \
    fi
```

### Justfile Naming

- Justfile is case insensitive: `Justfile`, `JUSTFILE` etc
- Justfile could be hidden: `.justfile`
- Call recipe from sub dir: `~/app1/target>$ just build`
