# xopen-cli

`xopen` command helps you open your project using Xcode.

## Example

most of case you develop Apple Platform Apps,

```sh
$ cd <your repository's root directory>
$ xopen
```

That's it.

`xopen` automatically discovers files like `Package.swift`, `xcworkspace` and `.xcodeproj` Breadth-First Search algorithm.

## Extras

I would pick up some features that I love. If you want to know other options of `xopen`, please check `xopen --help` or `xopen <subcomand> --help`.

### .xcode-version

`xopen` will determine the version of Xcode to use according to the version listed in the `.xcode-version` file. If you are developing multiple projects and each project is using a different version of Xcode, you will no longer be using the wrong Xcode version. You can simply run the `xopen` command and it will open the project in the appropriate Xcode.

You can open your project using `--use` option as well. The arguments of `--use` are `beta`, `latest` and semantic version string.

### histories

`xopen` has a subcommand called `history` which just prints file paths you recently open by `xopen`. Do you know how effective this is? When used with a filtering tool like [peco](https://github.com/peco/peco), you can easily open the desired project in Xcode with incremental search, no matter where you are in the directory.

## How to install

Download [release_binary.zip](https://github.com/griffin-stewie/xopen-cli/releases/latest) and unzip & put `xopen` command wherever you like.

- [ ] Support homebrew