DAVINCI
======

Shell tooling framework for teams practicing devops.

Goals:

- support bash/zsh
- support linux/mac

Setup
-----

```bash
git clone git@github.com:alexebird/davinci.git
cd davinci
# mac only
./setup-mac.sh
```

### Bash/Zsh

This exhastive list of environment variables are used to configure
Davinci. These go at the end of `~/.bashrc` or `~/.zshrc`, and must
be set before sourcing `sourceme.sh`:

```bash
# DAVINCI_CLONE
# - defaults to "${HOME}/davinci"
# - This is where Davinci is cloned to.
export DAVINCI_CLONE="${HOME}/davinci"
```

```bash
# DAVINCI_HOME (required)
# - The location where all your code repos are cloned to.
# - Used internally by davinci, but also provided for convenience
#   as a way to refence other codebases.
export DAVINCI_HOME="${HOME}/cool-co"
```

```bash
# DAVINCI_PATH
# - defaults to "${HOME}/.davinci"
# - Paths which davinci should look for additional bin/ and sh/ directories.
# - In this example, the '${HOME}/.davinci' component is a git repo with personal
#   tools, and the '${DAVINCI_HOME}/infra/davinci' component is a git repo with
#   team tooling.
export DAVINCI_PATH="${HOME}/.davinci:${DAVINCI_HOME}/infra/davinci"
```

```bash
# DAVINCI_ENV_PATH (required)
# - defaults to "${HOME}/.davinci-env"
# - Should not be a git repo unless any secrets are encrypted.
# - Paths are sourced in the order they appear in this variable, colon separated.
export DAVINCI_ENV_PATH="${HOME}/.davinci-env:${HOME}/projects/infra"
```

```bash
# DAVINCI_OPTS
# - defaults to ''
# - options:
#   - prompt - allow davinci to modify the shell prompt.
export DAVINCI_OPTS='prompt'
```

Finally, source davinci.

```bash
. "${HOME}/davinci/sourceme.sh"
```

Here's a minimal `.bashrc` example:

```bash
...

export DAVINCI_HOME="${HOME}/cool-co"
export DAVINCI_OPTS='prompt'

. "${HOME}/davinci/sourceme.sh"

```

Discoverability
---------------

The commands and sourced-functions in DaVinci are automatically prefixed with `davinci-`.

```bash
$ davinci-<tab><tab>
```

davinci-env
-----------

### TODO docs

1. global auto dir
1. global vs project local
  1. common dir
1. .sh and .gpg
1. subenvs
  1. `DAVINCI_ENV_FULL`
  1. `DAVINCI_SUBENV`
1. parameterized

Example:

```bash
# set
foo@bar$ davinci-env dev
# if enabled, the davinci prompt detects davinci-env and shows it as (deva) (with the a in colored)
# print/get the davinci-env
foo@bar(deva)$ davinci-env
dev
```

This tooling generally relies on, for example, your AWS creds being provided
via environment variables. The command `davinci-env` controls this. It is also
recommended to setup your prompt to show the current `davinci-env`.
`davinci-env` operates by convention.  For an env called `dev`, it looks for a
file named `~/.davinci-env/dev/aws.sh`, with these env vars being exported:

```bash
$ cat ~/.davinci-env/dev/aws.sh
# iam user: larry
export AWS_DEFAULT_REGION='us-east-1'
export AWS_REGION="${AWS_DEFAULT_REGION}"
export AWS_ACCESS_KEY_ID='foobar'
export AWS_SECRET_ACCESS_KEY='flubberflabber'
```

The tool `davinci-aws-make-creds-file ENV` looks in `~/Downloads` for the most recent
file named `credentials*.csv` (which is downloaded from the IAM console), and generates
the appropriate file contents for placement into `~/.davinci-env/dev/aws.sh`.

Safety Prompt
-------------

The safety prompt changes your prompt from this:

```
foo@bar:/path$
```

to something like this (color not shown in readme):

```
foo@bar:/path (devn)$
```

Legend:

- `(deva)` - the AWS environment is set to `dev`. you can set this using the tool `aws-env`.
- `(devv)` - the `dev` OpenVPN connection is up.


Log of Useful Commands
----------------------

```
# watch the nomad jobs
echo my-service > /tmp/nplussearch
watch -c 'nplus | colorize-ips | grep --color=always -E ^\|$(cat /tmp/nplussearch)'

# watch a consul service
watch -c -n2 'cplus $(cat /tmp/nplussearch) | grep --color=always -E ^\|$(cat /tmp/nplussearch)'

# watch the ec2 instances
watch -c 5 'aws-find ec2 | colorize-ec2 worker'
```
