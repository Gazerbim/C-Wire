all: exec

exec: main.o data_tree.o process.o datatrsf.o
	gcc main.o data_tree.o process.o -o exec

main.o: main.c settings.h
	gcc -c main.c -o main.o

data_tree.o: data_tree.c settings.h
	gcc -c data_tree.c -o data_tree.o

process.o: process.c settings.h
	gcc -c process.c -o process.o

datatrsf.o: data_transfer.c settings.h
	gcc -c datatrsf.c -o datatrsf.o

clean:
	rm -f *.o
	rm -f exec