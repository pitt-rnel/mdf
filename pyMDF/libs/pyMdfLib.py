#
# python library to facilitate loading metadata and data from any MDF DC
#
# by: Max Novelli
#     man8@pitt.edu
#     2018/11/05
#

import json
import pymongo
import copy
import uuid
import datetime
from pandas.core.series import Series
#from numpy import ndarray,asarray
import numpy as np
import xml.etree.ElementTree as ET
import os
import h5py

modulePath = os.path.dirname(os.path.abspath(__file__))
configurationFile = os.path.join(modulePath,'../conf/mdf.1_6.xml.conf')
mdfObjectTemplate = os.path.join(modulePath,'../templates/mdfObjTemplate.json')
mdfSchemaJsFile = os.path.join(modulePath,'../../javascript/mdfDbSchema.js')
mdfConfigurations = []
mdfConfiguration = []

toList = lambda item: item if isinstance(item,list) else [item]

def showMdfConfigurationFile():
    global configurationFile
    return configurationFile


def mdfConfDecode(inXml,temp={}):
    #
    # makes sure that for each configuration, constants are properly decoded
    outC = {}
    name = inXml.tag
    if inXml.getchildren():
        # branch
        for child in inXml:
            # retrieve name and value of child
            cname = child.tag
            cvalue = mdfConfDecode(child,temp)
            attributes = child.attrib
            # check if it is a relative path
            if 'relative_path_to' in attributes.keys():
                cvalue = os.path.join(temp['tokens'][attributes['relative_path_to']],cvalue)
            # save value as a token
            token_name = cname if 'token_name' not in attributes else attributes['token_name']
            if 'tokens' not in temp.keys():
                temp['tokens'] = {}
            temp['tokens'][token_name] = cvalue
            # insert the value
            outC[cname] = cvalue
            # check if we need to save he value and present it somewhere else
            if 'present_as' in attributes.keys():
                if 'present_in' in attributes.keys():
                    # check if we need to create the present keys
                    if 'presents' not in temp.keys():
                        temp['presents'] = {}
                    if attributes['present_in'] not in temp['presents'].keys():
                        temp['presents'][attributes['present_in']] = {}
                    # save value for later
                    temp['presents'][attributes['present_in']][attributes['present_as']] = cvalue
                else:
                    # present the value here under a different name
                    outC[attributes['present_as']] = cvalue
            # insert values that needs to be presented here
            if 'presents' in temp.keys() and name in temp['presents'].keys():
                for akey,avalue in temp['presents'][name].items():
                    outC[akey] = avalue
                
    else:
        # leaf
        outC = inXml.text

    return outC


def mdfConfExtract(inXml):
    configurations = {};
    # expect only one tag named configurations
    for configuration in inXml.findall('./configuration'):
        # cycle on all the available configurations
        human_name = configuration.find('name').text
        machine_name = human_name.lower().replace(' ','_')
        configurations[machine_name] = {
            'human_name' : human_name,
            'machine_name' : machine_name,
            'description' : configuration.find('description').text,
            'constants' : mdfConfDecode(configuration.find('constants'))
        }
        
    return configurations

def getMdfConfiguration(selection=0):
    conf = False
    global configurationFile
    global mdfConfigurations
    global mdfConfiguration
    # load configuration as xml tree
    xmlTree = ET.parse(configurationFile)
    xmlRoot = xmlTree.getroot()
    # converts it to mdf dictionary
    mdfConfigurations = list(mdfConfExtract(xmlRoot).values())
    if type(selection) == int:
        # we got the index of the configuration
        conf = mdfConfigurations[0]
    else:
        # we got the name of the configuration
        conf = [item for item in mdfConfigurations if selection in item['human_name']][0]
    mdfConfiguration = conf
    return conf


def getMdfObjTemplate():
    template = False
    global mdfObjectTemplate
    # load mdf object template
    with open(mdfObjectTemplate, 'r') as fh:
        template = json.load(fh)
    return template

def connectMdfDC():
    global mdfConfiguration
    dbClient = pymongo.MongoClient(
        mdfConfiguration["constants"]['DB']["HOST"], 
        int(mdfConfiguration["constants"]['DB']["PORT"]))
    dbDb = dbClient[mdfConfiguration['constants']['DB']['DATABASE']]
    dbColl = dbDb[mdfConfiguration['constants']['DB']['COLLECTION']]
    return (dbClient,dbDb,dbColl)


def initPyMDF(configuration=0):
    global mdfObjTemplate
    global mdfConfiguration
    global dbColl
    global dbDatabase
    global dbClient
    global mdfSchemaQuery
    global mdfSchemaJsFile

    mdfConfiguration = getMdfConfiguration(selection=configuration)
    mdfObjTemplate = getMdfObjTemplate()
    dbClient, dbDb, dbColl = connectMdfDC()


    with open(mdfSchemaJsFile,'r') as fh:
        mdfSchemaQuery = json.load(fh)
    mdfSchemaQuery["mapReduce"] = mdfConfiguration['constants']['DB']['COLLECTION']

    return (mdfConfiguration,mdfObjTemplate,dbClient,dbDb,dbColl,mdfSchemaQuery)

