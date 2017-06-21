# MDF #

## Welcome to MDF ##

### What is MDF? ###
MDF stands for Multipurpose Data Framework.
It is a framework geared toward managing experimental data and the metadata data associated with it. 

Everything in the MDF is rapresented as an object. The mdf object is the smallest entity that can be created within the framework. It can be populated with data and metadata on-the-fly without previous definition.
The user instantiate the object and can start populate it right away.
Each object is identified by a unique id and has a type associated. 
By default the unique id is a uuid (https://en.wikipedia.org/wiki/Universally_unique_identifier), but any string can be assigned as id, as long as it is unique within the same group of objects. 
The object type can be defined as the best string to describe the object created and its data. There are no limitations within the system, it can be any string that the user would like to use. It is suggested to define the type as a short string to uniquely identify the type of data and metadata that is contained in the object itself. It is also suggested to use consistent type across object that represents and contains the same type of data and info.

It is considered data any time series or any series of numeric values acquired through measurement or sampling. They are usually vectors or matrix. 
On the contrary metadata are any property that describe and define the data saved in this object and by definition is simple and limited in dimension.
There is no limitation of what goes in metadata and in data, it is up to the user to decide.
One difference defined by designed is that metadata are loaded when the object is retrieved and created in memory, while data follow the lazy-loading paradigm: they are loaded in memory only when they are accessed.
Metadata and object definition can be queried by means of the mongodb instance that the MDF uses transparently.

There are currently 2 major version of the MDF: 
* 1.4.x
>In version 1.4.x, data are saved exclusively in mat files together with object definition hiddden structure and metadata. Object definition and metadata is also saved as documents in the associated mongodb database and in yaml text file. Therefore, only object definition and metadata can be queried through the mongodb instance. This choice was been made to offer queries capabilities through metadata and keep mongodb documents relatively small, reducing sys admin managament costs related to database instance.
* 1.5.x
>In branch v1.5.x, everything is saved exclusively in documents in Mongodb instance. Objects behave the same as v1.4.x, the source of everything are documents in Mongodb. This version is suitable for projects with small objects, aka small data sections. The advantages are: increased speed in saving and load objects, use of templates when creating new objects

## Versions available ##

### Version 1.4.x ###
### Set up? ###
* Requirements / Dependencies
  This version works on any version of Matlab from r2014a and up. All dependencies are included in the source code that you find in this repository.

* Install MDF
  Clone dev-1.4 branch or download the zip file. Place the code in a folder that is accessible to matlab

* Configuration
  Start matlab, make sure to add mdf/mMdf/core folder to your matlab path.
  Make sure that you have an instance of MongoDB running and that it is accessible fromt he machine where you are running matlab.

* Database configuration
  MDF uses an xml configuration file where to configure the location where the .mat and .yml files are located and the connection string to be able to reach the database. The xml file should be called mdb.conf.xml, an example is found under mdf/mMDF/templates/mdf.xml.conf.
  Multiple configurations can be used on the same machine. Just copy everything within the configuration tags and change as it is needed.
  MDF will automatically check the following folders in the user home (Linux: /home/<username>, OS X: /Users/<username>, Windows: /Users/<username>) for the mdf.conf.xml file:
  * .mdf
  * mdf
  * .MDF
  * MDF
  * .rnel
  * rnel
  * .RNEL
  * RNEL
  * MATLAB
  * Documents/MATLAB
 
  If the user would like to store the configuration file in other locations or wants to use an alternative one, just pass the full path to the conf fiel as it is specified in the next section

* Startup
  In order to start using mdf, the user has to instantiate the core classes. The main class mdf provides a static method to set up the correct environment.
  Here are the different method that mdf environment can be initialized:
  * let mdf check the standard location and ask which configuration we would like to use
        omdfc = mdf.init()
  * specify configuration file
        omdfc = mdf.init('<configuration_file_path>')
  * specify which configuration (#2 in this example) we would like to use specified in the configuration file saved in a standard location
        omdfc = mdf.init(2)
  * specify both configuration file and configuration to load
        omdfc = mdf.init('<configuration_file_path>',2)
  * specify both configuration file and configuration to load using a matlab struct
        omdfc = mdf.init(
            struct(
                'confFile', '<configuration_file_path>',
                'confSel', 2))
  
  The value returned by mdf.init and saved in omdfc is a structure with handler to the core classes used in the mdf environment:
          omdfc = 
                mdf: [1x1 mdf]
               conf: [1x1 mdfConf]
                 db: [1x1 mdfDB]
             manage: [1x1 mdfManage]

  where *mdf* is class containing useful methods used throughout the framework, *conf* contains all the value defined in the configuration file, *db* is the connection to the database and *manage* is the memory management class.
  User should not be concern with this variable unless any troubleshooting is required.

* How to test MDF on your platform
  * Linux
    * install mdf code in a folder that matches your needs
    * create the following structure under your home folder
      +- mdf
         +- conf
         +- data
    * make sure that mongodb is running on your local machine and is accepting connection on the standard port
    * open matlab and addpath mdf core folder <your_installation_folder>/mdf/mMDF/core
    * run the test environment 1 script in mdf/mMDF/test
        omdfc = testEnv1()
      this function should instantiate the correct mdf environment for the test, populate with a test hierarchical structure and return the omdfc data structure as specified above.
      it uses the following configuration file mdf/mMDF/templates/mdf.conf.test.env1.xml
    * Once the script has run successfully, you should find the omdfc variable in your matlab workspace.
    * If you do not find omdfc defined in your workspace, you can instantiate it with the following command:
        omdfc = mdf.init('<your_home_folder>/mdf/conf/mdf.conf.test.env1.xml')
    * you can now start exploring the test data from the root object that is of type subject:
        sbj = mdf.load(struct('mdf_type':'subject')

  * OS X
    *coming soon*
  * Windows 
    *coming soon*

