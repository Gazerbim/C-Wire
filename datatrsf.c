#include "settings.h"

void fprintAVL(pAvl node, FILE *file) {
    if (node != NULL){
        fprintAVL(node->leftSon, file);
        fprintf(file,"Station %d, capacity = %ld, load = %ld\n", node->id, node->capacity, node->load);
        fprintAVL(node->rightSon, file);
    }
}

void transferToFile(pAvl tree, int isLv, int isHva, int isHvb) {
    FILE *file;
    file = fopen("data.txt", "w+");
    if (file == NULL) {
        printf("Error opening file\n");
        exit(EXIT_FAILURE);
    }
    if (isLv) {
        fprintf(file, "Station LV:Capacité:Consommation\n");
    }
    if (isHva) {
        fprintf(file, "Station HVA:Capacité:Consommation\n");
    }
    if (isHvb) {
        fprintf(file, "Station HVB:Capacité:Consommation\n");
    }
    fprintAVL(tree, file);
    fclose(file);
}