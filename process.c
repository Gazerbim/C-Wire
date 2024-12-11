#include "settings.h"

void updateStation(pAvl tree, int id, long load){
    pAvl station;
    int result;
    result = research(tree, id, &station);
    
    if(!result){
        printf("Station not found\n");
        exit(3);
    }
    else{
        station->load += load;
    }
    
}


pAvl buildAvl(pAvl tree, int isLv, int isHva, int isHvb, char *chvb, char *chva, char *clv, char *ccomp, char *cindiv, char *ccapa, char *cload){
    int h;
    if(isLv){
        if (strcmp("-", ccomp) || strcmp("-", cindiv)){ // this is a consumer
            updateStation(tree, atoi(clv), atol(cload));
        }
    }else if(isHva){
        if (strcmp("-", ccomp) || strcmp("-", cindiv)){ // this is a consumer
            updateStation(tree, atoi(chva), atol(cload));
        }
        else if(strcmp("-", clv)){ // this is a lv station
            updateStation(tree, atoi(chva), atol(ccapa));
        }
    }else if(isHvb){
        if (strcmp("-", ccomp) || strcmp("-", cindiv)){ // this is a consumer
            updateStation(tree, atoi(chvb), atol(cload));
        }
        else if(strcmp("-", clv) || strcmp("-", chva)){ // this is a lv or hva
            updateStation(tree, atoi(chvb), atol(ccapa));
        }
    }
    return tree;
}

pAvl buildStations(pAvl tree, int isLv, int isHva, int isHvb, char *chvb, char *chva, char *clv, char *ccomp, char *cindiv, char *ccapa, char *cload){
    int h;
    if(isLv){
        if (!strcmp("-", ccomp) && !strcmp("-", cindiv)){ // this is a lv station
            tree = insertAVL(tree, atol(ccapa), &h, atol(clv));
        }
    }else if(isHva){
        if(strcmp("-", chva)){ // this is a hva station
            tree = insertAVL(tree, atol(ccapa), &h, atol(chva));
        }
    }else if(isHvb){
        if(strcmp("-", chvb)){ // this is a hvb station
            tree = insertAVL(tree, atol(ccapa), &h, atol(chvb));
        }
    }
    return tree;
}


pAvl readDataAndBuildAVL(pAvl tree, FILE * file,int isLv, int isHva, int isHvb){
    char *cpp, *chvb, *chva, *clv, *ccomp, *cindiv, *ccapa, *cload;
    //int pp, hvb, hva, lv, comp, indiv, capa, load; 
    char line[256];
    rewind(file);
    int i=0;
    // read each line the first time to build the stations
    while (fgets(line, sizeof(line), file)) {
        // delete line jump
        line[strcspn(line, "\n")] = '\0';

        // cut each string with ';'
        cpp = strtok(line, ";");
        chvb = strtok(NULL, ";");
        chva = strtok(NULL, ";");
        clv = strtok(NULL, ";");
        ccomp = strtok(NULL, ";");
        cindiv = strtok(NULL, ";");
        ccapa = strtok(NULL, ";");
        cload = strtok(NULL, ";");
        //printf("%s %s %s %s %s %s %s %s\n", cpp, chvb, chva, clv, ccomp, cindiv, ccapa, cload);
        
        tree = buildStations(tree, isLv, isHva, isHvb, chvb, chva, clv, ccomp, cindiv, ccapa, cload);
    }
    rewind(file);
    // read each line the second time to sum the consuptions
    while (fgets(line, sizeof(line), file)) {
        i++;
        //printf("%d\n", i);
        // delete line jump
        line[strcspn(line, "\n")] = '\0';

        // cut each string with ';'
        cpp = strtok(line, ";");
        chvb = strtok(NULL, ";");
        chva = strtok(NULL, ";");
        clv = strtok(NULL, ";");
        ccomp = strtok(NULL, ";");
        cindiv = strtok(NULL, ";");
        ccapa = strtok(NULL, ";");
        cload = strtok(NULL, ";");
        //printf("%s %s %s %s %s %s %s %s\n", cpp, chvb, chva, clv, ccomp, cindiv, ccapa, cload);
        
        tree = buildAvl(tree, isLv, isHva, isHvb, chvb, chva, clv, ccomp, cindiv, ccapa, cload);
    }
    return tree;
}

pAvl handleTreeProcess(pAvl tree, int isLv, int isHva, int isHvb){
    FILE *file;
    char *filename = "tmp/filtered_data.dat";

     // Open the file
    file = fopen(filename, "r");
    if (file == NULL) {
        printf("Error while opening file");
        exit(2);
    }
    tree = readDataAndBuildAVL(tree, file, isLv, isHva, isHvb);
    fclose(file);
    return tree;
}
