#!/bin/sh

setcolors() {
    if test -z "$COLORTERM" || test -z "${TERM#'*color'}" ; then
	return
    fi
}

for arg in "$@"; do
    case "$arg" in
	"-c")
	    setcolors
	    ;;
    esac
done

OS="$(uname -s)"
VERS="$(uname -r)"


command -v acpi >/dev/null && \
BAT="battery: $(acpi | awk '{print $4}')"

case $OS in
    *BSD)
        CPU="$(sysctl -n hw.model)"
        UPTIME="$(uptime | awk '{gsub(/,/,"") print $3 $4)}')"
        MEM="$(top -n 1 -b | awk '/Memory/{print $3}')" 
        if test -z "$MEM"; then
            if test -f /proc/meminfo; then
                MEMF="$(awk '/MemFree/{print int($2/10^3)}' /proc/meminfo)"
    		MEMC="$(awk '/Cached/{print int($2/10^3)}' /proc/meminfo)"
	        MEMA="$(( MEMF+MEMC ))"
                MEMT="$(awk '/MemTotal/{print int($2/10^3)}' /proc/meminfo)"
                MEM="$(( MEMT-MEMA ))/${MEMT}M"
            else
                MEMT="$(vmstat -h | awk 'NR==3{print $4}')"
                MEMF="$(vmstat -h | awk 'NR==3{gsub(/M/,""); print $5}')"
                MEM="$MEMF/$MEMT"
            fi
        fi
        ;;
    Darwin)
	CPU="$(sysctl -n machdep.cpu.brand_string)"
	;;
    *Linux)
        CPU="$(awk '/model name/{$1=$2=$3=""; sub(/ */,""); print $0}' \
                /proc/cpuinfo | uniq)"
        T="$(awk '{print int($1)}' /proc/uptime)"
	UPTIME="$(printf '%dd %dh %dm\n' \
		$(( $T/86400 )) $(( $T%86400/3600 )) $(( $T%3600/60 )))"
        MEMA="$(awk '/MemAvailable/{print int($2/10^3)}' /proc/meminfo)"
        if test -z "$MEMA"; then
            MEMF="$(awk '/MemFree/{print int($2/10^3)}' /proc/meminfo)"
	    MEMC="$(awk '/Cached/{print int($2/10^3)}' /proc/meminfo)"
	    MEMA="$(( MEMF+MEMC ))"
        
        fi
        MEMT="$(awk '/MemTotal/{print int($2/10^3)}' /proc/meminfo)"
        MEM="$(( MEMT-MEMA ))/${MEMT}M"
        ;;
    *)
        ;;
esac

test -z "$CPU" && CPU="Unknown"
test -z "$MEM" && MEM="Unknown"
tput setaf  $(( ( RANDOM % 7 ) + 1))
cat << EOF

      101001011000101010101011001                  
      110101011101010111100101011     $USER@$(/bin/hostname)
      101010101111011010111110101            
      110101101100101110101010101     OS: $OS
      100101110101011010100101101     UPTIME: $UPTIME
      100111010101010111100101011     CPU: $CPU
      101010010011010101011010100     Memory: $MEM
      011010101010100011110101010     Terminal: $TERM
      001101110101011011011101100     Shell: $SHELL
      001101100101101101010101010     
   
EOF
tput sgr0
unset MEM MEMF MEMA MEMC MEMT BAT CPU UPTIME VERS OS
