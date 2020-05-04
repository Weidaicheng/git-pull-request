#  git-pull-request
git-pull-request is an extension script based on [PowerShell Core](https://github.com/PowerShell/PowerShell) for git to manage PRs on Github. It's easy to use.

### Preparation
To use this, PowerShell Core needs to be installed on your machine firstly.
- Windows [install](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7).
- Linux [install](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7).
- Mac [Install](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7).

And also, [git](https://git-scm.com/) needs to be installed firstly.

### How to install
1. Download scripts from [release](https://github.com/Weidaicheng/git-pull-request/releases) page.
2. Running `install.ps1` in your terminal.
4. Now restart your terminal(If needed), and try `git pull-request`, you should see outputs like this:
```
Usages: pull-request [options] [command] [command-options] [arguments]

Options:
  -h|--help     Get help.
  -v|--version  Get version information.

Commands:
  list          List pull requests from pull remote.
  show          Show pull request detail by number.
  commits       Show commits by number.
  files         Show changed files by number.
  diff          Show diff information by number.
  new           Create a new pull request.
  close         Close pull request by number.
  open          Re-Open pull request by number.
  merge         Merge pull request by number.
  setting       Show/Set configuration.
```


### Examples
- #### Manage setting
  `git pull-request setting` to list all settings.
  `git pull-request setting.Key Value` to set a value.

	Token must have been set before create/close/reopen/merge a pull request.

- ##### View all pull requests by state
  `git pull-request list` to list all open pull requests.

- ##### View specific pull request by number
  `git pull-request show 1` to show pull request 1 details.
  
- ##### Create a new pull request
  `git pull-request new 'message'` to create a new pull request.
  
- ##### Close a pull request
  `git pull-request close 1` to close pull request 1.
  
- ##### merge a pull request
  `git pull-reuqest merge 1` to merge pull request 1.

More usages and options, please use -h|--help command to check.

### Contributing
Please don't hesitate to raise a PR if you have any cool idea.

### Report bugs
Please go to [Github issues](https://github.com/Weidaicheng/git-pull-request/issues).