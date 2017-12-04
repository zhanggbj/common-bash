# This is an example for retry and timeout as operation "kubectl edit cm" need some time to take effect.
# retry at most 60 times.
#!/bin/bash -x
function add_custom_port () {
  kubectl get cm cm-1 -o yaml -n kube-system > /tmp/cm.yaml
  cat /tmp/cm.yaml
  sed -i '/apiVersion: v1/a data:\n  public-ports: 80;443;2793;2222;4443' /tmp/cm.yaml
  kubectl apply -f /tmp/cm.yaml
  rm -rf /tmp/cm.yaml
  x=1
  while [ $x -le 60 ]
  do
    set +e
    out="out$RANDOM"
    kubectl -n kube-system get cm cm-1 -o yaml > $out 2>&1
    grep "80;443;2793;2222;4443" $out > /dev/null 2>&1
    gre=$?
    rm $out
    set -e
    if [[ $gre -ne 0 ]]; then
      sleep 10
    else
      sleep 2
      break
    fi
    x=$(( $x + 1 ))
  done

  if [ $x == 61 ]; then
    exit 1
  fi
}

add_custom_port