#!/usr/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

# Function: Display help
display_help() {
    echo -e "${CYAN}Usage:${RESET} $0 <path_to_CSV_file> <station_type> <consumer_type> [central_id] [-h]"
    echo ""
    echo -e "${YELLOW}Parameter descriptions:${RESET}"
    echo -e "  ${BLUE}<path_to_CSV_file>${RESET}   Path to the CSV file containing the data (required)."
    echo -e "  ${BLUE}<station_type>${RESET}       Type of station to process: hvb, hva, lv (required)."
    echo -e "  ${BLUE}<consumer_type>${RESET}      Type of consumer: comp (business), indiv (individual), all (all) (required)."
    echo -e "  ${BLUE}[central_id]${RESET}         ID of a specific station (optional)."
    echo -e "  ${BLUE}-h${RESET}                   Display this help and ignore all other parameters (optional)."
    echo ""
    echo -e "${YELLOW}Restrictions:${RESET}"
    echo "  The following combinations are forbidden:"
    echo -e "  - ${RED}hvb all${RESET}, ${RED}hva all${RESET}, ${RED}hvb indiv${RESET}, ${RED}hva indiv${RESET}"
    echo ""
    echo -e "${YELLOW}Example usage:${RESET}"
    echo "  $0 data.csv hvb comp 1"
}

# Function: Verify parameters passed to the script
verify_parameters() {
    local csv_file="$1"
    local station_type="$2"
    local consumer_type="$3"

    # Check if the CSV file exists
    if [[ ! -f "$csv_file" ]]; then
        echo -e "${RED}Error:${RESET} File $csv_file does not exist." >&2
        display_help
        exit 1
    fi

    # Validate station type
    if [[ "$station_type" != "hvb" && "$station_type" != "hva" && "$station_type" != "lv" ]]; then
        echo -e "${RED}Error:${RESET} Invalid station type. Choose ${BLUE}hvb${RESET}, ${BLUE}hva${RESET}, or ${BLUE}lv${RESET}." >&2
        display_help
        exit 1
    fi

    # Validate consumer type
    if [[ "$consumer_type" != "comp" && "$consumer_type" != "indiv" && "$consumer_type" != "all" ]]; then
        echo -e "${RED}Error:${RESET} Invalid consumer type. Choose ${BLUE}comp${RESET}, ${BLUE}indiv${RESET}, or ${BLUE}all${RESET}." >&2
        display_help
        exit 1
    fi

    # Check forbidden combinations of station/consumer
    if { [[ "$station_type" == "hvb" || "$station_type" == "hva" ]] && [[ "$consumer_type" == "all" || "$consumer_type" == "indiv" ]]; }; then
        echo -e "${RED}Error:${RESET} The combination ${BLUE}$station_type${RESET} ${BLUE}$consumer_type${RESET} is forbidden." >&2
        display_help
        exit 1
    fi
}

