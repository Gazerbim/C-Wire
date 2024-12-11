#!/usr/bin/bash

# Function: Display help
display_help() {
    echo "Usage: $0 <path_to_CSV_file> <station_type> <consumer_type> [central_id] [-h]"
    echo ""
    echo "Parameter descriptions:"
    echo "  <path_to_CSV_file>   Path to the CSV file containing the data (required)."
    echo "  <station_type>       Type of station to process: hvb, hva, lv (required)."
    echo "  <consumer_type>      Type of consumer: comp (business), indiv (individual), all (all) (required)."
    echo "  [central_id]         ID of a specific station (optional)."
    echo "  -h                   Display this help and ignore all other parameters (optional)."
    echo ""
    echo "Restrictions:"
    echo "  The following combinations are forbidden:"
    echo "  - hvb all, hva all, hvb indiv, hva indiv"
    echo ""
    echo "Example usage:"
    echo "  $0 data.csv hvb comp 1"
}

# Verify parameters
verify_parameters() {
    local csv_file="$1"
    local station_type="$2"
    local consumer_type="$3"

    if [[ ! -f "$csv_file" ]]; then #! = negation and -f it's for file 
        echo "Error: File $csv_file does not exist." >&2
        display_help
        exit 1
    fi

    if [[ "$station_type" != "hvb" && "$station_type" != "hva" && "$station_type" != "lv" ]]; then
        echo "Error: Invalid station type. Choose hvb, hva, or lv." >&2
        display_help
        exit 1
    fi

    if [[ "$consumer_type" != "comp" && "$consumer_type" != "indiv" && "$consumer_type" != "all" ]]; then
        echo "Error: Invalid consumer type. Choose comp, indiv, or all." >&2
        display_help
        exit 1
    fi

    # Check the forbidden combinations of station/consumer
    if { [[ "$station_type" == "hvb" || "$station_type" == "hva" ]] && [[ "$consumer_type" == "all" || "$consumer_type" == "indiv" ]]; }; then # {} it's because they are already [[]] in condition 
        echo "Error: The combination $station_type $consumer_type is forbidden." >&2
        display_help
        exit 1
    fi
}

