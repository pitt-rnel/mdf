#
# python implementation or mdfObj class
#
# by: Max Novelli
#     man8@pitt.edu
#

import mdf
import mdfDB
import mdfConf
import mdfManage
import sys
import hdf5storage
import os
import yaml
import mat4py
import json
import copy
import numpy

class mdfObj(object):
    #
    # control structure
    # this dictionary contains all the definitions for the object instance
    mdf_def = dict()
    #
    # metadata container
    mdf_metadata = dict()
    #
    # data container
    mdf_data = dict()
    #
    # status container
    mdf_status = dict()

    # ----------------------
    # getter/setter for type
    @property
    def type(self):
        return self.mdf_def['mdf_type']
    # end def uuid getter
    @type.setter
    def type(self, value):
        self.mdf_def['mdf_type'] = value
    # end def type setter
    # ----------------------
    # getter/setter for uuid
    @property
    def uuid(self):
        return self.mdf_def['mdf_uuid']
    # end def uuid getter
    @uuid.setter
    def uuid(self, value):
        self.mdf_def['mdf_uuid'] = value
    # end def uuid setter
    # ----------------------
    # getter/setter for vuuid
    @property
    def vuuid(self):
        return self.mdf_def['mdf_vuuid']
    # end def vuuid getter
    # ----------------------
    # getter/setter for created
    @property
    def created(self):
        return self.mdf_def['mdf_created']
    # end def created getter
    # ----------------------
    # getter/setter for modified
    @property
    def modified(self):
        return self.mdf_def['mdf_modified']
    # ----------------------

    #
    def addParent(self,parent):
        '''
        Add parent to current object
        :param parent:
                (string) uuid of the parent object
                (mdfObj) parent object
        :return: (boolean) True if added
        '''

        # initialize return value
        result = False

        # get parent uuid and object
        uParent, oParent = mdf.getUuidAndObject(parent)

        # structure of the mdf_parent array
        # - mdf_uuid
        # - mdf_file
        # - mdf_type

        # check if parent is already present
        # get parents uuid
        alreadyParent = False;
        if isinstance(self.mdf_def['mdf_parents'],dict) \
                and not self.mdf_def['mdf_parents'].keys():
            # get uuids for all parents
            pUuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_parents']]
            # search for uuid
            alreadyParent = (uParent in pUuids)
        # end if

        # insert parent if needed
        if not alreadyParent:
            # prepare parent item
            item = { \
                'mdf_uuid': uParent, \
                'mdf_file': oParent.getMFN(False), \
                'mdf_type': oParent.type}
            # check if it is the first parent or not
            if not isinstance(self.mdf_def['mdf_parents'], dict) \
                    or not self.mdf_def['mdf_parents'][0]:
                # first parent
                # initialize list
                self.mdf_def['mdf_parents'] = [item]
            else:
                # not the first parent
                # append
                self.mdf_def['mdf_parents'].append(item)
            # end if/else
            result = True
        #end if
        return result
    #end def addParent

    #
    def rmParent(self,parent=None):
        '''
        remove selected parent
        :param parent:
                (string) uuid of the parent selfect
                (mdfObj) parent object
        :return: (boolean) True if removed, False otherwise
        '''

        # initialize return value
        result = False

        if parent:
            # get uuid and selfect from argument passed
            uParent, oParent = mdf.getUuidAndObject(parent);
            if isinstance(oParent,mdfObj):
                raise Exception('mdfself:rmParent - Invalid object or uuid ')
            # end if

            # structure of the mdf_parent array
            # - mdf_uuid
            # - mdf_file
            # - mdf_type

            # check if object is present in parents list
            # get parents uuid
            pUuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_parents']]
            # search for uuid
            iParent = pUuids.index(uParent)

            # remove parent if needed
            if iParent:
                self.mdf_def['mdf_parents'].pop(iParent)
                result = True
            # end if
        else:
            # remove all parents
            self.mdf_def['mdf_parents'] = []
            result = True
        #end if

        return result
    # end rmParent

    #
    def getParent(self, selector=0):
        '''
        return the object parent according to the selector
        :param selector: value used to select requested parent
            options
                * numeric: index of the parent within the parents array of
                    objects
                * string: uuid of the parent
                * struct: query structure to find parent
        :return: (mdfObj) parent(s) requested
        '''

        # initialize output list
        parents = []

        # initialize parents index list
        indexes = []
        # find which parent needs to be returned
        if isinstance(selector, int):
            # use selector a parent index
            indexes.append(selector)

        elif isinstance(selector, str):
            # selector is a string, we assume it is the parent uuid
            # find index of the object with this uuid
            # and adds it to the list
            indexes += \
                [item['mdf_uuid'] for item in self.mdf_def['mdf_parents']].index(selector)

        elif isinstance(selector, dict):
            # selector is a dictionary, we pass it to the query method and see what
            # we get back

            # now we are ready to build the json query
            query = mdfDB.prepQuery(selector)
            # get database instance
            odb = mdfDB.getInstance()
            # runs query and hopes for the best
            mdf_data = odb.find(query)
            # extract uuids
            selUuids = [item['mdf_uuid'] for item in mdf_data.mdf_def]
            del mdf_data

            # get parents uuid
            uuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_parents']]
            # get index of selfects
            indexes = [i for i, v in enumerate(uuids) if v in selUuids]
            del selUuids
        # end if

        # find parent object to be returned
        for index in indexes:
            # check if it is a valid index
            if index  in range(len(self.mdf_def['mdf_parents'])):
                # get child uuid
                uuid = self.mdf_def['mdf_parents'][index]['mdf_uuid']
                # get object from memory
                parent = mdf.load(uuid)
                # if valid object, insert it in output values
                if parent:
                    parents += parent
                # end if
            # end if
        # end for
        return parents
    # end def getParent
    
    #
    def addChild(self,prop,child=None,pos=None):
        '''
        create a <prop> child property if not already present
        append child object to the property or insert it in the specified position pos

        :param prop: (string) child property to be create and/or populated
        :param child: (string or mdfObj) child to be inserted under child prop
        #           Optional. If left empty, no object is linked, only the
        #           child property placemark is added to the current object
        #           If an mdf object is passed, it is inserted in the child property list
        #           If a uuid is passed, it retrieves the mdf object.
        :param pos: (numeric) position in which the child needs to be inserted.
        #           Optional. Default: end+1
        #           Value is constrained to values from 0 to the number of children under this property
        :return: (mdfObj) returns the object itself
        '''

        # check if prop is a string
        if isinstance(prop,str):
            raise Exception('mdfObj:addChild - invalid prop. It should be a string')
        #end if

        # check if we need to create the child property or not
        if (prop not in self.mdf_def['mdf_children']['mdf_fields']):
            # we need to create the new property
            # append at the end of the list
            self.mdf_def['mdf_children']['mdf_fields'].append(prop)
            self.mdf_def['mdf_children']['mdf_types'].append('')
            self.mdf_def['mdf_children'][prop] = []
        # end if
        #
        # find the index
        ip = self.mdf_def['mdf_children']['mdf_fields'].index(prop)
        #
        # check if we have the object to insert or not
        if isinstance(child,mdfObj) or isinstance(child,str):

            # we got child to insert
            # let's check if have position too or not and if we do let's check if it is valid
            if pos is None:
                # we got only the child
                # no position, default to end
                # nothing to do
                pass
            # check if user asked to insert at the end
            elif isinstance(pos,int) and pos == len(self.mdf_def['mdf_children'][prop]):
                pos = None
            # we got position, extract it and check it
            elif not isinstance(pos,int) \
                    or pos not in range(len(self.mdf_def['mdf_children'][prop])):
                raise Exception('mdfObj:addChild - Invalid position (' + str(pos) + ')')
            # end if

            # get child uuid and object
            uChild, oChild = mdf.getUuidAndObject(child)

            # prepare item for insertion
            item = {
                'mdf_uuid': oChild.uuid,
                'mdf_type': oChild.type,
                'mdf_file': oChild.getMFN(False)
                }

            # check if it is the first element
            if prop in self.mdf_def['mdf_children'] \
                    or not self.mdf_def['mdf_children']['mdf_types'](ip) \
                    or len(self.mdf_def['mdf_children'][prop]) == 0:
                # insert type of new child
                self.mdf_def['mdf_children']['mdf_types'][ip] = oChild.type
                # insert new child in new property
                self.mdf_def['mdf_children'][prop] = [item]
            else:
                # check if uuid is already in list
                uuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_children'][prop]]
                if uChild in uuids:
                    raise Exception('mdfObj:addChild - Object with uuid ' + uChild + ' already inserted')
                #end if

                # check if type matches the one already present
                if self.mdf_def['mdf_children']['mdf_types'][ip] == oChild.type:
                    raise Exception( \
                        'mdfObj:addChild - Invalid type ' + \
                        oChild.type + \
                        '. Children under ' + \
                        prop + \
                        ' are of type ' + \
                        self.mdf_def['mdf_children']['mdf_types'][ip])
                #end if


                # we are cleared to insert in position
                if pos is not None:
                    # insert in the list at the right position
                    self.mdf_def['mdf_children'][prop].insert(item, pos)
                else:
                    # append at the end
                    self.mdf_def['mdf_children'][prop].append(item)
                # end if/else
            # end if/else
        #end if
        return self
    # end def addChild

    #
    def rmChild(self, prop, child=None):
        '''
        remove specific child or all children under prop
        :param prop: (string) name of the child property
        :param child: (string or mdfobj) child to be removed. Optional
                   if no child is provided, all the children under prop will
                   be removed
        :return: (mdfObj) the object itself
        '''

        # check if prop exists
        if prop not in self.mdf_def['mdf_children'].keys() \
                or prop not in self.mdf_def['mdf_children']['mdf_fields']:
            raise Exception('mdfself:rmChild - Invalid prop name or selfect corrupted')
        # end if
        ip = self.mdf_def['mdf_metadata']['mdf_children']['mdf_fields'].find(prop)
    
        # check if we got child or we need to remove everything
        if isinstance(child,mdfObj) or isinstance(child,str):
            # single child to be removed
            #
            # get uuid from child
            [uChild, oChild] = mdf.getUAO(child)
            #
            # find child in list
            uuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_children'][prop]]
            pos = uuids.index(uChild)
            if not pos:
               raise Exception('mdfself:rmChild - Child uuid not found in children property.')
            # end if
            #
            # remove child from all the lists
            # remove requested child from property list
            self.mdf_def['mdf_children'][prop].pop(pos)

        else:
            # all children under prop need to be removed
            # reset property
            # remove all the links and leave property empty
            self.mdf_def['mdf_children'][prop] = []
        # end if

        # check if the list is now empty
        if len(self.mdf_def['mdf_children'][prop]) == 0:
            # remove property
            self.mdf_def['mdf_children']['mdf_fields'].remove(prop)
            # remove property type
            self.mdf_def['mdf_children']['mdf_types'].pop(ip)
            # reset property type, remove structure
            self.mdf_def['mdf_children'].remove(prop)
        # end if

        return self
    # end def rmChild

    #
    def getChild(obj, prop, selector):
        '''
        return the object child of type prop according to the selector
        :param prop: (string) children property where we are looking for our child
        :param selector: value used to select requested child
              options
              * numeric: index of the child within the property array of
                         objects
              * string: uuid of the child
              * struct: query structure to find child
        :return: (mdfObj) child(ren) requested
        '''

        # check if children property exists and is valid
        if prop not in obj.mdf_def['mdf_children']['mdf_fields']:
            # invalid child property requested
            raise Exception('mdfself:getChild - Child property not found.')
        # end if

        # initialize index child object
        indexes = []
        # find which child needs to be returned
        if isinstance(selector,int):
            # use selector a child index
            indexes.append(selector-1)

        elif isinstance(selector,str):
            # selector is a string, we assume it is the child uuid
            # find index of the object with this uuid
            indexes += [item['mdf_uuid'] for item in obj.mdf_def['mdf_children'][prop]].index(selector)


        elif isinstance(selector,dict):
            # selector is astruct, we pass it to the query method and see what
            # we get back

            # now we are ready to build the json query
            query = mdfDB.prepQuery(selector)
            # retrieve database object
            odb = mdfDB.getInstance()
            # runs query and hopes for the best
            mdf_data = odb.find(query)
            # extract uuids
            selUuids = [item['mdf_uuid'] for item in mdf_data['mdf_def']]
            del mdf_data

            # get uuids of the children
            uuids = [item['mdf_uuid'] for item in obj.mdf_def['mdf_children'][prop]]
            # get index of objects
            indexes =  [i for i, v in enumerate(uuids) if v in selUuids]
            del selUuids
        # end if

        # find child object to be returned
        children = []
        for index in indexes:
            # check if it is a valide index
            if index in range(len(obj.mdf_def['mdf_children'][prop])):
                # get child uuid
                uuid = obj.mdf_def['mdf_children'][prop][index]['mdf_uuid']
                # get object from memory
                child = mdfObj.load(uuid);
                # if valid object, insert it in output values
                if child:
                    children.append(child)
                # end if
            # end if
        # end for
        return children
    # end function

    #
    def addLink(self,prop,link=None,dir='b',pos=None):
        '''
        insert link object under the link property requested at position specified
        :param prop: (string) link property to be create and/or populated
        :param link: (string or mdfObj) link object to be inserted under link prop
                     Optional. If left empty, no object is created, only the
                     link property placemark
        :param dir: link directionality: uni(directional) or bi(directional)
                    indicates if the link is uni or bi directional.
                    Default: bidirectional
        :param pos: (numeric) position in which the link needs to be inserted.
                    Optional. Default: None, aka append at the end
                    Value is contrained to values from 1 to end+1 of the index
                    of the current length
        :return: (mdfObj) the object itself
        '''

        # check if prop is a string
        if not isinstance(prop,str):
            raise Exception('mdfObj:addChild - invalid prop. It should be a string')
        # end if

        # check if links structure is present or needs to be created
        # done for backward compatibility
        if not 'mdf_links' in self.mdf_def.keys():
            self.mdf_def['mdf_links'] = {}
        # end if
        if not 'mdf_fields' in self.mdf_def['mdf_links']:
            self.mdf_def['mdf_links']['mdf_fields'] = {}
        # end if
        if not 'mdf_types' in self.mdf_def['mdf_links']:
            self.mdf_def['mdf_links']['mdf_types'] = {}
        # end if
        if not 'mdf_directions' in self.mdf_def['mdf_links']:
            self.mdf_def['mdf_links']['mdf_directions'] = {}
        # end if

        # check if we need to create prop
        if not prop in self.mdf_def['mdf_links']['mdf_fields']:
            # we need to create the new property
            # append at the end of the list
            self.mdf_def['mdf_links']['mdf_fields'].append(prop)
            self.mdf_def['mdf_links']['mdf_types'].append('')
            self.mdf_def['mdf_links']['mdf_directions'].append('')
            self.mdf_def['mdf_links'][prop] = [];
        # end if

        # find the index
        ip = self.mdf_def['mdf_links']['mdf_fields'].index(prop)
        if ~ip:
            raise Exception('mdfObj:addLinks - Invalid link property.')
        # end if

        # check if we have the object to insert or not
        # input argument: self, prop, link, dir, pos
        if isinstance(link,mdfObj) or isinstance(link,str):
            # we got link to insert
            # let's check if we have directionality
            # encode directionality
            # u[ni[directional]] = u
            # b[i[directionl]] = b
            dir = dir[0].lower()
            dir = dir if dir in ['u', 'b'] else 'b'

            # let's check if have position too or not
            if pos is None:
                # we got only the child
                # no position, default to end
                pass
            # check if user asked to insert at the end
            elif isinstance(pos, int) and pos == len(self.mdf_def['mdf_links'][prop]):
                pos = None
            # we got position, extract it and check it
            elif not isinstance(pos, int) \
                    or pos not in range(len(self.mdf_def['mdf_links'][prop])):
                raise Exception('mdfObj:addChild - Invalid position (' + str(pos) + ')')
            # end if

            # get link uuid and object
            [uLink, oLink] = mdf.getUAO(link)

            # prepare link item for insertion
            item = {
                'mdf_uuid', oLink.uuid,
                'mdf_type', oLink.type,
                'mdf_direction', dir,
                'mdf_file', oLink.getMFN(False)
            }

            # check if it is the first element
            if not prop in self.mdf_def['mdf_links'] \
                    or self.mdf_def['mdf_links']['mdf_types'][ip] \
                    or self.mdf_def['mdf_links']['mdf_directions'][ip] \
                    or len(self.mdf_def['mdf_links'][prop]) == 0:
                # insert type of new link
                self.mdf_def['mdf_links']['mdf_types'][ip] = oLink.type;
                # insert direction of new link
                self.mdf_def['mdf_links']['mdf_directions'][ip] = dir;
                # insert new link in new property
                self.mdf_def['mdf_links'][prop].append(item);
            else:
                # check if uuid is already in list
                if uLink in [item['mdf_uuid'] for item in self.mdf_def['mdf_links'][prop]]:
                    raise Exception('mdfObj:addLink - Object with uuid ' + uLink + ' already inserted')
            # end if

            # check if type matches the one already present
            if self.mdf_def['mdf_links']['mdf_types'][ip] != oLink.type:
                raise Exception('mdfObj:addLink - Invalid type ' + oLink.type  + '. Link under '  + prop + ' are of type ' + self.mdf_def['mdf_links']['mdf_types'][ip])
            # end if

            # we are cleared to insert in position
            if pos is not None:
                # insert in the list at the right position
                self.mdf_def['mdf_links'][prop].insert(item, pos)
            else:
                # append at the end
                self.mdf_def['mdf_links'][prop].append(item)
            # end if/else
        # end if/else
        return self
    # end addLink

    #
    def rmLink(self, prop, link=None):
        '''
        remove specific link or all links under prop
        :param prop: (string) name of the link property
        :param link: (string or mdfobj) uuid of the object or object reference to be removed.
                     from the link property. Optional
                     if no link is provided, all the links under prop will
                     be removed
        :return: (mdfObj) the object itself
        '''

        # check if prop is a string
        if not isinstance(prop,str):
            raise Exception('mdfObj:addChild - invalid prop. It should be a string')
        # end if

        # check if prop exists
        ip = self.mdf_def['mdf_links']['mdf_fields'].index(prop)
        if not prop in self.mdf_def['mdf_links'] or not ip:
            raise Exception('mdfself:rmLink - Invalid prop name or selfect corrupted')
        # end if
    
        # check if we got link or we need to remove everything
        if link:
            # single link to be removed
            #
            # get link uuid an dselfect
            [uLink, oLink] = mdf.getUuidAndObject(link)
            #
            # extract uuids
            uuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_links'][prop]]
            # find link in list
            pos = uuids.index(uLink)
            if not pos:
               raise Exception('mdfself:rmLink - Link uuid not found in link property {:s}.'.format(prop))
            # end if
            # remove link from all the lists
            self.mdf_def['mdf_links'][prop].pop(pos)
        else:
            # r:eset property
            self.mdf_def['mdf_links'][prop] = []
        # end if
        #
        # remove type and directionality if necessary
        if len(self.mdf_def['mdf_links'][prop]) == 0:
            # remove property
            self.mdf_def['mdf_links']['mdf_fields'].remove(prop)
            # remove property type
            self.mdf_def['mdf_links']['mdf_types'].pop(ip)
            # reset property type, remove structure
            self.mdf_def['mdf_links'].remove(prop)
        # end if
    # end def rmLink

    #
    def getMetadataFileName(self,filtered = True):
        '''
        returns the filename containing the metadata properties for this selfect
        false if not defined. Filtered argument indicates if the path should
        returned as it is or needs to be filtered with constants, aka
        substitute any costant found in it.

        :param filtered: request that the file name is a full path where
                         configuration constants have been replaced with matching values
                         Optional. Default: true
                         if set to False, it returns the string as it is saved in the object
        :return: (string) metadata file name if indata collection is "mixed"
        '''

        # initialize output
        mfn = False;

        # get configuration objbect
        oconf = mdfConf.getInstance()

        # check if this data collection uses yaml files
        if oconf.getCollectionYaml():
            # check if metadata file name is defined
            if 'mdf_metadata' in self.mdf_def['mdf_files'].keys() \
                    and self.mdf_def['mdf_files']['mdf_metadata'] \
                    and isinstance(self.mdf_def['mdf_files']['mdf_metadata'],str):
                # exists a file name for metadata
                mfn = self.mdf_def['mdf_files']['mdf_metadata']

            elif 'mdf_base' in self.mdf_def['mdf_files']['mdf_base'] \
                    and self.mdf_def['mdf_files']['mdf_base']:
                # no metadata file name yet, builds it
                # use basename to build data file name
                mfn = self.mdf_def['mdf_files']['mdf_base'] + '.md.yml'
                # save the file name
                self.mdf_def['mdf_files']['mdf_metadata'] = mfn
            #end if/elif

            # filters if needed
            if filtered:
                mfn = mdfConf.sfilter(mfn)
            #end if
        else:
            # we are not using yaml file
            # set the field to empty
            self.mdf_def['mdf_files']['mdf_metadata'] = ''
        # end if/else

        return mfn
    #end def getMetadataFileName

    #
    def getMFN(self,filtered = True):
        '''
        Shortcut to getMetadataFileName.
        Please refer to mdfObj.getMetadataFileName function for help
        :param filtered: (boolean) True or False
        :return: (string) file name
        '''

        # return output from getMetadataFileName
        return self.getMetadataFileName(filtered)
    #end def getMFN

    #
    def getDataFileName(self,filtered = True):
        '''
        returns the filename containing the data properties for this object
        false if not defined. Filtered argument indicates if the path should
        returned as it is or needs to be filtered with constants, aka
        substitute any costant found in it.

        :param filtered: request that the file name is a full path where
                         configuration constants have been replaced with matching values
                         Optional. Default: true
                         if set to False, it returns the string as it is saved in the object
        :return: (string) data file name
        '''

        # initialize output
        dfn = False;

        # get conf singleton
        oconf = mdfConf.getInstance();

        if oconf.isCollectionData('MATFILE'):
            # check if we have the dat afile name already set
            if 'mdf_data' in self.mdf_def['mdf_files'].keys() \
                    and self.mdf_def['mdf_files']['mdf_data'] \
                    and isinstance(self.mdf_def['mdf_files']['mdf_metadata'], str):
                # exists a file name for data
                dfn = self.mdf_def['mdf_files']['mdf_data'];
            elif 'mdf_base' in self.mdf_def['mdf_files'] \
                    and self.mdf_def['mdf_files']['mdf_base']:
                # no data file name yet. builds it
                # use basename to build data file name
                dfn = self.mdf_def['mdf_files']['mdf_base'] + '.data.mat'
                # save the file name
                self.mdf_def['mdf_files']['mdf_data'] = dfn
            # end if/elif

            # filters if needed
            if filtered:
                dfn = mdfConf.sfilter(dfn)
            # end if
        else:
            # we store data in the db, not mat file
            # just to be sure, we set the field to empty
            self.mdf_def['mdf_files']['mdf_data'] = ''
        # end if/else

        return dfn
    # end function

    #
    def getDFN(self,filtered):
        '''
        Shortcut to getDataFileName
        Please refer to mdfObj.getDataFileName function for help
        :param filtered: (boolean) true or false
        :return: (string) data file name
        '''

        # return output from getDataFileName method
        return self.getDataFileName(filtered)
    # end function

    #
    def getFiles(self,filtered = True):
        '''
        return files settings for the object
        Filtered argument indicates if the path should
        returned as it is or needs to be filtered with constants, aka
        substitute any costant found in it.
        This function returns empty if data collection is database only

        :param filtered: request that the file name is a full path where
                         configuration constants have been replaced with matching values
                         Optional. Default: true
                         if set to False, it returns the string as it is saved in the object
        :return: (dictionary) a dictionary with 3 fields for base name, data and metadata file name
                 base = base path, if used
                 data = path for .mat data file
                 metadata = path for .yaml metadata file
        '''

        # get conf singleton
        oconf = mdfConf.getInstance()

        # prepare output
        files = {
            'data' : self.getDataFileName(filtered),
            'metadata' : self.getMetadataFileName(filtered),
            'base' : ''
        }
        if oconf.isCollectionData('MATFILE') or oconf.getCollectionYaml():
            if filtered:
                files['base'] = mdfConf.sfilter(self.mdf_def['mdf_files']['mdf_base'])
            else:
                files['base'] = self.mdf_def['mdf_files']['mdf_base']
            # end if
        # end if

        return files
    # end def getFiles

    #
    def setFiles(self,indata,reset=False):
        '''
        set files where data is going to be saved

        :param indata:
                (string) user has specified the base path used to
                build data and metadata file names
                (struct) user has passed a structure in input.
                It has to contain the following fields:
                * base,
                * data,
                * metadata
                In this case base is not used, but saved anyway.
                Data is the file name for the .mat data file,
                while metadata is the file name of the yaml metadata file
        :param reset:
                (boolean) if indata is a string, indicate that the file
                names should be cleared before performing the assignment.
                it is ignored owtherwise

        :return: (dictionary) with all the files names
        '''

        if isinstance(indata,str):
            # we got base path

            # check if we need to clear previous names
            if reset:
                self.resetFiles()

            # set base
            self.mdf_def['mdf_files']['mdf_base'] = indata

        elif isinstance(indata,dict):
            # we got whole of it: base, data and metadata
            self.mdf_def['mdf_files']['mdf_base'] = '' \
                if not 'base' in indata.keys() \
                else indata['base']
            self.mdf_def['mdf_files']['mdf_data'] = indata['data']
            self.mdf_def['mdf_files']['mdf_metadata'] = indata['metadata']

        else:
            # wrong input, return false
            return False
        # end if

        # return all settings
        return self.getFiles()
    # end def setFiles

    #
    def getSize(self,details=False):
        '''
        return the memory size of the current object
        :param details: (logical) if true, the function will return the detailed
                memory consumption. Please see OUTPUT
        :return: (integer or struct). if details = false, it returns the total
            memory footprint of this object instance.
            if details = true, it returns a structure with the following
            fields:
            * total    : total memory used by the object
            * data     : memory used by the data section of the object
            * metadata : memory used by the metadata section of the object
        '''
        # return the approximate size of the object
        if not details:
            # total size
            return sys.getsizeof(self)
        else:
            res = {
                'total' : sys.getsizeof(self),
                'metadata' : sys.getsizeof(self.mdf_metadata),
                'data' : 0
            }
            for dprop in self.mdf_def['mdf_data']['mdf_fields']:
                if self.status['loaded']['data'][dprop]:
                    res['data'] += sys.getsizeof(self.mdf_data[dprop])
                else:
                    res['data'] += self.mdf_def['mdf_data'][dprop]['mdf_mem']
                #end if/else
            #end for
            return res
        # end if/else
    # end def getSize


    def getUuids(self,group,property='all',format='uuids'):
        '''
        this function returns the list of uuids of the selfect in the
        specified group of relationship: parents, children, links
        this function uses only local information. it will not load any of
        the selfect specified in the relationship

        :param group: (string) group for which we would like to uuids
                   There is no default for this
                   Possible values:
                   * children,child,c
                       returns uuids for all the children selfects
                   * links,l
                       returns uuids for all the selfects linked to the this one
                   * unidirectionallinks, unilinks, ulinks, ul
                       returns uuids for all the selfects unidirectionally
                       linked from the current one
                   * bidirectionallinks, bilinks, blinks, bl
                       returns uuids for all the selfects bidirectionally
                       linked to the current one
                   * parents, p
                       returns uuids of all the parents
        :param property: (string) name of the property within the group that we
                       would like to retrieve.
                       If not specified, will return all properties within the
                       group
                       Not used for parents
        :param format: (string) type of output
                    Possible values:
                    * uuids = output is a list containing uuids. This is the default
                    * UuidWithPropName = list of dictionaries with uuid and property
                                         associated
                    * UuidWithPropNameNoEmpty = same as previous but empty properties are removed

        :return: (list of strings or list of dicts)
                     list of uuids requested or
                      list of dicts with uuids and property under which they can be accessed
        '''

        # initialize uuid list and property list
        ul = [];
        pl = [];

        # check input parameters
        if group in ['children','child','c']:
            fg = 'c';
        elif group in ['links', 'l']:
            fg = 'l';
        elif group in ['unidirectionallinks', 'unilinks', 'ulinks', 'ul']:
            fg = 'ul';
        elif group in ['bidirectionalinks', 'bilinks', 'blinks', 'bl']:
            fg = 'bl';
        elif group in ['parents', 'p']:
            fg = 'p';
        else:
            # error
            raise Exception('mdfObj:getUuids - Invalid group option.')
        # end switch


        # check input parameters
        if fg in ['c']:
            # list the children properties that needs to be used
            properties = []
            if property in self.mdf_def['mdf_children'].keys():
                properties = [property]
            elif property == 'all':
                properties = self.mdf_def['mdf_children']['mdf_fields']
            #end if

            # cycle on all the properties requested
            for prop in properties:
                # set lists for current property
                ult,plt = zip(*[[item['mdf_uuid'],prop] for item in self.mdf_def['mdf_children'][prop]])
                # append values in complete list
                ul += ult
                pl += plt
            # end for

        elif fg in ['l', 'ul', 'bl']:
            # initialize the directionality list
            dl = []
            # list links properties that have been requested
            properties = []
            if property in self.mdf_def['mdf_links'].keys():
                properties = [property]
            elif property == 'all':
                properties = self.mdf_def['mdf_links']['mdf_fields']
            #end if

            # cycle on all the properties
            for prop in self.mdf_def['mdf_links']['mdf_fields']:
                # extract array of references
                ult, plt, dlt = zip(*[[item['mdf_uuid'],prop,item['mdf_direction']] for item in self.mdf_def['mdf_links'][property]])
                # append values in complete list
                ul += ult
                pl += plt
                dl += dlt
            # end for

            # filters accordingly to the request
            if fg in ['ul', 'bl']:
                # retains only the type of link requested
                [ul, pl, dl] = zip(*[item for item in zip(ul, pl, dl) if item[2] == fg[0]])
            # end if

        elif fg in ['p']:
            # extract array of references
            ul,pl = zip(*[[item['mdf_uuid'],'parent'] for item in self.mdf_def.mdf_parents])
        else:
            # error
            raise Exception( 'mdfself:getUuids - Invalid group option.')
        # end switch

        # prepare output according to format requested
        if format == 'UuidWithPropName':
            # initialize outdata
            return [ { 'uuid': item[0], 'prop': item[1]} for item in zip(ul,pl)]
        elif format == 'UuidWithPropNameNoEmpty':
            # initialize outdata
            return [ { 'uuid': item[0], 'prop': item[1]} for item in zip(ul,pl) if item[0]]
        else:
            # returns only uuids
            return ul
        # end if
    # end def getUuids

    #
    def setDataInfo(self,prop):
        '''
        update properties info in def structure for the field passed

        :param prop: (string) data property to be updated
        :return: (boolean) true if update was successful, false otherwise
        '''

        # check if data property is valid
        if not prop in self.data.keys():
            return False
        # end if

        # get info about the specific field
        propInfo = self.propInfo(prop)

        # check if info have changed,
        # if so, mark mdf_def changed
        if not prop in self.mdf_def['mdf_data'] \
                or self.mdf_def['mdf_data'][prop].mdf_class != propInfo['class'] \
                or self.mdf_def['mdf_data'][prop].mdf_size != propInfo['size'] \
                or self.mdf_def['mdf_data'][prop].mdf_mem != propInfo['mem']:
            self.mdf_status['changed']['data'][prop] = True
        # end if
        # set info in the _mdf_Def structure
        self.mdf_def['mdf_data'][prop] = { \
            'mdf_class': propInfo['class'], \
            'mdf_size': propInfo['size'], \
            'mdf_mem': propInfo['mem']}
        return True
    # end function

    #
    def dataLoad(self,dp):
        '''
        load data property dp from data source

        :param dp: (string) data property (aka field)
        :return: (integer) result from the operation
                -2: undefined error
                -1: error
                 0: property not existent
                 1: property already loaded
                 2: property loaded
                 (string) error message if needed
        '''

        res = 2
        message = ''

        # get mdfConf object handle
        oconf = mdfConf.getInstance()

        try:
            # check if the property exists
            if dp in self.mdf_status['loaded']['data']:
                res = 0
            elif self.mdf_status['loaded']['data'][dp]:
                res = 1
            else:
                # data property not loaded yet
                #
                if oconf.isCollectionData('MATFILE'):
                    # data is saved in matfile
                    #
                    # check if we have a file name for the data file
                    # if so, load just the property requested
                    dfn = self.getDataFileName()

                    if dfn and os.path.exists(dfn):
                        # ok we got a data file name
                        # open it with matfile class
                        dpo = hdf5storage.loadmat(dfn, variable_names=[dp])
                        # load the data property requested
                        self.mdf_data[dp] = dpo;
                        # updates def properties
                        self.setDataInfo(dp);
                        # marked as loaded
                        self.mdf_status['loaded']['data'][dp] = True

                elif oconf.isCollectionData('DATABASE'):
                    # database only mode
                    #
                    # object is not loaded yet
                    #
                    # retrieves database object
                    odb = mdfDB.getInstance()

                    # load  data property from db
                    mdf_data = [item for item in odb.find(
                        { "mdf_def.mdf_uuid" : self.uuid },
                        { dp : 1 })]
                    # transfer data to object
                    # load the data property requested
                    # find returns a list of dictionaries
                    # we know that there is only one document matching it
                    #
                    temp = numpy.ndarray(mdf_data[0][dp])
                    # check if we need to flip the cell array
                    ds = temp.shape()
                    if  self.mdf_def['mdf_data'][dp]['mdf_size'] == ds:
                        self.mdf_data['dp'] = temp
                    else:
                        raise Exception('mdfObj:dataLoad', 'Inconsistency in data size')
                    # end if/else
                else:
                    raise Exception('mdfObj:dataLoad', 'Unrecognized Data Collection')

                # updates def properties
                self.setDataInfo(dp)

                # marked as loaded
                self.mdf_status['loaded']['data'][dp] = True
                res = 2;
            #end if
        except Exception as e:
            res = -1
            message = ', '.join(e.args)
        #end try/except

        return res,message
    # end def dataLoad
    
    #
    @staticmethod
    def fileLoadInfo(file):
        '''
        loads mdfObj object from file
        it expects a file of type: .yml, .mat

        :param file: (string) file path of the file containing the data
        :return: dictionary with following keys if successful
          - mdf_version: file version
          - mdf_def: mdf object definition structure
          - mdf_metadata: mdf object metadata structure
          None otherwise
        '''

        # initialize output
        res = None;
    
        # check if input file is valid and exists
        if os.path.exists(file):
            # make sure that we catch any issue
            try:
                # extract filename and extension
                fn, fe = os.path.splitext(file)

                # decide how load it
                if fe in ['.yml']:
                    # we need to load a yaml file
                    res = yaml.load(file)
                elif fe in ['.mat', '.h5']:
                    # we have a mat or an h5 file
                    # load values through matfile function
                    temp1 = mat4py.loadmat(file)
                    # transfer what we need
                    res = {
                        'mdf_version' : temp1.mdf_version,
                        'mdf_def' : temp1.mdf_def,
                        'mdf_metadata' : temp1.mdf_metadata }
                #end if
            except:
                # error, cannot do anything
                # just in case we re-initialize the output
                res = None
            # end try/except
        # end if
        return res
    # end def fileLoadInfo

    @staticmethod
    def load(indata):
        '''
        load data and metadata from file or db and return an RF object fully populated

        :param indata: single string or structure with one of the following fields
           - uuid   : if this field is specified, loads the object defined by this uuid
                      uuid takes precedence over any other field
           - file   : if this field is defined, loads the object defined in the file itself
                      file takes precedence over everything other field, after uuid
           - <type> : object type. users can specify a condition for a specific metadata fields
                      each condition will be applied in AND with the others.
                      if there are multiple values for each conditions, each value with be applied in OR

                    If indata is a string, it will be converted to a structure internally and the
                    input value will be assigned to uuid and file
        :return: mdf object instance fully populated
        '''

        # check if we got a string in input
        if isinstance(indata,str):
            indata = {
                'uuid': indata,
                'file': indata,
                'json': indata}
        # end if

        # let's check if indata is a struct
        if ~isinstance(indata,dict):
            raise Exception('mdfObj.load: input data has to be a structure or a string')
        # end if

        # initialize temp mdf structure and output
        outdata = None
        mdf_data = None

        # retrieve handler to db and manage class
        odb = mdfDB.getInstance()
        om = mdfManage.getInstance()
        oconf = mdfConf.getInstance()

        collection_type = oconf.getCollectionData()

        # check if user specified the output that he / she wants
        mdf_output = 'object'
        mongo_projection = {"_id" : 0,  "mdf_def" : 1, "mdf_metadata" : 1 }
        if 'mdf_output' in indata.keys():
            if indata.mdf_output == 'uuid':
                mdf_output = 'uuid'
                mongo_projection = {"_id" : 0, "mdf_def.mdf_uuid": 1}
            elif indata.mdf_output == 'object':
                temp = 1
            else:
                raise Exception(
                    "mdfObj.load",
                    "Invalid output format requested")
            # end if
        # end if


        # let's check if we have uuid field
        if 'uuid' in indata.keys():
            # check if object is already loaded
            # retrieve handler
            outdata = om.get(indata['uuid'])
            if outdata:
                # object already loaded
                # return back the object in memory
                return outdata
            # end if

            # object is not loaded yet
            # try the db next
            mdf_data = odb.find(
                { "mdf_def.mdf_uuid" : indata['uuid'] },
                mongo_projection)

            if mdf_data is None and collection_type == 'M':
                # no luck through the db
                # trys file
                mdf_data = mdfObj.fileLoadInfo(indata['uuid'] + '_md.yml')
            # end if
        # end if

        # if mdf_data does not contains anything, next check if we have a file name
        # only if we are in mixed mode
        if mdf_data is None and 'file' in indata.keys() and collection_type == 'M':
            # check if the object has been loaded
            # trying to retrieve it by file name
            # retrieve handler, pass it back and return
            outdata = om.get(indata['file'])
            if outdata:
                # object already loaded
                # return back object in memory
                return outdata
            # end if

            # we could not retrieve the object by file name
            # try to load file
            mdf_data = mdfObj.fileLoadInfo(indata['file'])
            # check if we were successful to load the mdf data
            if mdf_data is None:
                # check if object has already been loaded by uuid
                outdata = om.get(mdf_data['mdf_def']['mdf_uuid'])
                if outdata:
                    # object already loaded
                    # return back object in memory
                    return outdata
                #end if
            # end if
        # end if

        # if mdf_data is still empty, next we check for json string
        if mdf_data and 'json' in indata.keys():
            # convert everything to a cell array
            if isinstance(indata.json, str):
                indata['json'] = [indata['json']]
            #end if

            # tries to convert json string to matlab structure
            # also checks if ther are all the fields needed
            try:
                mdf_data = [json.load(item) for item in indata['json']]
            except:
                # an error occured. returning empty handed
                return outdata;
            #end try/ catch
        #end if

        # if mdf_data still does not contains any info,
        # we check if there is a field named mdf_query, that contains a json
        # mongodb query
        if mdf_data is None and 'mdf_query' in indata.keys():
            # runs the query as it is
            mdf_data = odb.find(indata['mdf_query'],mongo_projection)
        # end if

        # next we check all the other fields and we use them to
        # build a query and send it to the db
        if mdf_data is None:
            tmp1 = copy.deepcopy(indata);
            # remove fields not needed
            tmp1.pop('uuid',None)
            tmp1.pop('file',None)
            tmp1.pop('json',None)
            tmp1.pop('mdf_query',None)
            if not tmp1:
                # now we are ready to build the json query
                tmp2 = mdfDB.prepQuery(tmp1)
                # runs query and hopes for the best
                mdf_data = odb.find(tmp2)
            # end if
        # end if

        # if we got here, we have not found the object that we are looking for
        # if mdf_data is not empty, we need to create it
        if mdf_data is not None:
            # here is the structure that mdf_data should have
            # mdf_data:
            #  - mdf_version: 1
            #  - mdf_metadata: metadata of the object
            #  - mdf_def: definition of the object
            #    - mdf_type: <object type>
            #    - mdf_uuid: <object uuid>
            #    - mdf_files: object files
            #      - mdf_base: base file name for metadata and data file names
            #      - mdf_data: .mat or .h5 file completed with data values
            #                 or struct with file name for each data property
            #      - mdf_metadata: .mat or .yml file with just mdf_def and mdf_metadata
            #    - mdf_data: data definition
            #      - mdf_fields: <dataProp1>, <dataProp2>, …  list of data properties
            #      - <dataProp1>:
            #        - mdf_size: <size1_dataProp1>, <size2_dataProp1> ...
            #        - mdf_mem:  <mem_dataProp1>
            #        - mdf_class: <ytpre_dataProp1>
            #      …
            #    - mdf_metadata: constrains or definition regarding metadata
            #                   still a work in progress
            #    - mdf_children:
            #      - mdf_fields: <child_1>, <child_2>, … list of child properties
            #      - <child_1>:
            #        -
            #          mdf_uuid: xxxx
            #          mdf_file: <file_path>
            #          mdf_type: <class type>
            #
            #    - mdf_parents:
            #      -
            #        mdf_uuid: xxxx
            #        mdf_file: <file_path>
            #        mdf_type: <class type>

            # initialize outdata
            outdata = []

            if mdf_output == 'object':

                # loop on all the objects found
                for cdata in mdf_data:

                    # check if the object has been already loaded
                    otemp1 = om.get(cdata['mdf_def']['mdf_uuid'])
                    if otemp1:
                        # object already loaded in memory
                        # use the one already loaded
                        outdata.append(otemp1)
                    else:

                        # create new object
                        otemp1 = mdfObj()

                        # populate it
                        # def
                        otemp1['mdf_def'] = cdata['mdf_def'];
                        # metadata
                        otemp1['metadata'] = cdata['mdf_metadata'];
                        # create place marks for data properties
                        for field in cdata['mdf_def']['mdf_data']['mdf_fields']:
                            otemp1['data'][field] = []
                            otemp1['status']['loaded']['data'][field] = 0
                            otemp1['status']['size']['data'][field] = 0
                        # end if

                        outdata.append(otemp1)
                    #end if
                    # register mdf object in memory structures
                    om.insert(otemp1['uuid'],otemp1.getMFN(),otemp1)
                # end for
            elif mdf_output == 'uuid':
                outdata = [item['mdf_def']['mdf_uuid'] for item in mdf_data]

            #end if

            # clear mdf data from memory
            del mdf_data
        # end if

        return outdata
    # end function load


# end class mdfObj

