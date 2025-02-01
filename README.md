# Vencord Launcher

Quickly and conveniently launch Vencord.

# Windows

Download and run [the latest installer](https://github.com/MeguminSama/Vencord-Launcher/releases/latest/download/VencordInstaller.exe) and pick the branches of Discord you want.

# Linux

## Stable

```
sh -c "$(curl -fsSL https://github.com/MeguminSama/Vencord-Launcher/releases/latest/download/install.sh)"
```

## PTB
```
sh -c "$(curl -fsSL https://github.com/MeguminSama/Vencord-Launcher/releases/latest/download/install.sh)" -- ptb
```

## Canary
```
sh -c "$(curl -fsSL https://github.com/MeguminSama/Vencord-Launcher/releases/latest/download/install.sh)" -- canary
```

## Uninstalling
```
sh -c "$(curl -fsSL https://github.com/MeguminSama/Vencord-Launcher/releases/latest/download/install.sh)" -- --uninstall <branch>
```

# MacOS

Working on it...


# Commandline Arguments

## Using a local (git) instance of a mod?

You can pass the `--local` flag with a path to the entrypoint. For example:

```
vencord-stable --local $HOME/workspace/vencord/patcher.js
```

## Passing arguments through to discord?

Any arguments passed after `--` are passed through to Discord. For example:

```
vencord-stable -- --start-minimized --enable-blink-features=MiddleClickAutoscroll
```
