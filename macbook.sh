#!/bin/sh
echo "This will install a bunch of utilities via HomeBrew"
echo "After installation this machine WILL restart"

cd brew || exit
sh brew.sh

sh actionlint.sh
sh antigravity.sh
sh awscli.sh
sh betterleaks.sh
sh brave.sh
sh chrome.sh
sh chromium.sh
sh code.sh
sh discord.sh
sh docker.sh
sh edge.sh
sh firefox.sh
sh gemini.sh
sh gh.sh
sh go.sh
sh helix.sh
sh helm.sh
sh hk.sh
sh jdk.sh
sh kind.sh
sh kubectl.sh
sh kubectx.sh
sh lua.sh
sh mise.sh
sh node.sh
sh obs.sh
sh obsidian.sh
sh oc.sh
sh ollama.sh
sh opencode.sh
sh openssh.sh
sh openssl.sh
sh pkl.sh
sh podman.sh
sh python.sh
sh retroarch.sh
sh slack.sh
sh talosctl.sh
sh tombi.sh
sh trivy.sh
sh uv.sh
sh yamllint.sh
sh zed.sh

cd ../npm || exit
sh angular-cli.sh
sh jules.sh
sh nodemon.sh
sh vue-cli.sh
