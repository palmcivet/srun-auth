# !/bin/sh
# annote: For authentication to Srun.
# author: Palm Civet
# date: 2020.05.18

base() {
	res=`echo "$1" | base64`
	len=${#res}
	echo ${res:0:((len-4))}
}

urlencode() {
	export LANG=C
	res=""
	arg="$1"
	i="0"
	while [ "$i" -lt ${#arg} ]; do
		c=${arg:$i:1}
		if echo "$c" | grep -q '[a-zA-Z0-9/:_\.\-]'; then
			printf $c
		elif [ "$c" = " " ]; then
			printf "+"
		else
			printf "%%%X" "'$c'"
		fi
		i=$((i+1))
	done
}

if [ $# = 2 ]; then
	NAME=$1
	PASS=`urlencode "\`base "$2"\`"`
	echo $NAME $PASS
else
	echo Usage: ./cmcc-auth.sh [ myName my123456 ]
	exit 1
fi

curl --location --request POST 'http://10.1.254.72:803/include/auth_action.php' \
--header 'accept: */*' \
--header 'accept-encoding: gzip, deflate' \
--header 'accept-language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2' \
--header 'connection: keep-alive' \
--header 'content-length: 122' \
--header 'content-type: application/x-www-form-urlencoded; charset=UTF-8' \
--header 'cookie: language=en; optimizelyEndUserId=oeu1589792986493r0.4834943958572333; optimizelySegments=%7B%22173031668%22%3A%22direct%22%2C%22173358367%22%3A%22false%22%2C%22173387060%22%3A%22ff%22%7D; optimizelyBuckets=%7B%7D; AMCV_8D6C67C25245AF020A490D4C%40AdobeOrg=283337926%7CMCIDTS%7C18401%7CMCMID%7C28758766152708140933518197837924390054%7CMCAID%7CNONE; mbox=session#1589792986565-496581#1589796073|em-disabled#true#1589794792|check#true#1589794273; s_sess=%20v0%3DExternal%2520Websites%257C10.1.254.72%3B%20s_cc%3Dtrue%3B%20s_sq%3Dsalesforcedeskstage%253D%252526pid%25253DDESK%2525253A10%2525253Aus%2525253Asrun_portal_pcyd.php%252526pidt%25253D1%252526oid%25253D%252525E7%25252599%252525BB%252525E9%25252599%25252586%252526oidt%25253D3%252526ot%25253DSUBMIT%3B; optimizelyPendingLogEvents=%5B%22n%3Dengagement%26u%3Doeu1589792986493r0.4834943958572333%26wxhr%3Dtrue%26time%3D1589794215.751%26f%3D3417450523%2C3478260568%2C3481252022%2C3735817878%26g%3D109615771%22%2C%22n%3Dhttp%253A%252F%252F10.1.254.72%253A803%252Fsrun_portal_pcyd.php%253Fac_id%253D2%2526wlanuserip%253D10.45.1.63%2526wlanacname%253D%2526wlanuserfirsturl%253Dhttp%253A%252F%252F192.168.137.100%252Findex_2.html%253Furl%253D%26u%3Doeu1589792986493r0.4834943958572333%26wxhr%3Dtrue%26time%3D1589794212.864%26f%3D3417450523%2C3478260568%2C3481252022%2C3735817878%26g%3D%22%5D' \
--header 'dnt: 1' \
--header 'host: 10.1.254.72:803' \
--header 'origin: http://10.1.254.72:803' \
--header 'referer: http://10.1.254.72:803/srun_portal_pcyd.php?ac_id=2&wlanuserip=10.45.1.63&wlanacname=&wlanuserfirsturl=http://192.168.137.100/index_2.html?url=' \
--header 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:76.0) Gecko/20100101 Firefox/76.0' \
--header 'x-requested-with: XMLHttpRequest' \
--header 'Content-Type: text/plain' \
--data-raw "action=login&username="${NAME}"&password={B}"${PASS}"&ac_id=2&user_ip=10.45.1.63&nas_ip=&user_mac=&save_me=0&ajax=1"
