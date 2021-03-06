#!/bin/bash -e

case "$0" in 
    *install*)
        http_proxy="$1"
        https_proxy="$2"
        no_proxy="$3"

        proxy_config=/etc/apt/apt.conf.d/99proxy
        if [ ! -f $proxy_config ]; then
            echo "Acquire:http:Proxy \"$http_proxy\";" > $proxy_config
        fi

        env_config=/etc/environment
        if [ -z "$(grep -E '_(proxy|PROXY)=' $env_config)" ]; then
            echo "http_proxy=\"$http_proxy\"" >> $env_config
            echo "https_proxy=\"$https_proxy\"" >> $env_config
            echo "no_proxy=\"$no_proxy\"" >> $env_config
        fi
        ;; 
    *setup*)
        if test ! -f ~/.ssh/id_rsa; then
            cat /dev/zero | ssh-keygen -q -N ""
        fi

        http_proxy=${http_proxy:-${HTTP_PROXY}}
        https_proxy=${https_proxy:-${HTTPS_PROXY}}
        no_proxy=${no_proxy:-${NO_PROXY}}

        NODEUSER="root"
        for nodeip in $(sudo vcactl network ip 2> /dev/null | grep -E '^[0-9.]+$'); do
            ssh-copy-id $NODEUSER@${nodeip} 2> /dev/null || echo
            scp /etc/resolv.conf $NODEUSER@$nodeip:/etc/resolv.conf
            ssh $NODEUSER@$nodeip "timedatectl set-timezone $(timedatectl | awk '/Time zone:/{print$3}')"
            ssh $NODEUSER@$nodeip "date -s \"$(date)\""
            scp "$0" $NODEUSER@$nodeip:/root/install-access.sh
            ssh $NODEUSER@$nodeip /root/install-access.sh "$http_proxy" "$https_proxy" "$no_proxy"
        done
        ;;
esac


