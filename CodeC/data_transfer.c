#include "settings.h"

//will write the data in the tree in the file in the id order
void fprintAVL(pAvl node, FILE *file) {
    if (node != NULL){
        fprintAVL(node->leftSon, file);
        fprintf(file,"%d:%ld:%ld\n", node->id, node->capacity, node->load);
        fprintAVL(node->rightSon, file);
    }
}

//will write the header and launch the fprintAVL function
void transferToFile(pAvl tree, int isLv, int isHva, int isHvb, char* station, char* consumer, char* powerplant) {
    FILE *file;
    char fileTitle[200]="../tests/";
    strcat(fileTitle, station);
    strcat(fileTitle, "_");
    strcat(fileTitle, consumer);
    if(strcmp("all", powerplant)!=0){ // if we have a specified power plant
        strcat(fileTitle, "_");
        strcat(fileTitle, powerplant);
    }
    strcat(fileTitle, ".csv");
    file = fopen(fileTitle, "w+");
    if (file == NULL) {
        printf("Error opening file\n");
        exit(4);
    }
    if (isLv) {
        fprintf(file, "LV_Station:Capacity:Consumption_(%s)\n", consumer);
    }
    if (isHva) {
        fprintf(file, "HVA_Station:Capacity:Consumption_(%s)\n", consumer);
    }
    if (isHvb) {
        fprintf(file, "HVB_Station:Capacity:Consumption_(%s)\n", consumer);
    }
    fprintAVL(tree, file);
    fclose(file);
}
