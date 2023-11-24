#!/bin/bash

function build() {
    nasm -f bin ./src/boot.asm -o ./target/boot.bin

    rm ./target/master.img
    bximage -hd=16 -func=create -sectsize=512 -imgmode=flat -q \
      ./target/master.img

    dd if=./target/boot.bin of=./target/master.img bs=512 count=1 conv=notrunc
}

function run() {
    bochs -q -f ./bochsrc.bxrc
}

function dbug() {
    bochsdbg -q -f ./bochsrc_dbg.bxrc
}

