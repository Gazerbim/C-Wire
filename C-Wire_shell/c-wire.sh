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
    echo "  - hvb all, hva all"
    echo ""
    echo "Example usage:"
    echo "  $0 data.csv hvb comp 1"
}

# Verify parameters
verify_parameters() {
    local csv_file="$1"
    local station_type="$2"
    local consumer_type="$3"

    if [[ ! -f "$csv_file" ]]; then
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
    if { [[ "$station_type" == "hvb" || "$station_type" == "hva" ]] && [[ "$consumer_type" == "all" ]]; }; then
        echo "Error: The combination $station_type $consumer_type is forbidden." >&2
        display_help
        exit 1
    fi
}

# Check and create tmp directory
check_and_create_tmp() {
    if [[ -d "tmp" ]]; then
        echo "The tmp directory already exists. Clearing its contents..."
        rm -rf tmp/*
    else
        echo "Creating the tmp directory..."
        mkdir tmp
    fi
}

# Filter and copy data
filter_and_copy_data() {
    local input_file="$1"
    local station_type="$2"
    local consumer_type="$3"
    local central_id="$4"
    local output_file="tmp/filtered_data.dat"

    echo "Filtering data based on station type, consumer type, and central ID..."

    head -n 1 "$input_file" > "$output_file"

    tail -n +2 "$input_file" | while IFS=';' read -r power_plant hvb_station hva_station lv_station company individual capacity load; do
        local station_match="-"
        case "$station_type" in
            hvb) station_match="$hvb_station" ;;
            hva) station_match="$hva_station" ;;
            lv) station_match="$lv_station" ;;
        esac

        # Check if the station type matches (not '-') and matches the central_id (if provided)
        if [[ "$station_match" != "-" ]]; then
            local consumer_match="-"
            case "$consumer_type" in
                comp) consumer_match="$company" ;;
                indiv) consumer_match="$individual" ;;
                all) consumer_match="valid" ;;
            esac

            # Check central_id match
            local id_match="true"
            if [[ "$central_id" != "all" ]]; then
                if [[ "$central_id" != "$company" && "$central_id" != "$individual" ]]; then
                    id_match="false"
                fi
            fi

            # If all conditions match, append the row to the output file
            if [[ "$consumer_match" != "-" && "$id_match" == "true" ]]; then
                echo "$power_plant;$hvb_station;$hva_station;$lv_station;$company;$individual;$capacity;$load" >> "$output_file"
            fi
        fi
    done

    echo "Filtered data has been saved to $output_file"
}

# Main function
main() {
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

    filter_and_copy_data "$csv_file" "$station_type" "$consumer_type" "$central_id"

    echo "Processing completed successfully."
}

main "$@"