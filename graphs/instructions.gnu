# graphique.gnu
# Définir une variable pour le fichier de données
datafile = "graphs/hvb_comp.csv"  # Valeur par défaut (à modifier si nécessaire)

# Définir le nom du fichier de sortie
set terminal png size 1600,900 # Définition du format et de la taille
set output "Graphe.png" # Nom par défaut (à modifier pour avoir plusieurs images différentes sinon réécriture)

# Instruction de traçage
set style data histograms
set style fill solid 1.00 border -1 # Remplissage des barres
set boxwidth 0.25 relative # Largeur des barres
set title "Histogramme représentant la puissance par rapport aux stations"
set xlabel "Station HV-B"
set xtics 1,1
set ylabel "Puissance (kWh)"

# Tracer l'histogramme
plot datafile u 1:2 with boxes title "Capacité", "" u 1:3 with boxes title "Consommation"

# Clôturer la commande de sauvegarde
set output
