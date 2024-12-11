#include <stdio.h>
#include <stdlib.h>
#include "settings.h"

int main(int argc, char *argv[]){
    int isLv = 0 , isHva = 0, isHvb = 0;
    pAvl tree = NULL;


    if (strcmp("lv", argv[1])){
        isLv = 1;
    }else if (strcmp("hva", argv[1])){
        isHva = 1;
    }else if (strcmp("hvb", argv[1])){
        isHvb = 1;
    }
    tree = handleTreeProcess(tree, isLv, isHva, isHvb);
    
    return 0;
}