def getNewMdfObject(objType,objUuid='',objTemplate=None):
    global mdfObjTemplate
    obj = copy.deepcopy(objTemplate) if type(objTemplate) == dict else copy.deepcopy(mdfObjTemplate)
    obj['mdf_def']['mdf_type'] = objType
    obj['mdf_def']['mdf_uuid'] = getUuid()
    obj['mdf_def']['mdf_vuuid'] = getUuid()
    obj['mdf_def']['mdf_created'] = getTimestamp()
    obj['mdf_def']['mdf_modified'] = getTimestamp()
    return obj

def addParent(obj,parent):
    # extract uuids of current parents
    pUuids = [item['mdf_uuid'] for item in obj['mdf_def']['mdf_parents']] if obj['mdf_def']['mdf_parents'] else []
    if parent['mdf_def']['mdf_uuid'] not in pUuids:
        obj['mdf_def']['mdf_parents'].append(getReference(parent))
        return True
    return False

def getReference(obj):
    return {
            'mdf_uuid' : obj['mdf_def']['mdf_uuid'],
            'mdf_type' : obj['mdf_def']['mdf_type'],
            'mdf_file' : ''
        }

def getUuid():
    return str(uuid.uuid4())

def getTimestamp():
    return datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

def getDataRef(data):
    """
    return the reference structure for the data
    prepare data item to be inserted in object
    """
    return {
        "mdf_class" : str(data.dtype),
        "mdf_size": [data.shape[item] for item in range(data.ndim)],
        "mdf_mem": data.nbytes }

def isChild(mdfObj,prop):
    """
    returns true if the property given is a child of the object
    false otherwise
    """
    return True if prop in mdfObj['mdf_def']['mdf_children']['mdf_fields'] else False;

def getChildrenUuids(mdfObj,prop,default='error'):
    """
    returns all the uuids linked to this object under the child property prop
    
    Parameters:
    - default: behavior if the property does not exists
    """
    
    if not isChild(mdfObj,prop) and default != 'error':
        if default.lower() == "none":
            # returns empty if the property does not exists
            return None
        elif default.lower() == "empty":
            return []
        else:
            return default
    
    # default behavior
    return [item['mdf_uuid'] for item in toList(mdfObj['mdf_def']['mdf_children'][prop])]

def getChildrenObjs(mdfObj,prop):
    return getMdfObjectsByUuids(getChildrenUuids(mdfObj,prop))

def isLink(mdfObj,prop):
    """
    returns true if the property given is a child of the object
    false otherwise
    """
    return True if prop in mdfObj['mdf_def']['mdf_links']['mdf_fields'] else False;


def getLinksUuids(mdfObj,prop,default='error'):
    """
    returns all the uuids linked to this object under the link property prop
    
    Parameters:
    - default: behavior if the property does not exists
    """
    
    if not isLink(mdfObj,prop) and default != 'error':
        if default.lower() == "none":
            # returns empty if the property does not exists
            return None
        elif default.lower() == "empty":
            return []
        else:
            return default
    
    # default behavior
    return [item['mdf_uuid'] for item in toList(mdfObj['mdf_def']['mdf_links'][prop])]

def getLinksObjs(mdfObj,prop):
    return getMdfObjectsByUuids(getLinksUuids(mdfObj,prop))


def getParentUuids(mdfObj,default='error'):
    """
    returns all the uuids linked to this object as parents
    
    Parameters:
    - default: behavior if the property does not exists
    """
    
    if not mdfObj['mdf_def']['mdf_parents'] and default != 'error':
        if type(default) is str and default.lower() == "none":
            # returns empty if the property does not exists
            return None
        elif type(default) is str and default.lower() == "empty":
            return []
        else:
            return default
    
    # default behavior
    return [item['mdf_uuid'] for item in toList(mdfObj['mdf_def']['mdf_parents'])]

def getParentObjs(mdfObj):
    return getMdfObjectsByUuids(getParentUuids(mdfObj),default='empty')

def getMdfObjectByUuid(objUuid):
    #
    # retrieve the mdf Object given the uuid
    global dbColl

    return [item for item in dbColl.find({'mdf_def.mdf_uuid':objUuid},{'_id':0,'mdf_def':1,'mdf_metadata':1})][0]

def getMdfObjectsByUuids(objUuids):
    #
    # retrieve the mdf Objects given the list of uuids
    global dbColl

    return [item for item in dbColl.find({'mdf_def.mdf_uuid': {'$in' : objUuids}},{'_id':0,'mdf_def':1,'mdf_metadata':1})]

def getMdfObjectsByQuery(query):
    #
    # retrieve the mdf Objects given the query
    global dbColl

    return [item for item in dbColl.find(query,{'_id':0,'mdf_def':1,'mdf_metadata':1})]


def getMetadata(mdfObj):
    return mdfObj['mdf_metadata']


