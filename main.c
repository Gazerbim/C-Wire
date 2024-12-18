#include "settings.h"

int main(int argc, char *argv[]){
    int isLv = 0 , isHva = 0, isHvb = 0;
    pAvl tree = NULL;


    if (strcmp("lv", argv[1])==0){
        isLv = 1;
    }else if (strcmp("hva", argv[1])==0){
        isHva = 1;
    }else if (strcmp("hvb", argv[1])==0){
        isHvb = 1;
    }
    tree = handleTreeProcess(tree, isLv, isHva, isHvb);
    transferToFile(tree, isLv, isHva, isHvb);
    freeTree(tree);
    return 0;
}
