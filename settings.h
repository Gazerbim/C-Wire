#ifndef SETTINGS_H
#define SETTINGS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>


typedef struct Avl{
    struct Avl *leftSon;
    struct Avl *rightSon;
    int balance;
    long capacity;
    int id;
    long load;
}Avl, *pAvl;


int min(int a, int b);
int max3(int a, int b, int c);
pAvl createNode();
pAvl createAVL(long capacity, int id);
int getBalance(pAvl node);
pAvl rotateRight(pAvl node);
pAvl rotateLeft(pAvl node);
pAvl doubleRotateLeft(pAvl node);
pAvl doubleRotateRight(pAvl node);
pAvl balanceAVL(pAvl node);
pAvl insertAVL(pAvl node, long capacity, int *h, int id);
int research(pAvl node, int id, pAvl *searched);
void printAVL(pAvl node);
void updateStation(pAvl tree, int id, int load);
pAvl buildAvl(pAvl tree, int isLv, int isHva, int isHvb, char *chvb, char *chva,
                char *clv, char *ccomp, char *cindiv, char *ccapa, char *cload);


#endif //SETTINGS_H