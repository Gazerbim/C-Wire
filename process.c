#include "settings.h"

pAvl updateStation(pAvl tree, int id, long load) {
    pAvl station;
    int h = 0;
    int result = research(tree, id, &station);
    if (!result) {
        tree = insertAVL(tree, 0, &h, id);
    } else {
        station->load += load;
    }

    return tree;
}



pAvl buildAvl(pAvl tree, int isLv, int isHva, int isHvb, char *chvb, char *chva, char *clv, char *ccomp, char *cindiv, char *ccapa, char *cload) {
    int h = 0;
    if (isLv) {
        if (strcmp("-", chva)) { // This is an lv station
            tree = insertAVL(tree, atol(ccapa), &h, atoi(clv));
        }else {
            tree = updateStation(tree, atoi(clv), atol(cload));
        }
    } else if (isHva) {
        if (strcmp("-", ccomp) != 0 || strcmp("-", cindiv) != 0) { // This is a consumer
            tree = updateStation(tree, atoi(chva), atol(cload));
        }else if (strcmp("-", clv) != 0) { // This is an lv station
            tree = updateStation(tree, atoi(chva), atol(ccapa));
        }else {
            tree = insertAVL(tree, atol(ccapa), &h, atoi(chva));
        }
    } else if (isHvb) {
        if (strcmp("-", ccomp) != 0 || strcmp("-", cindiv) != 0) { // This is a consumer
            tree = updateStation(tree, atoi(chvb), atol(cload));
        }else if (!strcmp("-", chva)) { // This is an hva station
            tree = updateStation(tree, atoi(chvb), atol(ccapa));
        }else {
            tree = insertAVL(tree, atol(ccapa), &h, atoi(chvb));
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
