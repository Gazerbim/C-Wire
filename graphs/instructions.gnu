# graphique.gnu
# Définir une variable pour le fichier de données
datafile = "lv_indiv.csv"  # Valeur par défaut (à modifier se nécessaire)

# Définir le nom du fichier de sortie
set terminal png size 1600,900 # Définition du format et de la taille
set output "Graphe.png" # Nom par défaut (à modifier pour avoir plusieurs images différentes sinon réécriture)

# Instruction de traçage
set title "Histogramme représentant la puissance par rapport aux stations"
set xlabel "Station HV-A"
set ylabel "Puissance (kWh)"

# Tracer l'histogramme
plot datafile u 1:2 with boxes title "Capacité", \
    "" u 1:3 with boxes title "Consommation"

# Clôturer la commande de sauvegarde
set output
