# GIT
## External Links

* @[https://git-scm.com/book/en/v2]
* @[https://learnxinyminutes.com/docs/git/]
* @[https://learngitbranching.js.org/?demo]
* Related:
  See UStore: Distributed Storage with rich semantics!!!
  @[https://arxiv.org/pdf/1702.02799.pdf]

### Who-is-who
(Forcibly incomplete but still quite pertinent list of core people and companies)

* Linus Torvald: He initiated the project to fix problems
  with distributed development of the Linux Kernel
* Junio C. Hamano:  lead git maintainer (+8700 commits)
  @[https://git-blame.blogspot.com/]


### What's new: [[{]]

- 2.28:
@[https://github.blog/2020-07-27-highlights-from-git-2-28/]

 - Git 2.28 takes advantage of 2.27 commit-graph optimizations to  [[performance]]
   deliver a handful of sizeable performance improvements.

- 2.27:
 - commit-graph file format was extended to store changed-path Bloom
   filters. What does all of that mean? In a sense,
   this new information helps Git find points in history that touched a
   given path much more quickly (for example, git log -- <path>, or git [[performance]]
   blame).

- 2.25:
@[https://www.infoq.com/news/2020/01/git-2-25-sparse-checkout/]
  500+ changes since 2.24.

  Sparse checkouts are one of several approaches Git supports to improve   [scalability]
  performance when working with big(huge or monolithic) repositories.      [monolitic]
   They are useful to keep working directory clean by specifying which     [performance]
  directories to keep. This is useful, for example, with repositories
  containing thousands of directories.

  See also: http://schacon.github.io/git/git-read-tree.html#_sparse_checkout

- 2.23:
  https://github.blog/2019-08-16-highlights-from-git-2-23
[[}]]


## GIT "Full Journey" [[{git.101,02_DOC_HAS.diagram,01_PM.WiP]]

Non-normative Git server setup for N projects with M teams of L users

### CONTEXT:
- ssh access has been enabled to server (e.g: $ $ sudo apt install openssh-server   )
- Ideally ssh is protected. See for example:
   @[../DevOps/linux_administration_summary.html#knockd_summary]
   (Alternatives include using GitHub,GitLab,BitBucket, AWS/Scaleway/Azure/... )

-  We want to configure linux users and groups to match a "permissions layout" similar to:
   ```
    GIT_PROJECT1 ···→ Linux Group teamA ····→ R/W permssions to /var/lib/teamA/project01 *1
    GIT_PROJECT2 ···→ Linux Group teamA ····→ R/W permssions to /var/lib/teamA/project02
                      └───────┬────────┘
                       alice, bob,...
    GIT_PROJECT3 ···→ Linux Group teamB ····→ R/W permssions to /var/lib/teamB/project03
    GIT_PROJECT4 ···→ Linux Group teamB ····→ R/W permssions to /var/lib/teamB/project04
                      └───────┬────────┘
                       franc, carl, ...
    GIT_PROJECT5 ···→ ...
  *1: setup /var/lib/teamA/project01 like:
  $ $ sudo mkdir -p /var/lib/teamA/project01                 ← create directory
  $ $ cd /var/lib/teamA/project01
  $ $ sudo git init --bare                                   ← INIT NEW GIT BARE DIRECTORY !!!!
                                                               (GIT OBJECT DATABASE for
                                                                commits/trees/blogs, ...)
  $ $ DIR01=/var/lib/teamA/project01
  $ $ sudo find ${DIR01} -exec chown -R nobody:teamA {} \;   ← Fix owner:group_owner for dir. recursively
  $ $ sudo find ${DIR01} -type d -exec chmod g+rwx {} \;     ← enable read/wr./access perm. for dirs.
  $ $ sudo find ${DIR01} -type f -exec chmod g+rw  {} \;     ← enable read/write      perm. for files

    Finally add the desired linux-users to the 'teamA' linux-group at will. More info at:
    @[../DevOps/linux_administration_summary.html#linux_users_groups_summary] )
   ```

## Non-normative ssh client access to Git remote repository using ssh

### PRE-SETUP) Edit ~/.bashrc to tune the ssh options for git ading lines similar to:

  ```
  + GIT_SSH_COMMAND=""
  + GIT_SSH_COMMAND="${GIT_SSH_COMMAND} -oPort=1234 "                 ← connect to port 1234 (22 by default)
  + GIT_SSH_COMMAND="${GIT_SSH_COMMAND} -i ~/.ssh/privKeyServer.pem " ← private key to use when authenticating to server
  + GIT_SSH_COMMAND="${GIT_SSH_COMMAND} -u myUser1 "                  ← ssh user and git user are the same when using ssh.
  + GIT_SSH_COMMAND="${GIT_SSH_COMMAND} ..."                          ← any other suitable ssh options (-4, -C, ...)

    Optionally add your GIT URL like:
  $ + export GIT_URL="myRemoteSSHServer"
  $ + export GIT_URL="${GIT_URL}/var/lib/my_git_team   ← Must match path in server (BASE_GIT_DIR)
  $ + export GIT_URL="${GIT_URL}/ourFirstProject"      ← Must match name in server (PROJECT_NAME)
  ```

* PRE-SETUP) Modify PS1 prompt (Editing $HOME/.bashrc) to look like:
  ```
  NOTE: Bash (bash "syntax sugar") 
  readonly val01=$( some_bash_script )
                 └─────────┬─────────┘
      exec. some_bash_script as script, then
      Assign STDOUT to val01
           


  PS1="\h[\$(git branch 2>/dev/null | grep ^\* | sed 's/\*/branch:/')]"               
           └─────────────     show git branch    ───────────────────┘                 
  export PS1="${PS1}@\$(pwd |rev| awk -F / '{print \$1,\$2}' | rev | sed s_\ _/_) \$ "
               └────────────── show current and parent dir. only ────────┘

  host1 $                           ← PROMPT BEFORE
  host01[branch: master]@dir1/dir2  ← PROMPT AFTER
  ```

* Finally clone the repo like:
  ```
  $ git clone   myUser1 @${GIT_URL}   # <·· execution will warn about cloning empty directory.
  $ cd ourFirstProject                # <·· move to local clone.
  $ ...                               # <·· Continue with standards git work flows.
  $ git add ...
  $ git commit ...
  ```

## COMMON (SIMPLE) GIT FLOWS

  ```
  ┌─ FLOWS 1: (Simplest flow) no one else pushed changes before our push.────────────────────────────────────
  │           NO CONFLICTS CAN EXISTS BETWEEN LOCAL AND REMOTE WORK
  │  local ─→ git status ─→ git add . ─→ git commit ··································→ git push \
  │  edit     └───┬────┘    └───┬────┘   └───┬────┘                                     origin featureX
  │               │         add file/s       │                                         └─────┬─────────┘
  │       display changes   to next commit   │                                       push to featureX branch
  │       pending to commit              commit new file history                     at remote repository.

  ┌─ FLOWS 2: someone else pushed changes before us,  ───────────────────────────────────────────────────────
  │           BUT THERE ARE NO CONFLICTS (EACH USER EDITED DIFFERENT FILES)
  │  local → git status → git add . → git commit ─→ git pull ·························→ git push \
  │  edit                                          └───┬───┘                            origin featureX
  │               • if 'git pull' is ommitted before 'git push', git will abort warning about remote changes
  │                 conflicting with our local changes. 'git pull' will download remote history and since
  │                 different files have been edited by each user, an automatic merge is done  (local changes
  │                  + any other user's remote changes). 'git pull' let us see other's people work locally.

  ┌─ FLOW 3: someone else pushed changes before our push,  ──────────────────────────────────────────────────
  │          BUT THERE ARE  CONFLICTS (EACH USER EDITED ONE OR MORE COMMON FILES)
  │  local → git status → git add . → git commit ─→ git pull ┌→ git add  → git commit → git push \
  │  edit                                              ↓     ↑  └──┬──┘                 origin featureX
  │                                             "fix conflicts" mark conflicts as
  │                                             └─────┬──────┘  resolved
  │                                  manually edit conflicting changes (Use git status to see conflicts)

  ┌─ FLOW 4: Amend local commit ─────────────────────────────────────────────────────────────────────────────
  │  local → git status → git add . → git commit  → git commit ─amend ...→ git commit → git push \
  │  edit                                                                               origin featureX

  ┌─ GIT FLOW: Meta-flow using WIDELY ACCEPTED BRANCHES RULES  ──────────────────────────────────────────────
  │  to manage common issues when MANAGING AND VERSIONING SOFTWARE RELEASES
  │  ┌───────────────────┬──────────────────────────────────────────────────────────────────────────────────┐
  │  │ Standarized       │ INTENDED USE                                                                     │
  │  │ branch names      │                                                                                  │
  │  ├───────────────────┼──────────────────────────────────────────────────────────────────────────────────┤
  │  │ feature/...       │ Develop new features here. Once developers /QA tests are "OK" with new code      │
  │  │                   │ merge back into develop. If asked to switch to another task just commit changes  │
  │  │                   │to this branch and continue later on.                                             │
  │  ├───────────────────┼──────────────────────────────────────────────────────────────────────────────────┤
  │  │develop            │ RELEASE STAGING AREA: Merge here feature/... completed features NOT YET been     │
  │  │                   │ released in other to make them available to other dev.groups.                    │
  │  │                   │ Branch used for QA test.                                                         │
  │  ├───────────────────┼──────────────────────────────────────────────────────────────────────────────────┤
  │  │release/v"X"       │ stable (release tagged branch). X == "major version"                             │
  │  ├───────────────────┼──────────────────────────────────────────────────────────────────────────────────┤
  │  │hotfix branches    │ BRANCHES FROM A TAGGED RELEASE. Fix quickly, merge to release and tag in release │
  │  │                   │ with new minor version. (Humor) Never used, our released software has no bugs    │
  │  └───────────────────┴──────────────────────────────────────────────────────────────────────────────────┘
  │
  │  • master branch ← "Ignore".
  │  ├─ • develop (QA test branch) ·················• merge ·················· • merge ┐  ...• merge ┐
  │  │  │                                           ↑ feat.1                   ↑       ·     ↑       ·
  │  │  ├→ • feature/appFeature1 • commit • commit ─┘  ························│·······↓ ... ┘       ·
  │  │  │     (git checkout -b)                                                │       ·             ·
  │  │  │                                                                      │       ·             ·
  │  │  ├→ • feature/appFeature2 • commit • commit • commit • commit • commit ─┘       ·  ┌··········┘
  │  │                                                                                 ·  ·(QA test "OK")
  │  │                      ┌··········←·(QA Test "OK" in develop, ready for release)··┘  ·
  │  │  ...                 v                                                             v
  │  ├─ • release/v1 ·······• merge&tag ┐         • merge&tag ┐         • merge&tag ······• merge&tag
  │  │                        v1.0.0    ·         ↑ v1.0.1    ·         ↑ v1.0.2            v1.1.0
  │  │                        *1        ↓         · *1        ·         · *1                *1
  │  │                                  └ hotfix1 •           └ hotfix2 •
  │  │                                  (git checkout -b)
  │  ├─ • release/v2 ····

  *1 Each merge into release/v"N" branch can trigger deployments to acceptance and/or production enviroments
     triggering new Acceptance tests. Notice also that deployments can follow different strategies
     (canary deployments to selected users first, ...).
  ```

## Git Recipes

  ```
                                            PLAYING WITH BRANCHES
  $ git checkout    newBranch             ← swith to local branch (use -b to create if not yet created)
  $ git branch -av                        ←  List (-a)ll existing branches
  $ git branch -d branchToDelete          ← -d: Delete branch
  $ git checkout --track "remote/branch"  ← Create new tracking branch (TODO)
  $ git checkout v1.4-lw                  ← Move back to (DETACHED) commit. ('git checkout HEAD' to reattach)
 $ git remote update origin --prune       ← Update local branch to mirror remote branches in 'origin'

                                            VIEW COMMIT/CHANGES HISTORY
  $ git log -n 10                         ← -n 10. See only 10 last commits.
  $ git log -p path_to_file               ← See log for file with line change details (-p: Patch applied)
  $ git log --all --decorate \            ← PRETTY BRANCH PRINT Alt.1
    --oneline --graph                       REF @[https://stackoverflow.com/questions/1057564/pretty-git-branch-graphs]
  $ git log --graph --abbrev-commit \     ← PRETTY BRANCH PRINT  Alt.2
     --decorate --date=relative --all


                                            UPDATE ALL REMOTE BRANCHES TO LOCAL REPO
  (REF: https://stackoverflow.com/questions/10312521/how-to-fetch-all-git-branches=
  for remote in `git branch -r`;             # ← add remote branches on server NOT yet tracked locally
     do git branch \                         #   (pull only applies to already tracked branches)
        --track ${remote#origin/} $remote;
  done

  $ git fetch --all                            # ← == git remote update.
                                               #    updates local copies of remote branches
                                               #    probably unneeded?. pull already does it.
                                               #    It is always SAFE BUT ...
                                               #    - It will NOT update local branches (tracking remote branches)
                                               #    - It will NOT create local branches (tracking remote branches)
  $ git pull --all                             # ← Finally update all tracked branches.

                                            TAGS:
  $ git tag                               ← List tags
  → v2.1.0-rc.2
  → ...
  $ git tag -a v1.4 -m "..." 9fceb..      ← Create annotated tag (recomended), stored as FULL OBJECTS.
                                            It contains tag author/mail/date, tagging message (-m).
                                            can be checksummed and optionally SIGNED/VERIFIED with GPG.
                                            if commit ommited (9fceb..) HEAD is used)
  $ git tag v1.4-lw                       ← Create lightweight tag ("alias" for commit-checksum)

                                            SHARING/PUSHING TAGS
                                            WARN : 'git push' does NOT push tags automatically
  $ git push origin v1.5                  ← Share 'v1.5' tag to remote 'origin' repo
  $ git push origin --tags                ← Share all tags
  $ git tag -d v1.4-lw                    ← Delete local tag (remote tags will persist)
  $ git push origin --delete v1.4-lw      ← Delete remote tag. Alt 1
  $ git push origin :refs/tags/v1.4-lw    ← Delete remote tag. Alt 2
                    └────────────────┴─── ← null value before the colon is being pushed to the
                                             remote tag name, effectively deleting it.
  $ git show-ref --tags                   ← show mapping tag ←→ commit
  → 75509731d28d... refs/tags/v2.1.0-rc.2
  → 8fc0a3af313d... refs/tags/v2.1.1
  → ...
                                            REVERTING CHANGES
 $ git reset --hard HEAD~1                ← revert to last-but-one (~1) local commit (Not yet pushed)
                                            (effectively removing last commit from local history)
 $ git checkout path/fileN                ← revert file not yet "git-add"ed or removed from FS to last commited ver.
 $ git checkout HEAD^ -- path/...         ← revert commited file to last-but-one commit version
 $ git revert ${COMMIT_ID}                ← add new commit cancelling changes in $COMMIT_ID. Previous
                                            commit is not removed from history. Both are kept on history.
 $ git clean -n                           ← Discard new "git-added" files. -n == -dry-run, -f to force
 $ git reset path/fileA                   ← Remove from index file "git-added" by mistake (with 'git add .')
                                            (probably must be added to .gitignore)

 $ git checkout N -- path1                ← Recover file at commit N (or tag N)
 $ git checkout branch1 -- path1          ← Recover file from branch1
                                            origin/branch1 to recover from upstream -vs local- branch.


                                            CLONING REMOTES
  $ git clone --depth=1  \                ← Quick/fast-clone (--depth=1) with history truncated to last N commits.
                                            Very useful in CI/CD tasks.
        --single-branch \                 ← Clone only history leading to tip-of-branch (vs cloning all branches)
                                            (implicit by previous --depth=... option)
        --branch '1.3' \                  ← branch to clone (defaults to HEAD)
        ${GIT_URL}                        To clone submodules shallowly, use also --shallow-submodules.
  ```

## Track code changes

REF: @[https://git-scm.com/book/en/v2/Appendix-C:-Git-Commands-Debugging]

Methods to track who changed and/or when a change(bug) was introduced include:

### git bisect : find first commit introducing a change(bug, problem, ...) through automatic binary search .
@[https://git-scm.com/book/en/v2/Git-Tools-Debugging-with-Git#_binary_search]
* git-blame helps to find recently introduced bugs.
* git-bisect helps find bugs digged many commits down in history.
* Ussage example:
  ```
                               MANUAL BISECT SEARCH
    $ git bisect start       ← start investigating issue.
    (run tests)
    $ git bisect bad         ← tell git that current commit is broken
    (run tests)
    $ git bisect good v1.0   ← tell git that current commit is OK
    Bisecting: 6 revisions↲  ← Git counts about 12 commits between
    left to test after this    "good" and "bad" and checks out middle one
    (run tests)
    ...
    b04... is 1st bad commit ← repeat git bisect good/bad until reaching
                               1st bad commit.
    $ git bisect reset       ← DON'T FORGET: reset after finding commit.

                               AUTOMATING BISECT SEARCH
  $ git bisect start HEAD v1.0
  $ git bisect run test.sh   ← test.sh must return 0 for "OK" results
                               non-zero otherwise.
  ```

### git blame : annotates lines-of-files with:
@[https://git-scm.com/book/en/v2/Git-Tools-Debugging-with-Git#_file_annotation]

  ```
  $ git blame -L 69,82 -C path2file  ← display last commit+committer for a given line
                                       -C: try to figure out where snippets of code
                                           came from (copied/file moved)
  b8b0618cf6fab (commit_author1 2009-05-26 ... 69) ifeq
  b8b0618cf6fab (commit_author1 2009-05-26 ... 70)
  ^1da177e4c3f4 (commit_author2 2005-04-16 ... 71) endif
  ^                                            ^^
  prefix '^' marks initial commit for line    line
  ```

### git grep : find any string/regex in any file in any commit, working directory (default) or index.
@[https://git-scm.com/book/en/v2/Git-Tools-Searching#_git_grep]
* Much faster than standard 'grep' UNIX command!!!
  ```
  $ git grep -n      regex01  ← display file:line   matching regex01 in working dir.
                                -n/--line-number: display line number
                                Use -p / --show-functions to display enclosing function
                                (Quick way to check where something is being called from)
  $ git grep --count regex01  ← Summarize file:match_count matching regex01 in working dir.

  $ git grep                  ← display file:line matching
      -n -e '#define' --and \ ← '#define' and
       \( -e ABC -e DEF \)      ( ABC or DEF )
      --break --heading \     ← split up output into more readable format
      "v1.8.0"                      ← search only in commit with tag "v1.8.0"
  ```

* See also ripgrep, claiming to be faster than `git grep`
  `https://github.com/BurntSushi/ripgrep`


### Git Log Searching:

  ```sh
  $ git log -S ABC --oneline ← log only commits changing the number-of-occurrences of "ABC"
  e01503b commit msg ...       Replace -S by -G for REGEX (vs string).
  ef49a7a commit msg ...
  ```

### Line history Search:
  ```
  $ git log -L :funABC:file.c ← git will try to figure out what the bounds of
                                function funABC are, then look through history and
                                display every change made.
                                If programming lang. is not supported, regex can be
                                used like {: -L '/int funABC/',/^[}]/:file.c
                                range-of-lines or single-line-number can be used to
                                filter out non interesting results.
  ```

## Git Plumbings

* Summary extracted from:
  ```
  @[https://alexwlchan.net/a-plumbers-guide-to-git/1-the-git-object-store/]
  @[https://alexwlchan.net/a-plumbers-guide-to-git/2-blobs-and-trees/]
  @[https://alexwlchan.net/a-plumbers-guide-to-git/3-context-from-commits/]
  @[https://alexwlchan.net/a-plumbers-guide-to-git/4-refs-and-branches/]

$ git init   ← creates an initial layout containing (Alternatively $ $git clone ... ª from existing remote repo )
  ✓.git/objects/, ✓ .git/refs/heads/master, ✓ .git/HEAD (pointing to heads/master initially)
  ✓.git/description (used by UIs), ✓.git/info/exclude (local/non-commited .gitignore),
  ✓.git/config, ✓.git/hooks/

   ~/.git/index  ←············  binary file with staging area data (files 'git-added' but not yet commited)
                                Use (porcelain) $ $ git ls-files   to see indexes files (git blobs)
        ┌─.git/objects/  (  GIT OBJECT STORE  ) ─────────┐      $ $ echo "..." > file1.txt
        │                                                │      $ $ git hash─object ─w file1.txt
┌········→ • /af/3??? •···→ •/a1/12???                   │          └───────────┬────────────────┘
·       │  │(2nd commit)                      ┌············ save to Object Store┘content─addressable File System.
·       │  v                                  v          │  WARN : Original file name lost. We need to add a mapping
· ┌··┬···→ • /5g/8... •···→ • /32/1... •┬··→• /a3/7... • │   (file_name,file_attr) ←→ hash to index like:
· ·  ·  │   (1st commit)    ┌··········┘├··→• /23/4... • │   $ $ git update-index --add file1.txt (git Plumbing)
· ·  ·  │                   ·           └···┐            │┌· Finally an snapshot of the index is created like a tree:
· ·  ·  │                   ·               ·            │·$ $ git write-tree                 .git/index snapshot to tree
· ·  ·  │                   ├─····························┘  ( /af/9???... tree object will be added to Obj.Store)
· ·  ·  │                   ·               ·            │ $ $ git cat-file -p ${tree_hash}
· ·  ·  │                   ·               ·            │     100644 blob b133......  file1.txt  ← Pointer+file_name to blob
· ·  ·  │                   ·               ·            │     040000 tree 8972......  subdir...  ← Pointer+"dirname" to (sub)tree
· ·  ·  │                   ·               ·            │     ...
· ·  ·  │                   ·               ·            │     ^^^^^^ ^^^^ ^^^^^^^^^^  ^^^^^^^^^^^^
· ·  ·  │                   ·               ·            │     file   type content     Name of file
· ·  ·  │                   ·               ·            │     permis.     address.ID
· ·  ·  │                   ·               ·            │ ☞KEY-POINT:☜
· ·  ·  │                   v               v            │  Starting at a tree, we can rebuild everything it points to
· ·  ·  │                   • /af/9... •┬··→• /12/d... • │  All that rest is mapping trees to some "context" in history.
· ·  ·  │                               └··→• /34/2... • │
· ·  ·  │  ^^^^^^^^^^^^     ^^^^^^^^^^^^    ^^^^^^^^^^^^ │  Plumbing "workflow" summary:
· ·  ·  │    commits          Trees           Blobs      │← Add 1+ Blobs → Update Index → Snapshot to Tree
· ·  ·  └────────────────────────────────────────────────┘  → create commit pointing to tree of "historical importance"
· ·  └·······················─┬──────────────────────┐        → create friendly refs to commits
· · $ $ echo "initial commit" | git commit-tree 321.....   ← create commit pointing to tree of "historical importance"
· ·     af3...                                               Use also flag '-p $previous_commit' to BUILD A LINEAR ORDERED
· ·                                                          HISTORY OF COMMITS !!!
· ·
· · $ $ git cat-file -p af3....                            -p: show parent of given commit
· ·   tree 3212f923d36175b185cfa9dcc34ea068dc2a363c   ← Pointer to tree of interest
· ·   author    Alex Chan ... 1520806168 +0000        ← Context with author/commiter/
· ·   committer Alex Chan ... 1520806168 +0000          creation time/ ...
· ·   ...
· · "DEBUGGING" TIP: Use 'git cat-file -p 12d...' for pretty print ('-t' to display/debug object type)
· ·
· └ ~/.git/refs/heads/dev     ←  ~/.git/HEAD (pointer to active ref)
└·· ~/.git/refs/heads/master af3...  ← Create friendly "master" alias to a commit like:
                      ^^^^^^         $ $ git update-ref refs/heads/master   ← With plumbing each new commit requires a new
    refs in heads/ folder are        $ $ cat  .git/refs/heads/master          git update-ref.
    COMMONLY CALLED BRANCHS            af3... (pointer to commit)
                                       Now $ $ git cat-file -p master   "==" $ $ git cat-file -p af3...

                                     $ $ git rev-parse master               ← check value of ref
                                       af3...

                                     $ $ git update-ref refs/heads/dev     ← Create second branch (ref in heads/ folder)
                                     $ $ git branch
                                       dev
                                     * master ←·························  current branch is determined by (contents of)
                                     $ $ cat .git/HEAD                     ~/.git/HEAD. Using plumbing we can change it like
                                     ref: refs/heads/master                $ git symbolic-ref HEAD refs/heads/dev
  ```

## merge/rebase/cherry-pick

* REF: @[https://stackoverflow.com/questions/9339429/what-does-cherry-picking-a-commit-with-git-mean],
  @[https://git-scm.com/docs/git-cherry-pick]
  ```
 ┌ INITIAL STATE ──────────────────────────────────────────────────────────
 │ • → • → • → • →H1          ← refs/heads/branch01
 │         │
 │         └─→ •x1→ •x2→ •H2  ← refs/heads/branch02
 └────────────────────────────────────────────────────────────────────────
 ┌ MERGE @[https://git-scm.com/docs/git-merge]────────────────────────────
 │ add changes for other branch as single "M"erge commit
 │ $ $ git checkout branch01 && git merge branch02
 │ • → • → • → • → •H1 → •M  : M = changes of ( x1+x2+H2 )
 │         │             ↑
 │         └─→ •x1→ •x2→ •H2
 └────────────────────────────────────────────────────────────────────────
 ┌ REBASE @[https://git-scm.com/docs/git-rebase]──────────────────────────
 │ "replay" full list of commits to head of branch
 │ $ $ git checkout branch01 && git rebase branch02
 │ • → • → • → • →H1 •x1→ •x2→ •H2
 │         │
 │         └─→ •x1→ •x2→ •H2
 └────────────────────────────────────────────────────────────────────────
 ┌ Squash N last commit into single one  (rebase interactively) ──────────
 │
 │ • → • → • → • →H1      ← refs/heads/branch01
 │         │
 │         └─→ • H2' (x1 + x2)
 │
 │ $ $ git rebase --interactive HEAD~2

 │   pick 64d03e last-but-2 commit comment ← Different interesing actions are available
 │   pick 87718a last-but-1 commit comment   Replace "pick" by "s"(quash) to mark commit
 │   pick 83118f HEAD       commit comment   to be squashed into single commit.
 │                                            ·
 │   s 64d03e last-but-2 commit comment     ←·┘
 │   s 87718a last-but-1 commit comment     (Save and close editor. Git will combine all
 │   s 83118f HEAD       commit comment     commits into first in list)
 │                                          The editor will "pop up" again asking to enter
 │                                          a commit message.
 └────────────────────────────────────────────────────────────────────────

 ┌ CHERRY-PICK @[https://git-scm.com/docs/git-cherry-pick]────────────────
 │ "Pick" unique-commits from branch and apply to another branch
 │ $ $ git checkout branch02 && git cherry-pick  -x branch02
 │ ··· • → • →H1 → ...                          └┬┘
 │     │                  • Useful if "source" branch is public, generating
 │     └─→ • → • →H2 →      standardized commit message allowing co-workers
 │                          to still keep track of commit origin.
 │                        • Notes attached to the commit do NOT follow the
 │                          cherry-pick. Use $ $ git notes copy "from" "to"
 └────────────────────────────────────────────────────────────────────────
  ```
[[}]]

## GPG signed commits [[{security.secret_management,security.signed_content,01_PM.TODO.now]]
@[https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work]

  ```
  GPG PRESETUP

  See @[General/cryptography_map.html?id=pgp_summary] for a summary on
  how to generate and manage pgp keys.

  GIT PRESETUP
  $ git config --global \
        user.signingkey 0A46826A  ← STEP 1: Set default key for tags+commits sign.

  $ git tag -s v1.  -m 'my signed 1.5 tag'  ←   Signing tags
            └──┬──┘                           (follow instructions to sign)
          replaces -a/--anotate

  $ git show v1.5
  tag v1.5
  Tagger: ...
  Date:   ...

  my signed 1.5 tag
  -----BEGIN PGP SIGNATURE-----
  Version: GnuPG v1

  iQEcBAABAgAGBQJTZbQlAAoJEF0+sviABDDrZbQH/09PfE51KPVPlanr6q1v4/Ut
  ...
  =EFTF
  -----END PGP SIGNATURE-----

  commit ...

  $ git tag -  v1.4.2.1  ←   Verify tag
            └┘             Note: signer’s pub.key must be in local keyring
  object 883653babd8ee7ea23e6a5c392bb739348b1eb61
  type commit
  ...
  gpg: Signature made Wed Sep 13 02:08:25 2006 PDT using DSA key ID
  F3119B9A
  gpg: Good signature from "Junio C Hamano <junkio@cox.net>"
  gpg:                 aka "[jpeg image of size 1513]"
  Primary key fingerprint: 3565 2A26 2040 E066 C9A7  4A7D C0C6 D9A4
  F311 9B9A
  └──────────────────────────┬────────────────────────────────────┘
   Or error similar to next one will be displayed:
     gpg: Can't check signature: public key not found
   error: could not verify the tag 'v1.4.2.1'

  $ git commit -  -  -m 'Signed commit'  ←   Signing Commits (git 1.7.9+)

  $ git log --show-signature -1          ←   Verify Signatures
  commit 5c3386cf54bba0a33a32da706aa52bc0155503c2
  gpg: Signature made Wed Jun  4 19:49:17 2014 PDT using RSA key ID
  0A46826A
  gpg: Good signature from "1stName 2ndName (Git signing key)
  <user01@gmail.com>"
  Author: ...
  ...
$ $ git log --pretty="format:%h %G? %aN  %s"
                                ^^^
                                check and list found signatures
         Ex. Output:
    5c3386cG   1stName 2ndName  Signed commit
    ca82a6dR   1stName 2ndName  Change the version number
    085bb3bR   1stName 2ndName  Remove unnecessary test code
    a11bef0R   1stName 2ndName  Initial commit


You can also use the -S option with the git merge command to sign the
resulting merge commit itself. The following example both verifies
that every commit in the branch to be merged is signed and
furthermore signs the resulting merge commit.


$ git merge \             ←   # Verify signature at merge time
  --verify-signatures \
  -S \                    ← Sign merge itself.
  signed-branch-to-merge  ← Commit must have been signed.

$ git pull  \             ←   # Verify signature at pull time
  --verify-signatures
  ```
[[}]]

## Client-Side Hooks [[{01_PM.TODO.now]]
@[https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks]

* Hook: Script execute before/after commiting.
* Client-Hook: hooks executed in every client to force some global policy.
* pre-commit hook:
  * First script to be executed.
  * used to inspect the snapshot that's about to be committed.
    * Check you’ve NOT forgotten something
    * make sure tests run
    * Exiting non-zero from this hook aborts the commit
  (can be bypassed with git commit *-no-verify flag)
* prepare-commit-msg hook:
  * Params:
    * commit_message_path (template for final commit message)
    * type of commit
    * commit SHA-1 (if this is an amended commit)
  * run before the commit message editor is fired up
    but after the default message is created.
  * It lets you edit the default message before the
    commit author sees it.
  * Used for non-normal-commits with auto-generated messages
    * templated commit messages
    * merge commits
    * squashed commits
    * amended commits
* commit-msg hook:
    * commit_message_path (written by the developer)
* post-commit hook:
  * (you can easily get the last commit by running git log -1 HEAD)
  * Generally, this script is used for notification or something similar.
* email-workflow  hooks:
  * invoked by
    ```
    $ git am  # <·· Apply a series of (git-formated) serieds of patches 
                    Sending patches by mail and then patching manually
                    was the way to work before the existence of source
                    control management systems (git, subversions, ...)
    ```
* applypatch-msg :
  * Params:
    * temp_file_path containing the proposed commit message.
* pre-applypatch :
  * confusingly, it is run after the patch is
    applied but before a commit is made.
  * can be used it to inspect the snapshot before making the commit,
    run tests,  inspect the working tree with this script.
* post-applypatch :
  * runs after the commit is made.
  * Useful to notify a group or the author of the patch
    you pulled in that you’ve done so.
* Others:
  * pre-rebase hook:
    * runs before you rebase anything
    * Can be used to disallow rebasing any commits
      that have already been pushed.
  * post-rewrite hook:
    * Params:
      * command_that_triggered_the_rewrite:
        * It receives a list of rewrites on stdin.
    * run by commands that replace commits
      such as 'git commit *-amend' and 'git rebase'
      (though not by git filter*branch).
    * This hook has many of the same uses as the
      post*checkout and post-merge hooks.
  * post-checkout hook:
    * Runs after successful checkout
    * you can use it to set up your working directory
      properly for your project environment.
      This may mean moving in large binary files that
      you don't want source controlled, auto*generating
      documentation, or something along those lines.
  * post-merge hook:
    * runs after a successful merge command.
    * You can use it to restore data in the working tree
      that Git can't track, such as permissions data.
      It can likewise validate the presence of files
      external to Git control that you may want copied
      in when the working tree changes.
  * pre-push hook:
    * runs during git push, after the remote refs
      have been updated but before any objects have
      been transferred.
    * It receives the name and location of the remote
      as parameters, and a list of to*be-updated refs
      through stdin.
    * You can use it to validate a set of ref updates before
      a push occurs (a non*zero exit code will abort the push).
[[}]]

## Server-Side Hooks [[{01_PM.TODO.now]]

* Only a git system administrator can setup them.
* Useful to enforce nearly any kind of policy in repository.
* exit non-zero to rollback/reject any push and print error messages
  back to the client.
* Pre-receive hook:
  * first script to run
  * INPUT: STDIN reference list
  * Rollback all references on non-zero exit
  * Ex. Ussage: Ensure none of the updated references are non-fast-forwards.
    do access control for all the refs and files being modifying by the push.
* update hook : similar to pre-receive hook.but  run once for each branch the
  push is trying to update  (ussually just one branch is updated).
  * INPUT arguments:
    * reference name (for branch),
    * SHA-1
    * SHA-1
      ```
      | refname= ARGV[0] ← ref.name for current branch
      | oldrev = ARGV[1] ←  (SHA*1)  original (current-in-server)      ref. *1
      | newrev = ARGV[2] ←  (SHA*1)  new      (intention to)      push ref. *1
      | user   = $USER   ← "Injected" by git when using ssh.
      | ¹: We can run over all commit from $oldrev to $newrev like
      |    git rev*list \                        ← display a (sha1)commit per line to STDOUT
      |        oldrev..$newrev \                 ← from $oldrev to $newrev
      |        while read SHA_COMMIT ; do
      |       git cat*file commit $SHA_COMMIT \  ← *1
      |       | sed '1,/^$/d'                    ← Delete from line 1 to first match of
      |                                            empty*line (^$).
      |
      | ¹ output format is similar to:
      | tree      ...
      | parent    ...
      | committer ...
      | 
      | My commit Message
      | tree      ...
      ```
   * user-name (if accesing through ssh) based on ssh public-key.
   * Exit  0: Update
     Exit !0: Rollback reference, continue with next one.
* Post-receive hook:
  * can be used to update other services or notify users.
  * INPUT: STDIN reference list.
  * Useful for:
    * emailing a list.
    * trigger CI/CD.
    * update ticket system (commit messages can be parsed
      for "open/closed/...")
  * WARN : can't stop the push process. Client will block until completion.
[[}]]

## GIT Commit Standard Emojis: [[{]]
```
@[https://gist.github.com/parmentf/035de27d6ed1dce0b36a]
 Commit type               Emoji                    Graph
 Initial commit           :tada:                      🎉
 Version tag              :bookmark:                  🔖
 New feature              :sparkles:                  ✨
 Bugfix                   :bug:                       🐛
 Metadata                 :card_index:                📇
 Documentation            :books:                     📚
 Documenting src          :bulb:                      💡
 Performance              :racehorse:                 🐎
 Cosmetic                 :lipstick:                  💄
 Tests                    :rotating_light:            🚨
 Adding a test            :white_check_mark:          ✅
 Make a test pass        :heavy_check_mark:           ✔️
 General update           :zap:                       ⚡️
 Improve format           :art:                       🎨
 /structure
 Refactor code            :hammer:                    🔨
 Removing stuff           :fire:                      🔥
 CI                       :green_heart:               💚
 Security                 :lock:                      🔒
 Upgrading deps.         :arrow_up:                   ⬆️
 Downgrad. deps.         :arrow_down:                 ⬇️
 Lint                     :shirt:                     👕
 Translation              :alien:                     👽
 Text                     :pencil:                    📝
 Critical hotfix          :ambulance:                 🚑
 Deploying stuff          :rocket:                    🚀
 Work in progress         :construction:              🚧
 Adding CI build system   :construction_worker:       👷
 Analytics|tracking code  :chart_with_upwards_trend:  📈
 Removing a dependency    :heavy_minus_sign:          ➖
 Adding a dependency      :heavy_plus_sign:           ➕
 Docker                   :whale:                     🐳
 Configuration files      :wrench:                    🔧
 Package.json in JS       :package:                   📦
 Merging branches         :twisted_rightwards_arrows: 🔀
 Bad code / need improv.  :hankey:                    💩
 Reverting changes        :rewind:                    ⏪
 Breaking changes         :boom:                      💥
 Code review changes      :ok_hand:                   👌
 Accessibility            :wheelchair:                ♿️
 Move/rename repository  :truck:                      🚚
```
[[}]]

## GitHub Custom Bug/Feat-req templates [[{git.github]]

* WARN: Non standard (Vendor lock-in) Microsoft extension.

  ```
  $ cat .github/ISSUE_TEMPLATE/bug_report.md
  | ---
  | name: Bug report
  | about: Create a report to help us improve
  | title: ''
  | labels: ''
  | assignees: ''
  |
  | ---
  |
  | **Describe the bug**
  | A clear and concise description of what the bug is.
  |
  | **To Reproduce**
  | Steps to reproduce the behavior:
  | 1. Go to '...'
  | 2. Click on '....'
  | 3. Scroll down to '....'
  | 4. See error
  |
  | **Expected behavior**
  | A clear and concise description of what you expected to happen.
  |
  | ...
  ```


  ```
  | $ cat .github/ISSUE_TEMPLATE/feature_request.md
  | ---
  | name: Feature request
  | about: Suggest an idea for this project
  | title: ''
  | labels: ''
  | assignees: ''
  |
  | ---
  |
  | **Is your feature request related to a problem? Please describe.**
  | A clear and concise description of what the problem is....
  |
  | **Describe the solution you'd like**
  | A clear and concise description of what you want to happen.
  |
  | **Describe alternatives you've considered**
  | A clear and concise description of any alternative solutions or features you've considered.
  |
  | **Additional context**
  | Add any other context or screenshots about the feature request here.
  ```

  ```
  | $ cat ./.github/pull_request_template.md
  | ...
  ```

  ```
  | $ ./.github/workflows/*
  | WARN : Non standard (Vendor lock-in) Microsoft extension.
  | <https://docs.github.com/en/free-pro-team@latest/actions/learn-github-actions>
  ```
[[}]]

## Unbreakable Branches [[{git.bitbucket,qa,jenkins.troubleshooting]]
* <https://github.com/AmadeusITGroup/unbreakable-branches-jenkins>
* plugins for Bitbucket and Jenkins trying to fix next problem:
  ```
  | Normal Pull Request workflow:
  | Open pull-request (PR) to merge changes in target-branch
  |   → (build automatically triggered)
  |     → build OK
  |       repo.owner merges PR
  |        → second build triggered on target-branch
  |          →  second build randomnly fails
  |             leading to broken targeted branch
  |             └───────────────┬───────────────┘
  |              Reasons include:
  |              - Race condition: Parallel PR was merged in-between
  |              - Environment issue (must never happens)
  |              - lenient dependency declaration got another version
  |                leading to a build break
  ```
* If the Jenkins job is eligible to unbreakable build
  (by having environment variables such as UB_BRANCH_REF)
  at the end of the build a notification to Bitbucket is
  sent according to the build status.
  (or  manually through two verbs: ubValidate|ubFail)
* Difference stashnotifier-plugin:
  * stashplugin reports status-on-a-commit
  * unbreakable build a different API is dedicated on Bitbucket.
* On the Bitbucket side:
  * GIT HEAD@target-branch moved to  top-of-code to be validated in PR
    (target-branch can then always have a successful build status).
* Security restrictions added to Bitbucket:
  (once you activate the unbreakable build on a branch for your repository)
  * merge button replaced by merge-request-button to queue the build.
  * The merge will happen automatically at the end of the build if the build succeeds
  * direct push on the branch is forbidden
  * Merge requests on different PRs will process the builds sequentially
* Prerequisites to run the code locally:
  * Maven (tested agains 3.5)
  * Git should be installed
* PRE-SETUP:
  * Install UnbreakableBranch plugin at Bitbucket
  * bitbucketBranch source plugin Jenkins plugin should be
    a patched so that mandatory environment variables are
    injected.   Note that this plugin hasn't been released yet

## Git Filter Repo: 
* <https://github.com/newren/git-filter-repo/>
* Create new repository from old ones, keeping just the
  history of a given subset of directories.

## git-filter-branch 
* Replace: (buggy)filter-branch <https://git-scm.com/docs/git-filter-branch>
* Python script for rewriting history:
  * cli for simple use cases.
  * library for writing complex tools.
* Presetup:
  * git 2.22.0+  (2.24.0+ for some features)
  * python 3.5+
  * Example:
  ```
  | $ git filter-repo \
  |      --path src/ \                         ← commits not touching src/ removed
  |      --to-subdirectory-filter my-module \  ← rename  src/** → my-module/src/**
  |      --tag-rename '':'my-module-'            add 'my-module-' prefix to any tags
  |                                              (avoid any conflicts later merging
  |                                               into something else)
  ```
* Design rationale behind filter-repo :
  * None existing tools with similr features.
  * [Starting report] Provide analysis before pruning/renaming.
  * [Keep vs. remove] Do not just allow to remove selected paths
                      but to keep certain ones.<br/>
    (removing all paths except a subset can be painful.
     We need to specify all paths that ever existed in
     any version of the repository)
  * [Renaming] It should be easy to rename paths:
  * [More intelligent safety].
  * [Auto shrink] Automatically remove old cruft and repack the
    repository for the user after filtering (unless overridden);
  * [Clean separation] Avoid confusing users (and prevent accidental
    re-pushing of old stuff) due to mixing old repo and rewritten repo
    together.
  * [Versatility] Provide the user the ability to extend the tool
    ... rich data structures (vs hashes, dicts, lists, and arrays
        difficult to manage in shell)
    ... reasonable string manipulation capabilities
  * [Old commit references] Provide a way for users to use old commit
    IDs with the new repository.
  * [Commit message consistency] Rewrite commit messages pointing to other
    commits by ID.
  * [Become-empty pruning] empty commits should be pruned.
  * [Speed]
* Work on filter-repo and predecessor has driven
  improvements to fast-export|import (and occasionally other
  commands) in core git, based on things filter-repo needs to do its
  work:
* Manual Summary :
  * <https://htmlpreview.github.io/?https://github.com/newren/git-filter-repo/blob/docs/html/git-filter-repo.html>
* Overwrite entire repository history using user-specified filters.
  (WARN: deletes original history)
  * Use cases:
    * stripping large files (or large directories or large extensions)
    * stripping unwanted files by path (sensitive secrests) [secret]
    * Keep just an interesting subset of paths, remove anything else.
    * restructuring file layout. Ex:
      * move all files subdirectory
      * making subdirectory as new toplevel.
      * Merging two directories with independent filenames.
      * ...
    * renaming tags
    * making mailmap rewriting of user names or emails permanent
    * making grafts or replacement refs permanent
    * rewriting commit messages
[[}]]

# What's new <!-- { --> 

* 2.40
  * <https://www.infoq.com/news/2023/04/git-releases-version-2-40/>
* Git 2.37 Brings Built-in File Monitor, Improved Pruning, and More
* <https://www.infoq.com/news/2022/06/git-2-37-released/>
  According to Jeff Hostetler, the author of the patches for git's new
  file monitor, the implementation relies mostly on cross-platform code
  with custom backends leveraging OS-native features, i.e. FSEvents on
  macOS and ReadDirectoryChangesW on Windows. A Linux backend would
  probably use either inotify or fanotify, Hostetler says, but that
  work has not started yet.
* 2.35
  SSH signing you to use SSH-keys to sign certain kinds of objects in Git.
  * Git 2.35 includes a couple of new additions to SSH signing.
    * To track which SSH keys you trust, you use the ALLOWED SIGNERS FILE
      to store the identities and public keys of signers you trust.
      PROBLEM: NOW suppose one commiter rotates their key.
      * You could update their entry in the allowed signers file
        but that would make it impossible to validate objects signed with
        the older key.
      * You could store both keys, but that would mean that you
        would accept new objects signed with the old key.
      SOLUTION: Git 2.35 lets you take advantage of OpenSSH’s
                 valid-before and valid-after directives.
   * Git 2.35 also supports new key types in the user.signingKey
     configuration when you include the key verbatim (instead of storing
     the path of a file that contains the signing key). Previously, the
     rule for interpreting user.signingKey was to treat its value as a
     literal SSH key if it began with “ssh-“, and to treat it as
     filepath otherwise. You can now specify literal SSH keys with
     keytypes that don’t begin with “ssh-” (like ECDSA
     keys).[source, source]
<!-- } -->


# TODO [[{01_PM.TODO]]
## GitOps: Git as single source of truth
* for declarative infrastructure and 
  applications. Every developer within a team can issue pull requests against a
  Git repository, and when merged, a "diff and sync" tool detects a difference
  between the intended and actual state of the system. Tooling can then be
  triggered to update and synchronise the infrastructure to the intended state.
  <https://www.weave.works/blog/gitops-operations-by-pull-request>
[[{ci/cd.gitops}]]

## Scalar (Git v2.38+) [[{git.scalability,scalability.storage}]]
* <https://git-scm.com/docs/scalar>
* Replace previous Git LFS/VFS support for "big files and repositories
  with a native Git integration.
* Scalar improves performance by configuring advanced Git settings,
  maintaining repositories in the background, and helping to reduce
  data sent across the network.
* <https://github.blog/2022-10-13-the-story-of-scalar/>

## NostrGit [[{git.nostr]]
* <https://github.com/NostrGit/NostrGit>
  A truly censorship-resistant alternative to GitHub that has a chance of working
[[}]]

## 4 secrets encryption tools [[{security.secret_management}]]
* <https://www.linuxtoday.com/security/4-secrets-management-tools-for-git-encryption-190219145031.html>
* <https://www.atareao.es/como/cifrado-de-repositorios-git/>

## Garbage Collector [[{performance}]]
*  Git occasionally does garbage collection as part of its normal operation,
by invoking git gc --auto. The pre-auto-gc hook is invoked just before the
garbage collection takes place, and can be used to notify you that this is
happening, or to abort the collection if now isn’t a good time.


## sparse-checkout (Git v2.25+) allows to checkout just a subset [[{scalability]]
  of a given monorepo, speeding up commands like git pull and
  git status.
@[https://github.blog/2020-01-17-bring-your-monorepo-down-to-size-with-sparse-checkout/] [[}]]

## Advanced Git:
* revert/rerere:
* Submodules:
* Subtrees:
  * TODO: how subtrees differ from submodules
  * how to use the subtree to create a new project from split content
* Interactive rebase:
  * how to rebase functionality to alter commits in various ways.
  * how to squash multiple commits down into one.
* Supporting files:
  * Git attributes file and how it can be used to identify binary files,
    specify line endings for file types, implement custom filters, and
    have Git ignore specific file paths during merging.
* Cregit token level blame:
@[https://www.linux.com/blog/2018/11/cregit*token-level-blame-information-linux-kernel]
cregit: Token*Level Blame Information for the Linux Kernel
Blame tracks lines not tokens, cgregit blames on tokens (inside a line)

## Gitea painless self-hosted Git) [[{01_PM.TODO,01_PM.low_code]]
("replaced" unmaitained Gogs)
* <https://gitea.io/>
* Fork of gogs, since it was unmaintained.

## Gerrit (by Google)</span>
* <https://www.gerritcodereview.com/index.html>
Gerrit is a Git Server that provides:
* Code Review:
  * One dev. writes code, another one is asked to review it.
    (Goal is cooperation, not fauilt-finding)
  * <https://docs.google.com/presentation/d/1C73UgQdzZDw0gzpaEqIC6SPujZJhqamyqO1XOHjH*uk/>
  * UI for seing changes.
  * Voting pannel.
* Access Control on the Git Repositories.
* Extensibility through Java plugins.
  <https://www.gerritcodereview.com/plugins.html>

* Gerrit does NOT provide:
  * Code Browsing
  * Code Search
  * Project Wiki
  * Issue Tracking
  * Continuous Build
  * Code Analyzers
  * Style Checkers
[[}]]

## Git Secrets: [[{qa,security.secret_management}]]
* <https://github.com/awslabs/git-secrets#synopsis>
  Prevents you from committing passwords and other sensitive
  information to a git repository.

## Forgit: Interactive Fuzzy Finder:[[{dev_stack.forgit,qa.UX,01_PM.TODO]]
* <https://www.linuxuprising.com/2019/11/forgit-interactive-git-commands-with.html>
* It takes advantage of the popular "fzf" fuzzy finder to provide
  interactive git commands, with previews. [[}]]

## Isomorphic Git: 100% JS client [[{security.gpg]]
@[https://isomorphic-git.org/] !!!

* Features:
  * clone repos
  * init new repos
  * list branches and tags
  * list commit history
  * checkout branches
  * push branches to remotes
  * create new commits
  * git config
  * read+write raw git objects
  * PGP (GPG) signing
  * file status
  * merge branches
[[}]]

## Git Monorepos: [[{qa.UX,scalability}]]
* (Big) Monorepos in Git:
  * <https://www.infoq.com/presentations/monorepos/>
  * <https://www.atlassian.com/git/tutorials/big-repositories>

## Git: Symbolic Ref best-patterns
* <https://stackoverflow.com/questions/4986000/whats-the-recommended-usage-of-a-git-symbolic-reference>

## GitHub: Search by topic: [[{git.github}]]
* <https://help.github.com/en/github/searching-for-information-on-github/searching-topics>
* Ex:search by topic ex "troubleshooting" and language "java"
  <https://github.com/topics/troubleshooting?l=java>

## Gitsec: [[{security.secret_management,qa}]]
* <https://github.com/BBVA/gitsec>
  gitsec is an automated secret discovery service for git that helps
  you detect sensitive data leaks.
  gitsec doesn't directly detect sensitive data but uses already
  available open source tools with this purpose and provides a
  framework to run them as one.

## when to avoid git-rebase [[{101.rebase]]
https://www.javacodegeeks.com/2024/03/when-to-avoid-git-rebase.html
[[101.rebase}]]

## Alternatives to git

* Fossil, Plastic, Pijal  
