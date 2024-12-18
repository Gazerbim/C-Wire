# C-Wire

This is a program that will help you visualize your power data.

## Compile Instructions

1. **Grant execution permissions**:
   ```bash
   chmod +x c-wire.sh
   ```
   This gives the shell file permission to execute.

2. **Run the program**:
   ```bash
   ./c-wire.sh CSVfile.dat station individu central_id
   ```

### Parameters
- **`c-wire.sh`**: The name of the shell script file.
- **`CSVfile.dat`**: The name of the CSV file to be filtered (e.g., `c-wire_v25.dat`) in the "inputs" folder
- **`station`**: The name of the requested station (e.g., `hvb`, `hva`, `lv`).
- **`individu`**: The type of person treated (e.g., `comp`, `indiv`, `all`).
- **`central_id`** (optional): The name of the requested central:
  - If omitted, the program will process data for all centrals.

### Example Usage
```bash
./c-wire.sh c-wire_v25.dat hva comp 2
```
In this example:
- The program will process the file `c-wire_v25.dat`.
- It will filter data for station `hva`.
- It will handle `comp` type individuals.
- It will focus on central ID `2`.

If `central_id` is not specified, all central IDs will be included.

## Output
Just sit back and let the machine do its work! The program will process your data and generate the desired output based on the given parameters.






contenant les instructions pour compiler et pour utiliser
votre application. Il contiendra aussi un document au format PDF
présentant la répartition des tâches au sein du groupe, le planning de
réalisation, et les limitations fonctionnelles de votre application (la liste
de ce qui n’est pas implémenté, et/ou de ce qui est implémenté mais qui
ne fonctionne pas correctement/totalement).
