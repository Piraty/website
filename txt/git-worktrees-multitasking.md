title: Piraty/txt/git-worktrees-for-efficient-multitasking-in-a-git-repository
date: 2023-11-22
css:../style.css

# [Piraty](../index.md) / [txt](./index.md)

---

# Git-Worktrees For Efficient Multitasking In A Git-Repository

Use `git-worktree` to keep your sanity in a project with many branches.

## Why

Working on projects that require a lot of context switching (a.k.a. branch
switching) has some cost.

Being greenly, you might still use one single checkout. When switching
branch context frequently, you either pull your hair over too many stashes that
tend to roll under the bus sooner or later or you might drown in `WIP`-commits
which lead to huge merge conflicts after rebasing to master, thus slowing you
down when you again need to switch context while resolving the conflict.

I have.

Instead, I now use one git-worktree for each and every active branch and avoid
git-stash as much as possible.  I live much more happy life ever since.


### Totally made-up scenario, totally

You're implementing that very important and mind-consuming breaking change when
a hotfix is requested by OOps department. You stash away your current work,
checkout a new branch and start poking into the issue, adding a lot of debug
log statements and half-baked tests. Then a coworker calls and has some very
urgent(tm) refactoring ideas, which *of course* need your immediate attention
so you `git add .`, create a WIP commit (or worse: stash again), checkout a new
branch and start applying the proposed ideas.

After pushing your refactorings, rebasing the WIP commits or pop'ing from the
stash results in a hellofa merge conflict, which you then need to leave behind
midst resolving, because of the upcoming peer review session.

Not fun.


## How To Do Better: Have Each Active Branch In A Git-Worktree

Use one git-worktree per active branch, to be able to leave off
mid work/conflict/rebase/whatever and come back if you need to without slowing
down the setup-time to get to work on other branches.
Deal with a branch when you want to, not when you need to, at your pace.

 
### Project Topology

A project dir may look like this:

    $ ls -1 my_project
    __master
    _v3.0.0
    _v3.0.1
    _v3.0.2
    _v3.0.2
    _v5.0.0
    feat-add-foo
    feat-add-bar
    fix-issue-1337
    fix-issue-6666
    hotfix-deadlock
    playground-migrate-to-this-other-lib
    refactor-peer-review-Alice
    refactor-peer-review-Bob
    release-3.x
    release-4.1.x
    release-4.2.x
    release-4.x
    release-5.x

### Semantics

- `__master` is the one and *only* real checkout with a fully populated `.git`
  gitdir.
  It's supposed to be a clean worktree *all the time* (with passing tests
  [^passing-tests-on-master] etc.)
  and all other active branches are (rebased+)merged into it.
  All worktrees are created from it like this:
  `git branch feat-add-foo && git worktree add ../feat-add-foo feat-add-foo`
- `_v<tag>` are worktrees pointing to annotated[^tag-annotated]
  tags[^tag-v-prefix].
  The leading underscore portrays that it is a tag (should be a clean worktree
  all the time too obviously, just like master).
  The idea is to have quick access to the tag's repo state and possibly its
  release artifacts
- all other worktrees represent a (local or remote) branch that either is an
  LTS branch (i.e. `release-...-x` pattern, which mostly receives cherry-picked
  commits from master for bugfix/feature backports) or an active branch where
  real work happens. may as well be nested like `jdoe/playground/foobar` if the
  branch name purports it.

[^passing-tests-on-master]: you are a good citizen and ensure passing test suites on master. right?
[^tag-annotated]: you are a good gitizen and use annotaded, signed tags. right?
[^tag-v-prefix]: you are a good gitizen and prefix your release tags with `v`. right?


### Workflow

After creating a new branch, immediately populate its git-worktree:
    
    git branch feat-1337
    git worktree add ../feat-1337 feat-1337
    cd ../feat-1337

Each active branch/worktree usually has its own untracked TODO.md file which
allows to keep track of current progress/problems/ideas/blockers/whatnot.

If the branch is superseded or obsolete, remove the worktree and remove the
branch:

    cd ../master # or any related worktree
    git worktree remove ../feat-1337  # make sure it's clean, else use -f
    git branch -d feat-1337  # or -D
    git push --delete upstream feat-1337  # don't forget remote branches

Integrating the branch into master works as usual: cherry-pick/rebase/merge.

I have several shell alias/functions for these procedures and you should too!


## Benefits

- Quick access to code and test logs of multiple branches/tags
- Fixing merge conflicts after rebasing a branch takes too long? Just leave it
  as is.
- per-worktree TODO is more accessible than maintaing the same info in the WIP
  commit's body

## Other Notes

While this pattern avoids using stash explicitly, `git-rebase --autostash`
(which i freqently use to bring branches up to date) will leave dangling stash
entries if conflicts arose and i forgot to drop them.

A seemingly innocent `git stash pop` in another worktree will therefore make
your life complicated.
