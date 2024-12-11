#include "settings.h"

int min(int a, int b) {
    return (a < b) ? a : b;
}

int max(int a, int b) {
    return (a > b) ? a : b;
}

int max3(int a, int b, int c) {
    return (a > b) ? (a > c ? a : c) : (b > c ? b : c);
}

int min3(int a, int b, int c) {
    return (a < b) ? (a < c ? a : c) : (b < c ? b : c);
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
    new->id = 0;
    new->load = 0;
    return new;
}

pAvl createAVL(long capacity, int id){
    pAvl new = createNode();
    new->capacity = capacity;
    new->id = id;
    return new;
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

    node->balance = balance_node - max(balance_pivot, 0) - 1;
    pivot->balance = min3(balance_node - 2, balance_node + balance_pivot - 2, balance_pivot - 1);

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

pAvl insertAVL(pAvl node, long capacity, int *h, int id){
    if(node==NULL){
        *h = 1;
        return createAVL(capacity, id);
    }else if(id < node->id){
        node->leftSon = insertAVL(node->leftSon, capacity, h, id);
        *h = -*h;
    }else if(id > node->id){
        node->rightSon = insertAVL(node->rightSon, capacity, h, id);
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

int research(pAvl node, int id, pAvl *searched){
    if (node==NULL){
        return 0;
    }
    if (node->id == id){
        *searched = node;
        return 1;
    }
    if (node->id > id){
        return research(node->leftSon, id, searched);
    }
    if (node->id < id){
        return research(node->rightSon, id, searched);
    }
}

void printAVL(pAvl node) {
    if (node != NULL){
        printAVL(node->leftSon);
        printf("Station %d, capacity = %ld, load = %ld\n", node->id, node->capacity, node->load);
        printAVL(node->rightSon);
    }
}
