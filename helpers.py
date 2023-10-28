"""
Will contain functions to parse filenames, management of files
and other related functionalities.
"""

import os
import glob
import numpy as np


def findcharacter(word, character):
    """
    Finds the indices of a character in a string.
    https://stackoverflow.com/questions/21199943/index-of-second-repeated-character-in-a-string
    author: mhlester

    :param word: filename to parse
    :type word: string
    
    :param character: characters in string
    :type character: string
    
    :return: indices where character shows up
    :rtype: integer or array of integers
    """
    found = []
    last_index = -1
    while True:
        try:
            last_index = word.index(character, last_index+1)
        except ValueError:
            break
        else:
            found.append(last_index)
    return found

def removechars(word,characters):
    """
    Just using this temporarily to remove run# from the naming
    of simtel files. Need to find something better than this.
    
    ----------
    :param word: filename to parse
    :type word: string
    
    :param character: characters in string to be removed
    :type character: string
    
    :return: simtel naming without run# information
    :rtype: string
    """
    index = [i for i in range(len(word)) if word.startswith(characters, i)]
    indices = np.arange(index[0],index[0]+9)
    string_list = list(word)

    # Remove characters at the specified indices
    string_list = [char for index, char in enumerate(string_list) if index not in indices]

    # Convert the modified list back to a string
    new_word = ''.join(string_list)

    return new_word

def namesimtelfile(filepath, filename_ending):
    """
    Returns a newly named file while removing any path dependencies.
    For example:
    filepath = 'simtel_files/gamma_20deg_0deg_run10.simtel.gz'
    filename_ending = 'sim_container.h5'
    name_file(filepath,filename_ending) will return
    >> gamma_20deg_0deg_run10_sim_container.h5

    :param file_path: path to simtel file
    :type file_path: string
    
    :param filename_ending: ending to be specified for file
    :type filename_ending: string
    
    :return: new file name with removal of '/' and '.simtel.gz'
    :rtype: string
    """
    # Finds the index of every instance of '/'
    ind1 = findcharacter(filepath, '/')
    # Finds the starting index of '.simtel.gz'
    ind2 = findcharacter(filepath, '.simtel.gz')
    # removes all characters up to and including the last '/' as well as .simtel.gz
    new_filename = '{}_{}'.format(filepath[ind1[-1]+1:ind2[0]],filename_ending)
    
    return new_filename

def findfiles(directory_path,chars,absolutepath=False):
    """
    Will search for a file that has characters
    specified in chars.

    Parameters
    ----------
    directory_path : string
        absolute path to search file

    chars : string
        File type or characters contained in
        file for instance .fits or .txt

    absolutepath : boolean
        If True returns list of files with absolute path
        IF False returns list of files with relative path
    
    Returns
    -------
    string
        relative path where file is stored    
    """
    original_directory = os.getcwd()
    chars = '*' + chars
    files=[]
    
    # It seems like the absolute path option just returns the relative path
    if absolutepath==True:
        # Use os.walk() to iterate through the directory and its subdirectories
        for root, _, _ in os.walk(directory_path):
            os.chdir(root)  # Change to the current directory within the loop
            current_dir_files = glob.glob(str(chars)) # returns list, need to unpack
            absolutepathfiles = [os.path.join(root, file_name) for file_name in current_dir_files]
            files.extend(absolutepathfiles)
        # Change back to the original working directory
        os.chdir(original_directory)
        
        return files
    # This seems to return only the file name
    else:
        # Repeat almost exactly the same as before
        for root, _, _ in os.walk(directory_path):
            os.chdir(root)
            current_dir_files = glob.glob(str(chars))
            relativepathfiles = [os.path.relpath(os.path.join(root, file_name), directory_path) for file_name in current_dir_files]
            files.extend(relativepathfiles)
        os.chdir(original_directory)

        return files

def cleaning_params(*args):
    """
    Will create file name ending with cleaning type and parameters used.
    Parameters will follow the ctapipe input order
    Example: 
    print(cleaning_name("2pass", "4", "2"))
    >> "2pass_4_2_"
    """
    name = ""
    for arg in args:
        name += arg+'_'
    return name[:-1]