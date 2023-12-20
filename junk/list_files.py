import os
directory = input("Enter a dir name :")
def list_files(directory = directory):
    print(f"Listing files in {os.path.abspath(directory)}: ")
    files = os.listdir(directory)

    for file in files:
        print(file)

list_files()
