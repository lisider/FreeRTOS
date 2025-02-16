#########################################################################
# File Name: do_freertos.sh
# Author: SuWeishuai
# mail: suwsl@foxmail.com
# Created Time: Sat 02 Jul 2022 01:15:22 AM CST
# Version : 1.0
#########################################################################
#!/bin/bash

Build(){
    [ -f log_build ] && mv log_build log_build_bak

    make DEBUG=1 2>&1 | tee log_build
}

Clean(){
    make clean
}

Run(){
    [ -f log_run ] && mv log_run log_run_bak

    qemu-system-riscv64 -nographic -machine virt -net none  \
        -chardev stdio,id=con,mux=on -serial chardev:con    \
        -mon chardev=con,mode=readline -bios none           \
        -smp 4 -kernel ./build/RTOSDemo.axf                 \
        2>&1 | tee log_run
}


Debug_run(){
    [ -f log_run ] && mv log_run log_run_bak
    [ -f log_gdb ] && mv log_gdb log_gdb_bak

    qemu-system-riscv64 -nographic -machine virt -net none  \
        -chardev stdio,id=con,mux=on -serial chardev:con    \
        -mon chardev=con,mode=readline -bios none           \
        -smp 4 -kernel ./build/RTOSDemo.axf                 \
        -S -s                                               \
        2>&1 | tee log_run
}

Debug_gdb(){
    echo "set logging file log_gdb"     >  gdb_init
    echo "set logging on"               >> gdb_init
    echo "set  architecture riscv:rv64" >> gdb_init
    echo "target remote localhost:1234" >> gdb_init
    echo "b _start"                     >> gdb_init
    riscv64-unknown-linux-gnu-gdb -x gdb_init -tui ./build/RTOSDemo.axf
}

Simple(){
    # 1. checkout if build
    [ ! -e build ]                                          \
        && echo please build first                          \
        && exit -2

    # 2. create dir for output
    TOP_DIR=../../

    TMP1=`pwd`
    TMP2=${TMP1%/*}
    TMP3=${TMP2%/*}/
    PATH_FOR_SED=$(echo ${TMP3} | sed   's/\//\\\//g')

    PRO_NAME=${TMP1##*/}
    SIMPLE_PRO_NAME=${PRO_NAME}_simple

    SIMPLE_PRO_DIR=../../../${SIMPLE_PRO_NAME}

    [ -d ${SIMPLE_PRO_DIR} ] && rm ${SIMPLE_PRO_DIR} -rf
    mkdir ${SIMPLE_PRO_DIR}


    # 3. copy object file releated files to outout dir

    # 3.1 .S .c file

    find ./build -name "*.o" | while read -r FILE_READ ; do
        FILE_READ1=$(echo ${FILE_READ} | sed "s/\.\/build//g")
        echo ${FILE_READ1} | egrep "/home/|/cygdrive" > /dev/null
        if [ $? -eq 0 ];then
            FULL_PATH=${FILE_READ1}
        else
            FULL_PATH=`realpath ${FILE_READ1#*/}`
        fi

        FILE_OBJ=$(echo ${FULL_PATH} | sed "s/${PATH_FOR_SED}//g")
        cd ${TOP_DIR}
        [ -e ${FILE_OBJ%.*}.c ] && echo ${FILE_OBJ%.*}.c && cp ${FILE_OBJ%.*}.c ../${SIMPLE_PRO_NAME} --parents
        [ -e ${FILE_OBJ%.*}.S ] && echo ${FILE_OBJ%.*}.S && cp ${FILE_OBJ%.*}.S ../${SIMPLE_PRO_NAME} --parents
        cd -
    done

    #3.2 .h file in .d
    find ./build -name "*.o" | while read -r FILE_READ ; do
        [ -f ${FILE_READ%.*}.d ]    &&                      \
        cat ${FILE_READ%.*}.d       |                       \
        grep ":$"                   |                       \
        sed 's/://'                 |                       \
        while read line
        do
            echo ${line} | egrep "/home/|/cygdrive" > /dev/null
            if [ $? -eq 0 ];then
                FULL_PATH=${line}
            else
                FULL_PATH=`realpath ${line}`
            fi

            FILE_OBJ=$(echo ${FULL_PATH} | sed "s/${PATH_FOR_SED}//g")
            cd ${TOP_DIR}
            [ -e ${FILE_OBJ} ] && echo ${FILE_OBJ} && cp ${FILE_OBJ} ../${SIMPLE_PRO_NAME} --parents
            cd -
        done
    done

    # 3.3 other file
    FILE_ISSUE+=" do_freertos.sh Makefile fake_rom.lds log_build log_gdb log_run"
    for file in ${FILE_ISSUE};do
        [ -f ${file}  ] && cp ${file} ${SIMPLE_PRO_DIR}/Demo/${PRO_NAME}
    done
}

Simple_with_log(){
    [ -f log_simple ] && mv log_simple log_simple_bak

    TMP1=`pwd`
    PRO_NAME=${TMP1##*/}
    SIMPLE_PRO_NAME=${PRO_NAME}_simple

    SIMPLE_PRO_DIR=../../../${SIMPLE_PRO_NAME}

    Simple 2>&1 | tee -a  log_simple

    cp log_simple ${SIMPLE_PRO_DIR}/Demo/${PRO_NAME}
}

Kill(){
    killall qemu-system-riscv64
}

##########################################################
##########################################################


Usage(){
    echo Usage :
    cat ${CURRENT_SCRIPT}               \
        | grep "(){"                    \
        | grep -v "^ "                  \
        | egrep -v  "Usage|Main"        \
        | awk -F "(" '{print $1}'       \
        | while read line
    do
        echo -e '\t' ${CURRENT_SCRIPT} ${line}
    done
    exit -1
}

Main(){

    CURRENT_SCRIPT=$0
    OBJ=$1

    if [ $# == 0 ];then
        Usage
    fi

    [ ${OBJ} == help ] && Usage

    cat ${CURRENT_SCRIPT}               \
        | grep "(){"                    \
        | grep -v "^ "                  \
        | egrep -v  "Usage|Main"        \
        | grep -w ${OBJ} > /dev/null
    if [ $? -eq 0 ];then
        shift
        start_time=$(date +%s)
        ${OBJ} $*
        end_time=$(date +%s)
        cost_time=$[ $end_time-$start_time ]
        echo "cost time is $(($cost_time/60))min $(($cost_time%60))s"
    else
        echo ${OBJ} : NOT DEFINED
        Usage
    fi
}

Main $*