# Check and create tmp directory
check_and_create_tmp() {
    if [[ -d "tmp" ]]; then #-d it's for dossier 
        echo "The tmp directory already exists. Clearing its contents..."
        rm -rf tmp/* #delete all in tmp without tmp 
    else
        echo "Creating the tmp directory..."
        mkdir tmp
    fi
    if [[ -d "graphs" ]]; then #-d it's for dossier 
        echo "The graphs directory already exists."
    else
        echo "Creating the graphs directory..."
        mkdir graphs
    fi
}

	
check_and_compile() {
    local executable="exec"  # Le nom de l'exécutable à vérifier
    local makefile="Makefile"
    local station_type="$1"

    # Vérifier si le Makefile existe
    if [[ ! -f "$makefile" ]]; then
        echo "Error: Makefile not found in the directory." >&2
        exit 1
    fi

    # Vérifier si l'exécutable existe déjà
    if [[ -f "$executable" ]]; then
        echo "The executable '$executable' already exists."
    else
        echo "The executable '$executable' does not exist. Running 'make' to compile..."

        # Vérifier si le Makefile contient une règle pour 'exec'
        if ! grep -q "exec" "$makefile"; then
            echo "Error: No target for 'exec' found in the Makefile." >&2
            exit 1
        fi

        # Lancer 'make' pour compiler l'exécutable
        make
        if [[ $? -ne 0 ]]; then
            echo "Error: Compilation failed using 'make'." >&2
            exit 1
        fi
        echo "Compilation successful. Executable '$executable' created."
    fi

    # Vérifier si l'exécutable existe après compilation
    if [[ ! -f "$executable" ]]; then
        echo "Error: The executable '$executable' was not created." >&2
        exit 1
    fi
    
    echo "Executing '$executable'..."
    ./$executable "$station_type"

}


filter_and_copy_data() {
    local input_file="$1"
    local station_type="$2"
    local consumer_type="$3"
    local central_id="$4"
    local output_file="tmp/filtered_data.dat"

    echo "Filtering data based on station type, consumer type, and central ID..."

    local station_index consumer_index
    case "$station_type" in
        hvb) station_index=2 ;;  # Column index for HVB
        hva) station_index=3 ;;  # Column index for HVA
        lv) station_index=4 ;;   # Column index for LV
    esac

    case "$consumer_type" in
        comp) consumer_index=5 ;;  # Column index for companies
        indiv) consumer_index=6 ;; # Column index for individuals
        all) consumer_index="all" ;; # Match all consumers
    esac
	
  
    
    if [[ "$consumer_index" == 5 ]]; then
	local no_consumer=6
    else
	local no_consumer=5
    fi
 
    # Total number of lines for progress calculation
    total_lines=$(wc -l < "$input_file")
    processed_lines=0

    # Use AWK for filtering with progress
    awk -F';' -v station_idx="$station_index" -v consumer_idx="$consumer_index" -v central_id="$central_id" -v total_lines="$total_lines" -v no_consumer_idx="$no_consumer" '
    BEGIN {
        OFS = ";"

        
    }
     NR == 1 { 
        next 
    }
    {
        station_value = $station_idx;
        consumer_value = consumer_idx == "all" ? "valid" : $consumer_idx;
	no_consumer_value = $no_consumer_idx;

        # Check station match
        if ((station_value != "-" && no_consumer_value =="-") || (station_value != "-" && consumer_value != "-")) {
            # Check central_id match if provided
            if (central_id == "all" || central_id == $1) {
                print >> "tmp/filtered_data.dat";
            }
        }

        # Update progress bar
        if (NR % 100000 == 0) {  # Update every 100 lines
            printf "\rProgress: %.1f%%", (NR / total_lines) * 100 > "/dev/stderr";
        }
    }
    END {
        print "\rProgress: 100%   " > "/dev/stderr";
    }' "$input_file"

    echo "Filtered data has been saved to $output_file"
    nb_lignes=$(wc -l < "$output_file")
    if [[ "$nb_lignes" == 1 ]]; then 
        echo "There is no station $station_type $consumer_type"
        exit 1
    fi
}

measure_time() {
    local func="$1"          # Nom de la fonction
    shift                    # Retire le nom de la fonction des arguments
    local start_time=$(date +%s.%N)  # Temps de départ (secondes.nanosecondes)
    
    # Appel de la fonction avec les arguments restants
    "$func" "$@"
    local func_exit_code=$?

    local end_time=$(date +%s.%N)  # Temps de fin
    local elapsed_time=$(awk "BEGIN {print $end_time - $start_time}")  # Calcul avec awk

    printf "Execution time for %s: %.3f sec\n" "$func" "$elapsed_time"

    return $func_exit_code
}

#part_C() { }




# Main function
main() {
    TIMEFORMAT=%R
    if [[ "$*" == *"-h"* ]]; then
        display_help
        exit 0
    fi

    if [[ $# -lt 3 ]]; then
        echo "Error: Missing parameters." >&2
        display_help
        exit 1
    fi

    local csv_file="$1"
    local station_type="$2"
    local consumer_type="$3"
    local central_id="${4:-all}"  # Default to "all" if not provided

    verify_parameters "$csv_file" "$station_type" "$consumer_type"
    check_and_create_tmp

    

    # Display the parameters
    echo "CSV file: $csv_file"
    echo "Station type: $station_type"
    echo "Consumer type: $consumer_type"
    echo "Central ID: $central_id"
    
    measure_time filter_and_copy_data "$csv_file" "$station_type" "$consumer_type" "$central_id"
    
    
    
    echo "Processing completed successfully."
    check_and_compile "$station_type"
    
}

main "$@"
