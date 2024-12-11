#include <stdio.h>
#include <stdlib.h>
#include <setting.h>

int main() {
    FILE *file;
    char line[256];
    char *filename = "C-Wire_shell/tmp/filtered_data.dat";
    char *cpp, *chvb, *chva, *clv, *ccomp, *cindiv, *ccapa, *cload;
    int pp, hvb, hva, lv, comp, indiv, capa, load; 
    int isLv = 0 , isHva = 0, isHvb = 0;
    pAvl tree = NULL;

    // Open the file
    file = fopen(filename, "r");
    if (file == NULL) {
        printf("Error while opening file");
        exit(2);
    }

    fgets(line, sizeof(line), file);
    line[strcspn(line, "\n")] = '\0';
    cpp = strtok(line, ";");
    chvb = strtok(NULL, ";");
    chva = strtok(NULL, ";");
    clv = strtok(NULL, ";");
    
    if (strcmp("-", clv)){
        isLv = 1;
    }else if (strcmp("-", chva)){
        isHva = 1;
    }else if (strcmp("-", chvb)){
        isHvb = 1;
    }

    rewind(file);
    // read each line
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
        
        tree = buildAvl(tree, isLv, isHva, isHvb, chvb, chva, clv, ccomp, cindiv, ccapa, cload);
    }
    printAVL(tree);
    // close the file
    fclose(file);
    return 0;
}
