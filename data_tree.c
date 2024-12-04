#include "settings.h"

int min(int a, int b) {
    return (a < b) ? a : b;
}

int max3(int a, int b, int c) {
    return (a > b) ? (a > c ? a : c) : (b > c ? b : c);
}

pAvl createNode(){
    pAvl new = malloc(sizeof(Avl));
    if (new==NULL){
        printf("Memory allocation failed");
        exit(1);
    }
    new->leftSon = NULL;
    new->rightSon = NULL;
    new->balance = 0;
    new->capacity = 0;
    return new;
}

pAvl createAVL(int capacity){
    pAvl new = createNode();
    new->capacity = capacity;
    return new;
}

void insert(pAvl tree, int capacity){
    pAvl new = createNode();
    new->capacity = capacity;
    if(tree == NULL){
        tree = new;
    }else if(new->capacity<tree->capacity){

    }
}

// Get the height of a node
int getBalance(pAvl node) {
    if (node == NULL) {
        return 0;
    }
    return node->balance;
}

// Perform a right rotation
pAvl rotateRight(pAvl node) {
    pAvl pivot = node->leftSon;
    int balance_node = node->balance;
    int balance_pivot = pivot->balance;

    node->leftSon = pivot->rightSon;
    pivot->rightSon = node;

    node->balance = balance_node - min(balance_pivot, 0) + 1;
    pivot->balance = max3(balance_node + 2, balance_node + balance_pivot + 2, balance_pivot + 1);

    return pivot;

}

// Perform a left rotation
pAvl rotateLeft(pAvl node) {
    pAvl pivot = node->rightSon;
    int balance_node = node->balance;
    int balance_pivot = pivot->balance;

    node->rightSon = pivot->leftSon;
    pivot->leftSon = node;

    node->balance = balance_node - min(balance_pivot, 0) - 1;
    pivot->balance = max3(balance_node - 2, balance_node + balance_pivot - 2, balance_pivot - 1);

    return pivot;

}

pAvl doubleRotateLeft(pAvl node){
    node->rightSon = rotateRight(node->rightSon);
    return rotateLeft(node);
}

pAvl doubleRotateRight(pAvl node){
    node->leftSon = rotateLeft(node->leftSon);
    return rotateRight(node);
}

pAvl balanceAVL(pAvl node){
    if(node->balance >= 2){
        if(node->rightSon->balance >= 0){
            return rotateLeft(node);
        }else{
            return doubleRotateLeft(node);
        }
    }else if(node->balance <= -2){
        if(node->leftSon->balance <= 0){
            return rotateRight(node);
        }else{
            return doubleRotateRight(node);
        }
    }
    return node;
}

pAvl insertAVL(pAvl node, int capacity, int *h){
    if(node==NULL){
        *h = 1;
        return createAVL(capacity);
    }else if(capacity < node->capacity){
        node->leftSon = insertAVL(node->leftSon, capacity, h);
        *h = -*h;
    }else if(capacity > node->capacity){
        node->rightSon = insertAVL(node->rightSon, capacity, h);
    }else{
        *h = 0;
        return node;
    }

    if(*h != 0){
        node -> balance += *h;
        node = balanceAVL(node);
        if(node->balance == 0){
            *h = 0;
        }else{
            *h = 1;
        }
    }
    return node;
}

void printAVL(pAvl node) {
    if (node != NULL){
        printAVL(node->leftSon);
        printf("%d ", node->capacity);
        printAVL(node->rightSon);
    }
}
