#include "settings.h"

void fprintAVL(pAvl node, FILE *file) {
    if (node != NULL){
        fprintAVL(node->leftSon, file);
        fprintf(file,"%d:%ld:%ld\n", node->id, node->capacity, node->load);
        fprintAVL(node->rightSon, file);
    }
}

void transferToFile(pAvl tree, int isLv, int isHva, int isHvb) {
    FILE *file;
    file = fopen("data.csv", "w+");
    if (file == NULL) {
        printf("Error opening file\n");
        exit(4);
    }
    if (isLv) {
        fprintf(file, "LV Station:Capacity:Consumption\n");
    }
    if (isHva) {
        fprintf(file, "HVA Station:Capacity:Consumption\n");
    }
    if (isHvb) {
        fprintf(file, "HVB Station:Capacity:Consumption\n");
    }
    fprintAVL(tree, file);
    fclose(file);
}
