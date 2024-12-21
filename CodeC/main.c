#include "settings.h"

int main(int argc, char *argv[]){ // receives the arguments from the shell
    int isLv = 0 , isHva = 0, isHvb = 0;
    pAvl tree = NULL;


    if (strcmp("lv", argv[1])==0){ // search if the asked station is a lv, a hva or a hvb
        isLv = 1;
    }else if (strcmp("hva", argv[1])==0){
        isHva = 1;
    }else if (strcmp("hvb", argv[1])==0){
        isHvb = 1;
    }
    tree = handleTreeProcess(tree, isLv, isHva, isHvb); // create and fill the tree
    transferToFile(tree, isLv, isHva, isHvb, argv[1], argv[2], argv[3]); // write the tree's data
    freeTree(tree); // free the tree
    return 0; // returns 0 if all was succesfully executed
}
