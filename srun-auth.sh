# !/bin/bash
# annote: For authentication to Srun.
# author: Palm Civet

base_64() {
	TXT=`echo "$1" | base64`
	RES=${TXT:0:$((${#TXT} - 4))}
	echo $RES
}

encode_url() {
	export LANG=C
	res=''
	arg="$1"
	i='0'
	while [ "$i" -lt ${#arg} ]; do
		c=${arg:$i:1}
		if echo "$c" | grep -q '[a-zA-Z0-9/:_\.\-]'; then
			printf $c
		elif [ "$c" = ' ' ]; then
			printf '+'
		else
			printf "%%%X" "'$c'"
		fi
		i=$((i+1))
	done
}

check_ip() {
    if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        FIELD1=$(echo $1 | cut -d. -f 1)
        FIELD2=$(echo $1 | cut -d. -f 2)
        FIELD3=$(echo $1 | cut -d. -f 3)
        FIELD4=$(echo $1 | cut -d. -f 4)
        if [ $FIELD1 -le 255 -a $FIELD2 -le 255 -a $FIELD3 -le 255 -a $FIELD4 -le 255 ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# detect curl & base64
hash curl 2>/dev/null || { echo >&2 "Can't find curl"; exit 1; }
hash base64 2>/dev/null || { echo >&2 "Can't find base64"; exit 1; }

# parse options
while getopts 'u:p:' opt
do
    case $opt in
        u)
            USER=$OPTARG
            ;;
        p)
            PASS=`encode_url "\`base_64 "$OPTARG"\`"`
            ;;
        ?)
            exit 1
            ;;
    esac
done

# check arguments
if test -z "$USER" || test -z "$PASS"; then
    echo "Usage: srun-auth.sh -u yourName -p yourPass [IP]"
    exit 1
else
    shift $(($OPTIND - 1))
    IP=$1
    # IP isn't empty
    if test -n "$IP"; then
        check_ip $IP
        if [[ $? != 0 ]]; then
            echo "Invalid IP: ${IP}"
            exit 1
        fi
    # IP is empty
    else
		OPTION=`ifconfig | grep 'inet' | grep -v '127.0.0.1' | cut -d : -f 2 | awk '{print $2}' | sed -e '/^$/d'`
		echo "$OPTION" | nl
		EDGE=`echo "$OPTION" | awk 'END{print NR}'`

		read -p "Select IP(1-${EDGE}):" INDEX
		if [[ $INDEX -le $EDGE ]]; then
			IP=`echo "$OPTION" | sed -n "$INDEX"p`
		else
			echo "Invalid number"
			exit 1
		fi
    fi
fi

curl --location --request POST "http://10.1.254.72:803/include/auth_action.php" \
--header "accept: */*" \
--header "accept-encoding: gzip, deflate" \
--header "accept-language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2" \
--header "content-length: 122" \
--header "content-type: application/x-www-form-urlencoded; charset=UTF-8" \
--header "connection: keep-alive" \
--header "cookie: language=en; optimizelyEndUserId=oeu1589792986493r0.4834943958572333; optimizelySegments=%7B%22173031668%22%3A%22direct%22%2C%22173358367%22%3A%22false%22%2C%22173387060%22%3A%22ff%22%7D; optimizelyBuckets=%7B%7D; AMCV_8D6C67C25245AF020A490D4C%40AdobeOrg=283337926%7CMCIDTS%7C18401%7CMCMID%7C28758766152708140933518197837924390054%7CMCAID%7CNONE; mbox=session#1589792986565-496581#1589796073|em-disabled#true#1589794792|check#true#1589794273; s_sess=%20v0%3DExternal%2520Websites%257C10.1.254.72%3B%20s_cc%3Dtrue%3B%20s_sq%3Dsalesforcedeskstage%253D%252526pid%25253DDESK%2525253A10%2525253Aus%2525253Asrun_portal_pcyd.php%252526pidt%25253D1%252526oid%25253D%252525E7%25252599%252525BB%252525E9%25252599%25252586%252526oidt%25253D3%252526ot%25253DSUBMIT%3B; optimizelyPendingLogEvents=%5B%22n%3Dengagement%26u%3Doeu1589792986493r0.4834943958572333%26wxhr%3Dtrue%26time%3D1589794215.751%26f%3D3417450523%2C3478260568%2C3481252022%2C3735817878%26g%3D109615771%22%2C%22n%3Dhttp%253A%252F%252F10.1.254.72%253A803%252Fsrun_portal_pcyd.php%253Fac_id%253D2%2526wlanuserip%253D"${IP}"%2526wlanacname%253D%2526wlanuserfirsturl%253D%26u%3Doeu1589792986493r0.4834943958572333%26wxhr%3Dtrue%26time%3D1589794212.864%26f%3D3417450523%2C3478260568%2C3481252022%2C3735817878%26g%3D%22%5D" \
--header "dnt: 1" \
--header "host: 10.1.254.72:803" \
--header "origin: http://10.1.254.72:803" \
--header "x-requested-with: XMLHttpRequest" \
--header 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:76.0) Gecko/20100101 Firefox/76.0' \
--header "referer: http://10.1.254.72:803/srun_portal_pcyd.php?ac_id=2&wlanuserip=${IP}&wlanacname=&wlanuserfirsturl=" \
--data-raw "action=login&username=${USER}&password={B}${PASS}&ac_id=2&user_ip=${IP}&nas_ip=&user_mac=&save_me=1&ajax=1"
