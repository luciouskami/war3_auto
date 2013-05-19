#!/bin/bash

if [ $# -lt 1 ]; then
        exit 1
fi

STARTX=450
STARTY=200
HEIGHT=170
WIDTH1=150
WIDTH2=240
HEROX=1140
HEROY=720
WIDTH3=80
HEIGHT3=60

hero_id="0_0"
tavern_id="0"
ord="0"

tag_loc=""

get_target_line_num() {
        cat $1 | egrep -n '\$' | awk '{print $1}' | awk -F: '{print $1}'
}

arr=()
str2arr() {
        c=0

        for s in $@
        do
                c=`expr $c + 1`
                arr[$c]=$s
        done
}

x=`get_target_line_num $1`
str2arr $x

print_para() {
        START=`expr $1 + 1`
        END=`expr $2 - 1`

        sed -n "$START,${END}p" $3
        # demo : print_para 11 16 $1
}

cur_token=0

next_token() {
        c=0
        for i in ${arr[*]}
        do
                c=`expr $c + 1`
                if [ $i -eq $cur_token ]; then
                        break
                fi
        done
        echo ${arr[`expr $c + 1`]}

}

calcu_tavern_location() {
        x=0
        y=0
        t=0
        if [ "$[$1%2]" == "1" ]; then
                t=$[2*$1+1]
        else
                t=$[2*$1-1]
        fi

        flag=$[$t%3]
        if [ "$[$1%2]" = "1" ]; then
                x=$STARTX

        else
                x=$[$STARTX+$WIDTH1]
        fi
        y=$[$STARTY+$flag*$HEIGHT]
        printf $x\,$y
}

calcu_hero_location() {
        x=$[($1-1)%4]
        y=$[($1-1)/4]
        _x=$[$HEROX+$WIDTH3*$x]
        _y=$[$HEROY+$HEIGHT3*$y]
        printf $_x,$_y
}
        

c=0
for i in ${arr[*]}
do
        cur_token=$i
        tmp=$(next_token)
        c=`expr $c + 1`
        if [ "$c" -gt "6" ]; then
                STARTX=$[$STARTX+$WIDTH1+$WIDTH2]
                c=1
        fi
        if [ -n "$tmp" ]; then
                para=`print_para $i $tmp $1 | grep '#' | \
                        awk -F'#' '{print $2}'`
                _c=0
                for line in $para
                do
                        _c=`expr $_c + 1`
                        printf $line:
                        calcu_tavern_location $c
                        echo \;`calcu_hero_location $_c`
                done
        else
                sed -n "`expr $i + 1`,`cat $1 | wc -l`p" $1
        fi
done

