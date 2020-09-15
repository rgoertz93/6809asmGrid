#!/usr/bin/bash

imgtool create coco_jvc_rsdos edtasm.dsk
#cp edtasm_main.dsk edtasm.dsk
lwasm -9bl -p cd -oMAIN.BIN main.asm
#lwasm --decb -o MAIN.BIN main.asm
imgtool put coco_jvc_rsdos edtasm.dsk MAIN.BIN MAIN.BIN

#./prepend.py > code.asm
#imgtool put coco_jvc_rsdos edtasm.dsk CODE.ASM CODE.ASM --ascii=ascii --ftype=assembler

cp edtasm.dsk ../VCC/disks
mv edtasm.dsk ../Mame/disks

rm main.bin
#rm code.asm
