# **mygrep.sh** - A Custom Mini-Grep Script  

## 📌 **Overview**  
`mygrep.sh` is a lightweight, custom-built Bash script that mimics the core functionalities of the `grep` command. It allows users to search for a **case-insensitive** string within a text file and supports extra functionalities like showing line numbers and **inverting matches** (displaying non-matching lines).

## 🚀 **Features**  
✔️ Case-insensitive string searching.  
✔️ Displaying matching lines from a text file.  
✔️ **Options:**  
   - `-n` → Show line numbers for each match.  
   - `-v` → Invert match (print lines that **do not** match).  
   - `--help` → Show usage information.  
✔️ Supports option combinations (e.g., `-vn` or `-nv` work the same).  
✔️ Input validation to prevent errors (e.g., missing file or search string).  
✔️ Mimics standard `grep` output formatting.  

---

## ⚙️ **Installation & Setup**  
### **1️⃣ Download the script**  
Save the following Bash script as `mygrep.sh`:  

```bash
#!/bin/bash
# mygrep.sh - A mini version of grep with case-insensitive search,
# support for line numbers (-n) and inverted matching (-v), plus a help menu.

usage="Usage: $0 [OPTIONS] search_pattern file
Options:
  -n        Show line numbers for each match.
  -v        Invert match (print lines that do not match).
  --help    Display this help message."

# Show help if requested
if [[ "$1" == "--help" ]]; then
    echo "$usage"
    exit 0
fi

# Initialize flags
line_numbers=false
invert_match=false

# Parse options using getopts
while getopts ":nv" opt; do
    case $opt in
        n) line_numbers=true ;;
        v) invert_match=true ;;
        \?) echo "Error: Invalid option -$OPTARG"; echo "$usage"; exit 1 ;;
    esac
done

# Shift processed options
shift $((OPTIND - 1))

# Validate arguments
if [ "$#" -ne 2 ]; then
    echo "Error: Missing arguments."
    echo "$usage"
    exit 1
fi

search="$1"
file="$2"

# Check file existence
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    exit 1
fi

# Read file line by line
line_num=0
while IFS= read -r line; do
    ((line_num++))
    
    # Case-insensitive match
    shopt -s nocasematch
    is_match=false
    [[ "$line" == *"$search"* ]] && is_match=true
    shopt -u nocasematch

    # Handle -v (invert match)
    [[ "$invert_match" == true && "$is_match" == true ]] && continue
    [[ "$invert_match" == false && "$is_match" == false ]] && continue

    # Print matching line with optional line numbers
    [[ "$line_numbers" == true ]] && echo "${line_num}:$line" || echo "$line"
done < "$file"

exit 0
```

### **2️⃣ Make the script executable**  
Run the following command to grant execution permissions:  

```bash
chmod +x mygrep.sh
```

---

## 📖 **Usage Examples**  
Create a sample text file (`textfile.txt`) containing:  

```
Hello world
This is a test
another test line
HELLO AGAIN
Don't match this line
Testing one two three
```

### 🔹 **Basic search (case-insensitive):**  
Search for `"hello"`:  
```bash
./mygrep.sh hello textfile.txt
```
**Expected output:**  
```
Hello world
HELLO AGAIN
```
![](./screenshots/test1.png)
### 🔹 **Search with line numbers (-n):**  
```bash
./mygrep.sh -n hello textfile.txt
```
**Expected output:**  
```
1:Hello world
4:HELLO AGAIN
```
![](./screenshots/test2.png)
### 🔹 **Invert match (-v):**  
```bash
./mygrep.sh -v hello textfile.txt
```
**Expected output:**  
```
This is a test
another test line
Don't match this line
Testing one two three
```
![](./screenshots/test3.png)

### 🔹 **Invert match + line numbers (-vn or -nv):**  
```bash
./mygrep.sh -vn hello textfile.txt
```
**Expected output:**  
```
2:This is a test
3:another test line
5:Don't match this line
6:Testing one two three
```
![](./screenshots/test4.png)

### 🔹 **Help flag:**  
```bash
./mygrep.sh --help
```
**Expected output:**  
```
Usage: ./mygrep.sh [OPTIONS] search_pattern file
Options:
  -n        Show line numbers for each match.
  -v        Invert match (print lines that do not match).
  --help    Display this help message.
```
![](./screenshots/test5.png)
---

## 🔍 **Troubleshooting**  
### ❌ **Error: Missing arguments**  
If the script is run without a search string:  
```bash
./mygrep.sh -v textfile.txt
```
**Output:**  
```
Error: Missing arguments.
Usage: ./mygrep.sh [OPTIONS] search_pattern file
Options:
  -n        Show line numbers for each match.
  -v        Invert match (print lines that do not match).
  --help    Display this help message.
```
💡 **Fix:** Ensure both a search string and file name are provided.

### ❌ **Error: File not found**  
If the script is run on a non-existent file:  
```bash
./mygrep.sh hello nonexistent.txt
```
**Output:**  
```
Error: File 'nonexistent.txt' not found.
```
💡 **Fix:** Verify the file exists before running the command.

---

## 🚀 **Future Enhancements**  
🔹 Add support for **regular expressions** like the original `grep`.  
🔹 Enable searching across **multiple files** simultaneously.  
🔹 Enhance **error handling** for malformed inputs.  

---