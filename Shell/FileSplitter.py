import os
import shutil
from datetime import datetime

print("Start Time :", datetime.now())

# Master File Name
MASTER_FILE = "orig.csv"

# No Of Files in which the Original files will be split into
SPLIT_FILE_COUNT = 5

# Split File Names
SPLIT_FILE_NAME_ARR = ["split_11.csv", "split_12.csv", "split_13.csv", "split_14.csv", "split_15.csv"]

# Port to Add
PORT_NO_ARR = [9091, 9092, 9093, 9094, 9095]

# CUST_ID_START and END Range
CUST_ID_START = 101
CUST_ID_END = 200

mstr_file_extn = MASTER_FILE.rsplit('.', 1)[-1]
mstr_file_base_nm = os.path.splitext(os.path.basename(MASTER_FILE))[0]
port_appnd_fl_name = f"{mstr_file_base_nm}_port_append.{mstr_file_extn}"

tmp_split_fl_name = "temp_split_file_"
shutil.rmtree(tmp_split_fl_name, ignore_errors=True)

OUTPUT = "output/"
os.makedirs(OUTPUT, exist_ok=True)

# Validate User Input
def validate_input():
    print("  Validating User Input")

    NO_OF_SPLIT_FILES = len(SPLIT_FILE_NAME_ARR)
    if SPLIT_FILE_COUNT != NO_OF_SPLIT_FILES:
        print("    Error - Split File Name (SPLIT_FILE_NAME_ARR) and File Count (SPLIT_FILE_COUNT) do not match.")
        exit(1)

# Create Master File
def create_master_file():
    print("  Creating Master File ...")

    if os.path.exists(MASTER_FILE):
        os.remove(MASTER_FILE)

    with open(MASTER_FILE, 'w') as master_file:
        for i in range(CUST_ID_START, CUST_ID_END + 1):
            master_file.write(str(i) + '\n')

def append_port_no():
    print("  Appending the Port No to Customer ID ...")
    no_of_ports = len(PORT_NO_ARR)
    with open(MASTER_FILE, 'r') as master_file, open(port_appnd_fl_name, 'w') as port_append_file:
        for line in master_file:
            port_append_file.write(f"{line.rstrip()},{PORT_NO_ARR[no_of_ports % len(PORT_NO_ARR)]}\n")
            no_of_ports = (no_of_ports + 1) % len(PORT_NO_ARR)

# Split Files
def split_files():
    print("  Split master File ...")

    with open(f"{mstr_file_base_nm}_port_append.{mstr_file_extn}", 'r') as port_append_file:
        tot_rec_cnt = sum(1 for line in port_append_file)
        print("    Total No Of records In Master File :", tot_rec_cnt)

    split_cnt_rec = tot_rec_cnt // SPLIT_FILE_COUNT
    print("    No Of records per Split File :", split_cnt_rec)

    os.system(f"split -l {split_cnt_rec} {mstr_file_base_nm}_port_append.{mstr_file_extn} temp_split_file_")

# Rename Split Files
def rename_split_files():
    print("  Renaming splitted Files ...")

    idx = 0
    for temp_file in sorted(os.listdir(), key=lambda x: x):
        if temp_file.startswith("temp_split_file_"):
            split_file_name = SPLIT_FILE_NAME_ARR[idx]
            print(f"    Split File Name: {split_file_name}")
            os.rename(temp_file, split_file_name)
            idx += 1

# Validate Input
validate_input()

# Create Master File
create_master_file()

# Append Port No
append_port_no()

# Split File
split_files()

# Rename Split File Names
rename_split_files()

# Move Split Files to OUTPUT directory
for split_file_name in SPLIT_FILE_NAME_ARR:
    shutil.move(split_file_name, OUTPUT)

print("End Time :", datetime.now())