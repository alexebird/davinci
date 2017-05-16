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

Put this in **~/.bashrc** or **~/.zshrc**:

```bash
export DAVINCI_HOME="<where ever you clone your team's repos to>"

# must set DAVINCI_OPTS before sourcing sourceme.sh
# see `man davinci-davinci` for all options.
export DAVINCI_OPTS='prompt'

# this is the path to where you store your gpg public keys.
export DAVINCI_GPGP_PATH="${DAVINCI_HOME}/my-teams-gpg-pub-keys"
# this is your company's domain or domains ('|' separated) that are on gpg pub keys
export DAVINCI_GPGP_EMAIL_DOMAINS='cool-co.com'

. "${HOME}/davinci/sourceme.sh"
```

### Ruby Setup
**note: this is only required for some older tools in bin/**

```bash
# install rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable

# get a terminal
rvm install ruby-2.3
rvm use ruby-2.3.3@global --default
gem install bundler
bundle
```

Discoverability
---------------

The commands and sourced-functions in DaVinci are automatically prefixed with `davinci-`.

```bash
$ man-davinci-davinci
$ davinci-<tab><tab>
```

aws-env
-------

This tooling generally relies on your AWS creds being provide via environment
variables. The command `aws-env` controls this. It is also recommended to setup
your prompt to show the current `aws-env`. `aws-env` operates by convention.
For an env called `dev`, it looks for a file named `~/.aws/dev.sh`, with these
env vars being exported:

```bash
$ cat ~/.aws/dev.sh
# iam user: larry
export AWS_DEFAULT_REGION='us-east-1'
export AWS_REGION="${AWS_DEFAULT_REGION}"
export AWS_ACCESS_KEY_ID='foobar'
export AWS_SECRET_ACCESS_KEY='flubberflabber'
```

The tool `davinci-aws-make-creds-file ENV` looks in `~/Downloads` for the most recent
file named `credentials*.csv` (which is downloaded from the IAM console), and generates
the appropriate `ENV.sh` file for placement into `~/.aws/`.

Safety Prompt
-------------

The safety prompt changes your prompt from this:

```
foo@bar:/path$
```

to:

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
