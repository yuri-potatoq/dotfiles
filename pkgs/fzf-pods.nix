# copy from https://github.com/ratsclub/dotfiles/commit/2c01721b7d5bb2eb9ebaeea97594ddd153020046#diff-99fa9069b543b620d2065321791e3f9feb70e3e08fcad6c9d0a39f195cd2e27e

{ pkgs, ... }:

# Helper to see all kubernetes pods and their logs

let
  writeShellScriptBin = pkgs.writeShellScriptBin;
  fzf = "${pkgs.fzf}/bin/fzf";
  kubectl = "${pkgs.kubectl}/bin/kubectl";
in
writeShellScriptBin "fzf-pods" ''
  FZF_DEFAULT_COMMAND="${kubectl} get pods --all-namespaces" \
    ${fzf}  --info=inline --layout=reverse --header-lines=1 \
            --prompt "$(${kubectl} config current-context | sed 's/-context$//')> " \
            --header $'/ Enter (${kubectl} exec) / CTRL-O (open log in editor) / CTRL-R (reload) /\n\n' \
            --bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
            --bind 'enter:execute:${kubectl} exec -it --namespace {1} {2} -- bash > /dev/tty' \
            --bind 'ctrl-o:execute:${EDITOR:-vim} <(${kubectl} logs --all-containers --namespace {1} {2}) > /dev/tty' \
            --bind 'ctrl-r:reload:$FZF_DEFAULT_COMMAND' \
            --preview-window up:follow \
            --preview '${kubectl} logs --follow --all-containers --tail=10000 --namespace {1} {2}' "$@"
''
