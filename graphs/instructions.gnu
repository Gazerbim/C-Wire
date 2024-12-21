# Gnuplot script to plot a histogram with data differentiated by color
# Skip the first two header lines

# Define the input file
datafile = "input.csv"  # Name of the file containing the data

# Define the output file
set terminal pngcairo size 1600,900 enhanced font 'Verdana,10'
set output "graphique.png"

# Style and axes parameters
set style data histogram
set style histogram clustered gap 1
set style fill solid border -1
set boxwidth 0.8
set title "Histogram: Capacity vs Consumption" font "Verdana,14"
set xlabel "Stations" font "Verdana,12"
set ylabel "Values (units)" font "Verdana,12"

# Define the colors
set style line 1 lc rgb '#00ff00' lt 1 lw 2  # Green for margin (positive)
set style line 2 lc rgb '#ff0000' lt 1 lw 2  # Red for excess (negative)

# Add a grid
set grid ytics

# Read the data
set key outside
set datafile separator " "  # Define the separator (space)

# Skip the first two lines
skip_lines = 2

# Plot margins and excesses with different orientations (up or down)
# Margins go up (positive) and excesses go down (negative)
plot datafile every ::skip_lines using 0:(($2 > $3) ? $2 - $3 : 0) with boxes ls 1 title "Margin (Capacity > Consumption)", \
     '' every ::skip_lines using 0:(($3 > $2) ? $2 - $3 : 0) with boxes ls 2 title "Excess (Consumption > Capacity)"
