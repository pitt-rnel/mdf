
class mdfConf:

    # properties
    # name of the file with the configuration
    filename = 'mdf.conf.xml'

    # type of configuration file
    fileType ='unknown'

    # data read from configuration file
    fileData

    # configuration data structure
    confData

    # temp dictionary with configuration file
    temp

    # configuration selected
    selection = 0

    # automation
    automation = 'none'
    automationList = ['none',' load', 'exctract', 'select', 'start']

    # menu type
    menuType = 'auto'
    menuTypeList = ['text', 'gui', 'auto']

    # list of path to search for the configuration
    searchPaths = [
        '.mdf',
        'mdf',
        '.MDF',
        'MDF',
        '.rnel',
        'rnel',
        '.RNEL',
        'RNEL',
        'MATLAB',
        'Documents/MATLAB'
    ]

    # methods

