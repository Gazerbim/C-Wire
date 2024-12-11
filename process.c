#include "settings.h"

//======================================= PROCESS WHILE MAKEFILE NOT MADE ===================================


void updateStation(pAvl tree, int id, int load){
    pAvl station;
    int result = research(tree, id, &station);
    
    if(!result){
                printf("Station not found\n");
                exit(3);
    }
    station->load += load;
}


pAvl buildAvl(pAvl tree, int isLv, int isHva, int isHvb, char *chvb, char *chva, char *clv, char *ccomp, char *cindiv, char *ccapa, char *cload){
    int h;
    if(isLv){

        if (strcmp("-", ccomp) || strcmp("-", cindiv)){ // this is a consumer
            updateStation(tree, atoi(clv), atol(cload));
        }else{ // this is a lv station
            tree = insertAVL(tree, atol(ccapa), &h, atol(clv));
        }
    }else if(isHva){
        if (strcmp("-", ccomp) || strcmp("-", cindiv)){ // this is a consumer
            updateStation(tree, atoi(chva), atol(cload));
        }
        else if(strcmp("-", clv)){ // this is a lv station
            updateStation(tree, atoi(chva), atol(ccapa));
        }
        else{ // this is a hva station
            tree = insertAVL(tree, atol(ccapa), &h, atol(chva));
        }
    }else if(isHvb){
        if (strcmp("-", ccomp) || strcmp("-", cindiv)){ // this is a consumer
            updateStation(tree, atoi(chvb), atol(cload));
        }
        else if(strcmp("-", clv) || strcmp("-", chva)){ // this is a lv or hva
            updateStation(tree, atoi(chvb), atol(ccapa));
        }else{ // this is a hvb station
            tree = insertAVL(tree, atol(ccapa), &h, atol(chvb));
        }
    }
    return tree;
}
