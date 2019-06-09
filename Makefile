all: build
	
build: clean  forth.asm
	nasm -felf64 -g forth.asm -o forth.o
	ld -o forth forth.o
	chmod +x forth
	echo "#!/bin/sh\n cat pt3.frt - | ./forth" > start
	chmod +x start

clean: 
	rm -rf forth.o forth start

