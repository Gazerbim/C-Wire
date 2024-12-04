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
    int capacity;
}Avl, *pAvl;


int min(int a, int b);
int max3(int a, int b, int c);
pAvl createNode();
pAvl createAVL(int capacity);
void insert(pAvl tree, int capacity);
int getBalance(pAvl node);
pAvl rotateRight(pAvl node);
pAvl rotateLeft(pAvl node);
pAvl doubleRotateLeft(pAvl node);
pAvl doubleRotateRight(pAvl node);
pAvl balanceAVL(pAvl node);
pAvl insertAVL(pAvl node, int capacity, int *h);
void printAVL(pAvl node);

#endif //SETTINGS_H
