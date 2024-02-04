import os

# Get the directory where the script is located
script_directory = os.path.dirname(os.path.abspath(__file__))

# Construct the path to the 'output' directory
directory_path = os.path.join(script_directory, 'output')

try:
    with os.scandir(directory_path) as entries:
        for entry in entries:
            print("\nentry",entry)
            if entry.is_file():
                file_path = entry.path
                print("file_path",file_path)
                try:
                    with open(file_path,'r') as file:
                        lines = file.readlines()
                        print("Line ",lines)

                    #Check if Last Line is Empty
                    print("Last Line ",lines)
                    if lines and lines[-1].strip() == '':
                        print("Last Line Removed")
                        lines.pop()
                    
                    # Write the modified content back to the file
                    with open(file_path, 'w') as file:
                        file.writelines(lines)

                except FileNotFoundError:
                    print("File Not Found")
except Exception as e:
    print("Error : ",e)