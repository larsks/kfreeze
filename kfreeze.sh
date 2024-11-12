#!/bin/bash

: "${KUBECTL:=kubectl}"
: "${KUBECTL_FREEZE_DIR:=$HOME/.kube/freeze}"

kubectl_freeze() {
  if [[ -n $kubeconfig_frozen ]]; then
    echo "ERROR: already frozen to $("$KUBECTL" config current-context)" >&2
    return 1
  fi

  mkdir -p "$KUBECTL_FREEZE_DIR"
  kubeconfig_tmp=$(mktemp -p "$KUBECTL_FREEZE_DIR" kubeconfigXXXXXX)
  kubeconfig_ctx=$("$KUBECTL" config current-context)
  if ! "$KUBECTL" config view --flatten --minify > "$kubeconfig_tmp"; then
    rm -f "$kubeconfig_tmp"
    echo "ERROR: failed to freeze" >&2
    return 1
  fi

  export KUBECONFIG="$kubeconfig_tmp"
  kubeconfig_frozen=1
  echo "Kubeconfig frozen to context $kubeconfig_ctx"
}

kubectl_thaw() {
  if [[ -z $kubeconfig_frozen ]]; then
    echo "ERROR: not frozen" >&2
    return 1
  fi

  rm -f "$kubeconfig_tmp"
  unset kubeconfig_frozen
  unset kubeconfig_tmp
  unset KUBECONFIG

  echo "Kubeconfig no longer frozen; current context is: $("$KUBECTL" config current-context)"
}

alias kfreeze=kubectl_freeze
alias kthaw=kubectl_thaw
alias kunfreeze=kubectl_thaw