# Function: Check and create necessary directories
check_and_create_tmp() {
    # Ensure "tmp" directory exists and is empty
    if [[ -d "tmp" ]]; then
        echo -e "${YELLOW}The tmp directory already exists.${RESET} ${CYAN}Clearing its contents...${RESET}"
        rm -rf tmp/* # Delete all contents of "tmp" without deleting the directory
    else
        echo -e "${GREEN}Creating the tmp directory...${RESET}"
        mkdir tmp
    fi

    # Ensure "graphs" directory exists
    if [[ -d "graphs" ]]; then
        echo -e "${YELLOW}The graphs directory already exists.${RESET}"
    else
        echo -e "${GREEN}Creating the graphs directory...${RESET}"
        mkdir graphs
    fi

    # Ensure "tests" directory exists
    if [[ -d "tests" ]]; then
        echo -e "${YELLOW}The tests directory already exists.${RESET}"
    else
        echo -e "${GREEN}Creating the tests directory...${RESET}"
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

    printf "${CYAN}Execution time for ${BLUE}%s${RESET}: %.3f sec\n" "$func" "$elapsed_time"

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
        echo -e "${RED}Error:${RESET} Makefile not found in the directory." >&2
        exit 1
    fi

    # Run 'make' to compile the executable
    echo -e "${CYAN}Running 'make' to compile...${RESET}"
    make
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${RESET} Compilation failed using 'make'." >&2
        exit 1
    fi

    echo -e "${GREEN}Compilation successful.${RESET} Executable '${BLUE}$executable${RESET}' created."

    # Verify if the executable exists after compilation
    if [[ ! -f "$executable" ]]; then
        echo -e "${RED}Error:${RESET} The executable '${BLUE}$executable${RESET}' was not created." >&2
        exit 1
    fi

    # Execute the compiled executable
    echo -e "${CYAN}Executing '${BLUE}$executable${RESET}'...${RESET}"
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

    echo -e "${CYAN}Filtering data based on station type, consumer type, and central ID...${RESET}"

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

    echo -e "${GREEN}Filtered data has been saved to $output_file${RESET}"
    nb_lignes=$(wc -l < "$output_file")
    if [[ "$nb_lignes" == 1 ]]; then 
        echo -e "${RED}There is no station $station_type $consumer_type${RESET}"
        exit 1
    fi
}


# Function: Sort file based on capacity
sort_file() {
    # Change directory to 'tests'
    cd tests/
    
    # Store the input file name in a local variable
    local input_file="$1"
    
    # Check if the input file exists and contains data
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}Error: $input_file not found. Ensure the filtering step is completed.${RESET}" >&2
        exit 1
    fi

    if [[ ! -s "$input_file" ]]; then
        echo -e "${RED}Error: $input_file is empty. Check the filtering process.${RESET}" >&2
        exit 1
    fi

    # Determine the name of the temporary file for sorting
    local temp_sorted_file="${input_file%.csv}_sorted.csv"

    echo -e "${CYAN}Sorting data by numeric capacity in ascending order from $input_file...${RESET}"

    # Process the header and sort the data
    {
        # Extract the header (first line of the file)
        head -n 1 "$input_file"

        # Sort the rest of the lines (data only) based on the second column (capacity) numerically
        tail -n +2 "$input_file" | sort -t ':' -k2,2n
    } > "$temp_sorted_file"

    # Check if the sorting operation succeeded
    if [[ ! -s "$temp_sorted_file" ]]; then
        echo -e "${RED}Error: Sorting failed. $temp_sorted_file is empty.${RESET}" >&2
        exit 1
    fi

    # Replace the original file content with the sorted data
    mv "$temp_sorted_file" "$input_file"

    echo -e "${GREEN}File tests/$input_file successfully updated with sorted data.${RESET}"
    cd ..
}

# Function: Copy and transform CSV to remove ':' and save it as a new file in 'graphs'
copy_and_transform_csv() {
    # Define input and output file paths
    local input_file="tests/$1"
    local output_file="graphs/$1"
    
    # Check if the input file exists
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}Error: Input file '$input_file' does not exist.${RESET}" >&2
        exit 1
    fi

    # Transform and copy the file, replacing ':' with spaces and saving to the output path
    echo -e "${CYAN}Removing ':' and saving as CSV to '$output_file'...${RESET}"
    sed 's/:/ /g' "$input_file" > "$output_file"

    # Check if the transformation succeeded
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to transform and copy '$input_file'.${RESET}" >&2
        exit 1
    fi

    # Verify the output file is not empty
    if [[ ! -s "$output_file" ]]; then
        echo -e "${RED}Error: The output file '$output_file' is empty. Something went wrong.${RESET}" >&2
        exit 1
    fi

    echo -e "${GREEN}File has been successfully transformed and saved to '$output_file'.${RESET}"
}

# Function: Create minmax file with top and bottom stations based on capacity-consumption difference
sort_file_minmax() {
    # Define input and output file paths
    local input_file="tests/$1"
    local output_file="tests/${1%.csv}_minmax.csv"

    # Check if the input file exists
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}Error: Input file '$input_file' not found.${RESET}" >&2
        exit 1
    fi

    # Check if the input file contains data
    if [[ ! -s "$input_file" ]]; then
        echo -e "${RED}Error: Input file '$input_file' is empty.${RESET}" >&2
        exit 1
    fi

    echo -e "${CYAN}Creating a file with the 10 best and 10 worst stations based on capacity-consumption difference...${RESET}"

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
        echo -e "${RED}Error: Failed to create output file '$output_file'.${RESET}" >&2
        exit 1
    fi

    echo -e "${GREEN}File with top 10 best and worst stations saved to '$output_file'.${RESET}"
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
        echo -e "${RED}Error: Missing parameters.${RESET}" >&2
        display_help
        exit 1
    fi

    # Define variables for script parameters
    local csv_file="inputs/$1"          # Input CSV file path
    local station_type="$2"             # Station type (e.g., "hv", "lv")
    local consumer_type="$3"            # Consumer type (e.g., "all", "household")
    local central_id="${4:-all}"        # Central ID, defaulting to "all" if not specified

    # Verify the validity of provided parameters
    verify_parameters "$csv_file" "$station_type" "$consumer_type"

    # Ensure the temporary directory exists
    check_and_create_tmp

    echo -e "\n${CYAN}Input Parameters:${RESET}"
    # Display the input parameters for clarity
    echo -e "${CYAN}CSV file:${RESET} $csv_file"
    echo -e "${CYAN}Station type:${RESET} $station_type"
    echo -e "${CYAN}Consumer type:${RESET} $consumer_type"
    echo -e "${CYAN}Central ID:${RESET} $central_id\n"

    # Measure the time taken to filter and copy data
    measure_time filter_and_copy_data "$csv_file" "$station_type" "$consumer_type" "$central_id"
    echo -e "${GREEN}Processing completed successfully.${RESET}\n"

    # Perform additional checks and compilation if necessary
    check_and_compile "$station_type" "$consumer_type" "$central_id"
    echo -e "\n${GREEN}Compilation and execution completed.${RESET}"

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
    echo -e "\n${GREEN}Sorting completed.${RESET}"

    # If the station type is "lv" and consumer type is "all", process min/max sorting and transformation
    if [[ "$station_type" == "lv" && "$consumer_type" == "all" ]]; then
        measure_time sort_file_minmax "$input_file"
        # Copy and transform the minmax sorted file
        copy_and_transform_csv "lv_all_minmax.csv"
        echo -e "${GREEN}Min/Max Sorting and Transformation Completed.${RESET}\n"
    fi

    # Copy and transform the main input file
    copy_and_transform_csv "$input_file"
    echo -e "${GREEN}Transformation of the main input file completed.${RESET}\n"

    # Navigate to the CodeC directory, clean up previous builds, and return to the original directory
    cd CodeC/
    make clean
    cd ..
}

# Invoke the main function with all passed arguments
main "$@"