def metadataToDataframe(mdfObjs):
    return pd.DataFrame([flatten_dict(item['mdf_metadata']) for item in mdfObjs])


def getDataProp(mdfObj,prop):
    # getDataProp(mdfObj,prop,out)
    #
    # return the value of the data property prop from the mdfObj
    #
    # open data file
    dataFile = h5py.File(getDataFile(mdfObj))
    value = dataFile[prop].value
    dataFile.close()
    return value


def getDataFile(mdfObj):
    # get the path to the data file, taking care of F-windows backslash issue
    return filterMdfString(mdfObj['mdf_def']['mdf_files']['mdf_data'].replace('\\','/'))


def filterMdfString(mdfString):
    global mdfConfiguration
    for key in mdfConfiguration['constants'].keys():
        mdfString = mdfString.replace('<' + key + '>', mdfConfiguration['constants'][key]) \
            if isinstance(mdfConfiguration['constants'][key],str) \
            else mdfString
    return mdfString


#def insertData(obj,prop,data):
#    # insert new data property or replace existing data property
#    #
#
#    # check the type of the data
#    if isinstance(data,Series):
#        data = data.values
#    if not isinstance(data,ndarray):
#        raise Exception("pyEmgDecoding.insertData : invalid data type")
#
#    ref = getDataRef(data)
#
#    # insert data prop in list if necessary
#    if not prop in obj['mdf_def']['mdf_data']['mdf_fields']:
#        obj['mdf_def']['mdf_data']['mdf_fields'].append(prop)
#
#    # update/insert new data property ref
#    obj['mdf_def']['mdf_data'][prop] = ref
#
#    # insert data in object
#    obj[prop] = data.tolist()
#
#    return obj

def isfloat(value):
  try:
    float(value)
    return True
  except ValueError:
    return False

def getCollStats():
  global dbColl
  return [
    item
    for item 
    in dbColl.aggregate([
      {'$group' : {
        '_id'   : '$mdf_def.mdf_type',
        'count' : { '$sum' : 1 }
      }},
      {'$project' : {
        '_id'      : 0,
        'mdf_type' : '$_id',
        'count'    : '$count'
      }}
    ])]

def getSchema():
  global mdfSchemaQuery
  global dbColl

  res = dbColl.map_reduce(
    map=mdfSchemaQuery['map'],
    reduce=mdfSchemaQuery['reduce'],
    finalize=mdfSchemaQuery['finalize'],
    out=mdfSchemaQuery['out']
  )

  docNumber = res['counts']['input']

  mrCounts = [item['value'] for item in res['results']]

  # initialize schema to mdf_type counts
  schema = [
    {
      'mdf_type' : item['mdf_type'],
      'count'    : item['count'],
      'percent'  : item['count'] / docNumber
    }
    for item
    in mrCounts
    if item['value_type'] == 'all' and item['data_type'] == 'all' and item['field'] == 'all'
  ]

  # build stats for each metedata fields
  for item1 in schema:
    # extract total fields count for current mdf
    item1['mdf_metadata'] = [
      {
        'mdf_property'  : item2['field'],
        'count'         : item2['count'],
        'percent'       : item2['count'] / item1['count'],
        'property_type' : 'metadata'
      }
      for item2
      in mrCounts
      if item2['value_type'] == 'all' and item2['data_type'] == 'metadata' and item2['mdf_type'] == item1['mdf_type']
    ]
    
    # for each property extract data types
    for item2 in item1['mdf_metadata']:
      # extract all the different data types for this property
      item2['value_type'] = [
        {
          'value_type' : item3['value_type'],
          'count'      : item3['count'],
          'percent'    : item3['count'] / item2['count']
        }
        for item3
        in mrCounts
        if item3['mdf_type'] == item1['mdf_type'] and item3['value_type'] != 'all' and item3['field'] == item2['mdf_property'] and item3['data_type'] == 'metadata'
      ]

  return schema

def printMetadataSummary(obj):
  for key,value in obj['mdf_metadata'].items():
    vkey = key if len(key)<=20 else key[0:17] + '...'
    if isinstance(value,dict):
        lkeys = list(value.keys())
        skeys = " , ".join(lkeys)
        skeys = skeys if len(skeys)<=50 else skeys[0:47] + '...'
        print('{:20s} : [dict]        {:50s}'.format(vkey,skeys))
    elif isinstance(value,list):
        sValue = ",".join([str(item) for item in value])
        sValue = sValue if len(sValue)<=50 else sValue[0:47] + '...'
        print('{:20s} : [array,{:5d}] {:50s}'.format(vkey,len(value),sValue))
    else:
        print('{:20s} :               {:40s}'.format(vkey,str(value)))


def printDataSummary(obj):
  for field in obj['mdf_def']['mdf_data']['mdf_fields']:
    info = obj['mdf_def']['mdf_data'][field]
    print(
      'Data property : {:20s} [{:>9d}x{:<9d} {:10s}]'.format(
        field,
        int(info['mdf_size'][0]),
        int(info['mdf_size'][1]),
        info['mdf_class']))

