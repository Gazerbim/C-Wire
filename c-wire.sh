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

# Function: Verify parameters passed to the script
verify_parameters() {
    local csv_file="$1"
    local station_type="$2"
    local consumer_type="$3"

    # Check if the CSV file exists
    if [[ ! -f "$csv_file" ]]; then
        echo "Error: File $csv_file does not exist." >&2
        display_help
        exit 1
    fi

    # Validate station type
    if [[ "$station_type" != "hvb" && "$station_type" != "hva" && "$station_type" != "lv" ]]; then
        echo "Error: Invalid station type. Choose hvb, hva, or lv." >&2
        display_help
        exit 1
    fi

    # Validate consumer type
    if [[ "$consumer_type" != "comp" && "$consumer_type" != "indiv" && "$consumer_type" != "all" ]]; then
        echo "Error: Invalid consumer type. Choose comp, indiv, or all." >&2
        display_help
        exit 1
    fi

    # Check forbidden combinations of station/consumer
    if { [[ "$station_type" == "hvb" || "$station_type" == "hva" ]] && [[ "$consumer_type" == "all" || "$consumer_type" == "indiv" ]]; }; then
        echo "Error: The combination $station_type $consumer_type is forbidden." >&2
        display_help
        exit 1
    fi
}

# Function: Check and create necessary directories
check_and_create_tmp() {
    # Ensure "tmp" directory exists and is empty
    if [[ -d "tmp" ]]; then
        echo "The tmp directory already exists. Clearing its contents..."
        rm -rf tmp/* # Delete all contents of "tmp" without deleting the directory
    else
        echo "Creating the tmp directory..."
        mkdir tmp
    fi

    # Ensure "graphs" directory exists
    if [[ -d "graphs" ]]; then
        echo "The graphs directory already exists."
    else
        echo "Creating the graphs directory..."
        mkdir graphs
    fi

    # Ensure "tests" directory exists
    if [[ -d "tests" ]]; then
        echo "The tests directory already exists."
    else
        echo "Creating the tests directory..."
        mkdir tests
    fi
}

# Function: Measure execution time of a given function
measure_time() {
    local func="$1"          # Function name
    shift                    # Remove function name from arguments
    local start_time=$(date +%s.%N)  # Start time (seconds.nanoseconds)

    # Call the function with the remaining arguments
    "$func" "$@"
    local func_exit_code=$?

    local end_time=$(date +%s.%N)  # End time
    local elapsed_time=$(awk "BEGIN {print $end_time - $start_time}")  # Calculate using awk

    printf "Execution time for %s: %.3f sec\n" "$func" "$elapsed_time"

    return $func_exit_code
}

# Function: Check for Makefile and compile the executable
check_and_compile() {
    cd CodeC/
    local executable="exec"  # The name of the executable to check
    local makefile="Makefile"
    local station_type="$1"
    local consumer_type="$2"
    local central_id="$3"

    # Verify if the Makefile exists
    if [[ ! -f "$makefile" ]]; then
        echo "Error: Makefile not found in the directory." >&2
        exit 1
    fi

    # Run 'make' to compile the executable
    echo "Running 'make' to compile..."
    make
    if [[ $? -ne 0 ]]; then
        echo "Error: Compilation failed using 'make'." >&2
        exit 1
    fi

    echo "Compilation successful. Executable '$executable' created."

    # Verify if the executable exists after compilation
    if [[ ! -f "$executable" ]]; then
        echo "Error: The executable '$executable' was not created." >&2
        exit 1
    fi

    # Execute the compiled executable
    echo "Executing '$executable'..."
    measure_time ./$executable "$station_type" "$consumer_type" "$central_id"
    cd ..
}

# Function: Filter and copy data from the CSV file
filter_and_copy_data() {
    local input_file="$1"
    local station_type="$2"
    local consumer_type="$3"
    local central_id="$4"
    local output_file="tmp/filtered_data.dat"

    echo "Filtering data based on station type, consumer type, and central ID..."

    # Determine column indices based on station type
    local station_index consumer_index no_station
    case "$station_type" in
        hvb) station_index=2 ; no_station=3 ;;  # Column index for HVB
        hva) station_index=3 ; no_station=4 ;;  # Column index for HVA
        lv) station_index=4 ; no_station=2 ;;   # Column index for LV
    esac

    # Determine column indices based on consumer type
    case "$consumer_type" in
        comp) consumer_index=5 ; no_consumer=6 ;;  # Column index for companies
        indiv) consumer_index=6 ; no_consumer=5 ;; # Column index for individuals
        all) consumer_index="all" ; no_consumer="none" ;; # Match all consumers
    esac

    # Total number of lines for progress calculation
    total_lines=$(wc -l < "$input_file")
    processed_lines=0

    # Use AWK for filtering with progress
    awk -F';' -v station_idx="$station_index" -v consumer_idx="$consumer_index" -v central_id="$central_id" -v total_lines="$total_lines" -v no_consumer_idx="$no_consumer" -v no_station_idx="$no_station" '
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
	
        if ((station_value != "-" && no_consumer_value == "-" && $no_station_idx == "-") || (station_value != "-" && consumer_value != "-")) {
            # Check central_id match if provided
            if (central_id == "all" || central_id == $1) {
                # Print from station_index to the end of the line
                print  >> "tmp/filtered_data.dat";
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

sort_file() {
    # Change directory to 'tests'
    cd tests/
    
    # Store the input file name in a local variable
    local input_file="$1"
    
    # Check if the input file exists and contains data
    if [[ ! -f "$input_file" ]]; then
        echo "Error: $input_file not found. Ensure the filtering step is completed." >&2
        exit 1
    fi

    if [[ ! -s "$input_file" ]]; then
        echo "Error: $input_file is empty. Check the filtering process." >&2
        exit 1
    fi

    # Determine the name of the temporary file for sorting
    local temp_sorted_file="${input_file%.csv}_sorted.csv"

    echo "Sorting data by numeric capacity in ascending order from $input_file..."

    # Process the header and sort the data
    {
        # Extract the header (first line of the file)
        head -n 1 "$input_file"

        # Sort the rest of the lines (data only) based on the second column (capacity) numerically
        tail -n +2 "$input_file" | sort -t ':' -k2,2n
    } > "$temp_sorted_file"

    # Check if the sorting operation succeeded
    if [[ ! -s "$temp_sorted_file" ]]; then
        echo "Error: Sorting failed. $temp_sorted_file is empty." >&2
        exit 1
    fi

    # Replace the original file content with the sorted data
    mv "$temp_sorted_file" "$input_file"

    echo "File tests/$input_file successfully updated with sorted data."
    cd ..
}

# Function: Copy and transform CSV to remove ':' and save it as a new file in 'graphs'
copy_and_transform_csv() {
    # Define input and output file paths
    local input_file="tests/$1"
    local output_file="graphs/$1"
    
    # Check if the input file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' does not exist." >&2
        exit 1
    fi

    # Transform and copy the file, replacing ':' with spaces and saving to the output path
    echo "Removing ':' and saving as CSV to '$output_file'..."
    sed 's/:/ /g' "$input_file" > "$output_file"

    # Check if the transformation succeeded
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to transform and copy '$input_file'." >&2
        exit 1
    fi

    # Verify the output file is not empty
    if [[ ! -s "$output_file" ]]; then
        echo "Error: The output file '$output_file' is empty. Something went wrong." >&2
        exit 1
    fi

    echo "File has been successfully transformed and saved to '$output_file'."
}

sort_file_minmax() {
    # Define input and output file paths
    local input_file="tests/$1"
    local output_file="tests/${1%.csv}_minmax.csv"

    # Check if the input file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' not found." >&2
        exit 1
    fi

    # Check if the input file contains data
    if [[ ! -s "$input_file" ]]; then
        echo "Error: Input file '$input_file' is empty." >&2
        exit 1
    fi

    echo "Creating a file with the 10 best and 10 worst stations based on capacity-consumption difference..."

    {
  	echo "Min and Max 'capacity-load' extreme nodes" > "$output_file"
        # Preserve the header from the input file
        head -n 1 "$input_file" >> "$output_file"

        # Compute the difference between capacity and consumption, sort by ascending difference,
        # and extract the 10 worst stations (remove the difference column for output)
        tail -n +3 "$input_file" | awk -F':' '{
            diff = $2 - $3; # Compute the difference: Capacity - Consumption
            print diff, $0; # Add the difference column for sorting
        }' | sort -n | awk '{sub($1 FS, ""); print}' | head -n 10 >> "$output_file"

        # Compute the difference again, sort by descending difference,
        # and extract the 10 best stations (remove the difference column for output)
        tail -n +3 "$input_file" | awk -F':' '{
            diff = $2 - $3; # Compute the difference: Capacity - Consumption
            print diff, $0; # Add the difference column for sorting
        }' | sort -nr | awk '{sub($1 FS, ""); print}' | head -n 10 >> "$output_file"
    }

    # Check if the output file was created successfully and contains data
    if [[ ! -f "$output_file" || ! -s "$output_file" ]]; then
        echo "Error: Failed to create output file '$output_file'." >&2
        exit 1
    fi

    echo "File with top 10 best and worst stations saved to '$output_file'."
}




    

# Main function: Orchestrates the script's operations
main() {
    # Set a time format to measure execution time of specific steps
    TIMEFORMAT=%R

    # Check if the help flag is included in the arguments, display help, and exit
    if [[ "$*" == *"-h"* ]]; then
        display_help
        exit 0
    fi

    # Ensure the script has at least three parameters
    if [[ $# -lt 3 ]]; then
        echo "Error: Missing parameters." >&2
        display_help
        exit 1
    fi

    # Define variables for script parameters
    local csv_file="inputs/$1"          # Input CSV file path
    local station_type="$2"            # Station type (e.g., "hv", "lv")
    local consumer_type="$3"           # Consumer type (e.g., "all", "household")
    local central_id="${4:-all}"       # Central ID, defaulting to "all" if not specified

    # Verify the validity of provided parameters
    verify_parameters "$csv_file" "$station_type" "$consumer_type"

    # Ensure the temporary directory exists
    check_and_create_tmp

    echo " "
    # Display the input parameters for clarity
    echo "CSV file: $csv_file"
    echo "Station type: $station_type"
    echo "Consumer type: $consumer_type"
    echo "Central ID: $central_id"
    echo " "
    # Measure the time taken to filter and copy data
    measure_time filter_and_copy_data "$csv_file" "$station_type" "$consumer_type" "$central_id"
    echo "Processing completed successfully."
    echo " "

    # Perform additional checks and compilation if necessary
    check_and_compile "$station_type" "$consumer_type" "$central_id"
    echo " "
	
    # Determine the name of the source file to process
    local input_file
    if [[ "$central_id" == "all" ]]; then
        # If all central IDs are included
        input_file="${station_type}_${consumer_type}.csv"
    else
        # If a specific central ID is specified
        input_file="${station_type}_${consumer_type}_${central_id}.csv"
    fi

    # Measure the time taken to sort the source file
    measure_time sort_file "$input_file"
    echo " "
    
    # If the station type is "lv" and consumer type is "all", process min/max sorting and transformation
    if [[ "$station_type" == "lv" && "$consumer_type" == "all" ]]; then
        measure_time sort_file_minmax "$input_file"
        # Copy and transform the minmax sorted file
        copy_and_transform_csv "lv_all_minmax.csv"
        echo " "
    fi

    # Copy and transform the main input file
    copy_and_transform_csv "$input_file"
    echo " "

    # Navigate to the CodeC directory, clean up previous builds, and return to the original directory
    cd CodeC/
    make clean
    cd ..
}

# Invoke the main function with all passed arguments
main "$@"

