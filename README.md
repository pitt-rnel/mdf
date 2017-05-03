# MDF #

## Welcome to MDF ##

### What is MDF? ###
MDF stands for Multipurpose Data Framwork.
It is a framework geared toward managing experimental data and the metadata data associated with it. 

Everything in the MDF is rapresented as an object. The mdf object is the smallest entity that can be created within the framework. It can be populated with data and metadata on-the-fly without previous definition.
The user instantiate the object and can start populate right away.
Each object is identified by a unique id. By default the unique id is a uuid, but any string can be assigned as id. 
Same is for the type object, it can be defined as the best string to describe the type of object created and its data. There are no limitations within the system.

The difference between data and metadata is that metadata are loaded when the object is retrieved, while data follow the lazy-loading paradigm, they are loaded in memory only when they are accessed.
As a rule of thumb, time series or data vectors should be inserted in the mdf object as data properties, while metadata should be object properties that are descriptive and few values.
Metadata and object definition can be queried by means of the mongodb instance that the MDF uses transparently.

As of v1.4.x, data are saved only in a mat file together with object definition hiddden structure and metadata. Object definition and metadata is also saved as documents in a mongodb database and in yaml text file. 
Therefore, only object definition and metadata can be queried through the mongodb instance.
This choice was been made to offer queries capabilities through metadata and keep mongodb documents relatively small, redcuing sys admin managament costs.

In branch v1.5.x, everything is saved exclusively in documents in Mongodb instance. Objecteds behave the same as v1.4.x, the source of everything are documents in Mongodb. This version is suitable for projects with small objects, aka small data sections. The advantages are an increased speed in saving and load objects.

## Versions available ##

### Version 1.4.x ###
### Set up? ###
* Requirements / Dependencies
* Install MDF
* Configuration
* Database configuration
* Startup
* How to test if you are ready for production

