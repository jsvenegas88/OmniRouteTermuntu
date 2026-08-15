# OmniRouteTermuntu

A one-command launcher that starts OmniRoute (https://github.com/diegosouzapw/OmniRoute) and Claude Code from a fresh Termux session on Android — no manual server-start, no separate terminal tabs.

This is NOT OmniRoute itself. It automates the Android/Termux-specific setup OmniRoute's docs don't cover: running inside a proot-distro Ubuntu environment (Claude Code's native binary isn't built for Android), fixing a Node.js version bug that silently breaks OmniRoute's server, and wiring it all into a single command.

## What it does

Typing `omnicode` in plain Termux will:
1. Log into your proot-distro Ubuntu environment
2. Load Node.js 24 via nvm
3. Start the OmniRoute server in the background
4. Show a live progress bar while the server comes up
5. Launch Claude Code, pointed at your local OmniRoute gateway

## Why this exists

Claude Code's native binary isn't published for linux-arm64-android, so it must run inside a proot-distro Ubuntu container instead of plain Termux. That introduces a few rough edges this script handles automatically:

- Ubuntu's default nodejs package (22.22.1) is one patch behind OmniRoute's required minimum. This doesn't throw a clear error — the server starts but silently returns Internal Server Error on real requests. Fixed by installing Node 24 via nvm.
- Backgrounding the server naively can get torn down when the wrapping shell exits, so it uses nohup + disown from inside a persistent script.
- proot-distro shares Termux's network namespace, so localhost works the same across both.

## Prerequisites

- Termux with proot-distro and an Ubuntu container set up
- Node.js and npm installed inside that Ubuntu environment
- OmniRoute installed globally inside Ubuntu (npm install -g omniroute)
- Claude Code installed globally inside Ubuntu (npm install -g @anthropic-ai/claude-code)

## Setup

1. Inside Ubuntu, install nvm and Node 24:
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
   source ~/.bashrc
   nvm install 24
   nvm use 24

2. Reinstall OmniRoute and Claude Code under the new Node version:
   npm install -g omniroute
   npm install -g @anthropic-ai/claude-code

3. Save omniroute-start.sh to ~/omniroute-start.sh inside Ubuntu, then:
   chmod +x ~/omniroute-start.sh

4. Back in plain Termux, add this alias to ~/.bashrc:
   alias omnicode='proot-distro login ubuntu -- bash -c "~/omniroute-start.sh"'

5. From a fresh Termux session:
   omnicode

## Model quality note

OmniRoute's free-tier routing (auto, auto/claude-opus, etc.) does NOT call real Anthropic models — it substitutes other providers' models under Claude-shaped labels. Response quality will differ from actual Claude. Run `omniroute models` to see the real backend model IDs. For genuine Claude responses, add your own Anthropic API key or subscription as a provider in OmniRoute's config.

## Dashboard

Once `omnicode` is running, view OmniRoute's dashboard at:

http://localhost:20128

See live provider status, usage/cost analytics, add API keys or subscriptions, and manage routing combos. This link also prints automatically at the start of every `omnicode` run.

## Screenshots

1. Progress bar while OmniRoute starts:



![Progress bar](assets/ScreenshotTermux3.jpg)



2. Trusting the workspace:



![Workspace trust screen](assets/ScreenshotTermux2.jpg)



3. Claude Code running through the free gateway:



![Claude Code running](assets/ScreenshotTermux.jpg)



## Credit

Built on top of OmniRoute (https://github.com/diegosouzapw/OmniRoute) (MIT licensed) and Claude Code (https://www.npmjs.com/package/@anthropic-ai/claude-code). This repo only provides the Android/Termux launcher wrapper.

## Development note

Built with help from Claude (Anthropic) for debugging and scripting.

## License

MIT
