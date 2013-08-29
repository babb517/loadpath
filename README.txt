# ----------------------------------------------------------------------------
# Loadpath is a series of functions that allow you to manage
# and use path aliases within terminal environment.
# Author: Joseph Babb ( jbabb1 <at> asu <dot> edu ).
# ----------------------------------------------------------------------------
Functions: 
    savepath [<alias>] [-p <path>]
    spath [<alias>] [-p <path>]
        Saves an alias to path mapping.
        <alias> - The alias to assign. [Default: \"\"].
        <path>  - The path to assign to the alias. [Default: working directory]

    loadpath [<alias>]
    lpath [<alias>]
        Loads the path corresponding to the alias.
        <alias> - The alias to load. [Default: \"\"].

    listpath
    lspath
        Lists all stored aliases and their path mappings.

    removepath [<alias>]
    rmpath [<alias>]
        Removes an alias to path mapping.
        <alias> - The alias to remove. [Default: \"\"].
# ----------------------------------------------------------------------------
