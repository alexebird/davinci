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
# - Path where virtual-env tooling, such as aws-env, environments live.
# - Should not be a git repo unless any secrets are encrypted.
export DAVINCI_ENV_PATH="${HOME}/.cool-co-env"
```

```bash
# DAVINCI_OPTS
# - defaults to ''
# - options:
#   - prompt - allow davinci to modify the shell prompt.
export DAVINCI_OPTS='prompt'
```

```bash
# DAVINCI_GPGP_PATH
# - The path where gpgp should look.
# - Inside DAVINCI_GPGP_PATH, the expected structure is:
# - "${DAVINCI_GPGP_PATH}"
#   - gpg/
#     - public/    # public gpg keys
#     - roles/     # gpgp roles
export DAVINCI_GPGP_PATH="${DAVINCI_HOME}/infra/"
```

```bash
# DAVINCI_GPGP_EMAIL_DOMAINS
# - You or your company's domain or domains ('|' separated) that are associated with gpg public keys.
export DAVINCI_GPGP_EMAIL_DOMAINS='cool-co.com'
```

Finally, source davinci.

```bash
. "${HOME}/davinci/sourceme.sh"
```

Here's a minimal `.bashrc` example:

```bash
...


. "${DAVINCI_CLONE}/sourceme.sh"
```

Discoverability
---------------

The commands and sourced-functions in DaVinci are automatically prefixed with `davinci-`.

```bash
$ davinci-<tab><tab>
```

aws-env
-------

Example:

```bash
# set
foo@bar$ aws-env dev
# if enabled, the davinci prompt detects aws-env and shows it as (a:dev)
# print/get the aws-env
foo@bar(a:dev)$ aws-env
dev
```

This tooling generally relies on your AWS creds being provided via environment
variables. The command `aws-env` controls this. It is also recommended to setup
your prompt to show the current `aws-env`. `aws-env` operates by convention.
For an env called `dev`, it looks for a file named `~/.davinci-env/aws/dev.sh`,
with these env vars being exported:

```bash
$ cat ~/.davinci-env/aws/dev.sh
# iam user: larry
export AWS_DEFAULT_REGION='us-east-1'
export AWS_REGION="${AWS_DEFAULT_REGION}"
export AWS_ACCESS_KEY_ID='foobar'
export AWS_SECRET_ACCESS_KEY='flubberflabber'
```

The tool `davinci-aws-make-creds-file ENV` looks in `~/Downloads` for the most recent
file named `credentials*.csv` (which is downloaded from the IAM console), and generates
the appropriate `ENV.sh` file for placement into `~/.davinci-env/aws/`.

Safety Prompt
-------------

The safety prompt changes your prompt from this:

```
foo@bar:/path$
```

to something like this:

```
foo@bar:/path (a:dev)(n:dev)(v:dev)$
```

Legend:

- `(a:dev)` - the AWS environment is set to `dev`. you can set this using the tool `aws-env`.
- `(n:dev)` - the Nomad environment is set to `dev`. you can set this using the tool `nomad-env`. If the word `dev` is red, then the nomad tunnel is down.
- `(v:dev)` - the `dev-us-east-1` tunnelblick openVPN connection is up.

gpgp
----

"gpg Plus"

### Setup

```
# options go in in .bashrc

# whitelist of email domains of public gpg keys.
# for multiple, separate with a '|'.
export DAVINCI_GPGP_EMAIL_DOMAINS='foobar.com'
```

For the person provisioning new team member's gpg keys:

```
# import the new key on your system.
# edit the key, and trust the key ultimately.
gpg --edit-key <key_id>
> trust
> 5
> quit

# then export the ownertrust file to the repo, and commit.
gpg --export-ownertrust > ${DAVINCI_GPGP_PATH}/gpg/ownertrust.txt

# on subsequent runs of `gpgp import`, the ownertrust file will be imported
# and the new key will be trusted.
gpg --import-ownertrust < ${DAVINCI_GPGP_PATH}/gpg/ownertrust.txt
```

### Roles

### Secrets

`gpgp` gives you source-of-truth secret management.

```
secrets            <--- this dir should be a git repo.
├── dev
│   ├── FOO.gpg
│   └── gpgp-role  <--- each gpgp-role file should contain exactly one role.
├── prod
│   ├── BAR.gpg
│   ├── data
│   │   └── QUUX.gpg
│   ├── FOO.gpg
│   └── gpgp-role
├── misc
│   └── FOO        <--- misc doesn't have a gpgp-role file in any parent directory,
└── staging             so the gpgp will abort with an error.
    ├── FOO.gpg
    └── gpgp-role
```


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
