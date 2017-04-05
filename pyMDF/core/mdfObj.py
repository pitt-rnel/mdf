#
# python implementation or mdfObj class
#
# by: Max Novelli
#     man8@pitt.edu
#

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
    def addParent(obj,parent):
        # function res = obj.addParent(parent)
        #
        # add parent to current object
        #
        # Input
        # - parent: (string) uuid of the parent object
        #           (mdfObj) parent object
        #
        #

        uParent, oParent = mdf.getUuidAndObject(parent)

        # structure of the mdf_parent array
        # - mdf_uuid
        # - mdf_file
        # - mdf_type

        # check if parent is already present
        # get parents uuid
        alreadyParent = False;
        if isinstance(obj.mdf_def['mdf_parents'],dict) \
                and not obj.mdf_def['mdf_parents'].keys():
            # get uuids for all parents
            pUuids = [item.['mdf_uuid'] for item in obj.mdf_def['mdf_parents']]
            # search for uuid
            alreadyParent = (uParent in pUuids)
        # end if

        # prepare parent item
        item = { \
            'mdf_uuid': uParent, \
            'mdf_file': oParent.getMFN(False), \
            'mdf_type': oParent.type }

        # insert parent if needed
        if not alreadyParent:
            if not isinstance(obj.mdf_def['mdf_parents'], dict) \
                    or not obj.mdf_def['mdf_parents'][0]:
                obj.mdf_def['mdf_parents'] = [item]
            else
                obj.mdf_def['mdf_parents'].append(item)
        # end if/else
        return 1
    #end def addParent

    #
    def rmParent(self,parent):
        # function res = self.rmParent(parent)
        #
        # remove object from parent list
        #
        # Input
        # - parent: (string) uuid of the parent selfect
        #           (mdfself) parent selfect
        #
        #

        # get uuid and selfect from argument passed
        [uParent, oParent] = mdf.getUuidAndObject(parent);
        if isinstance(oParent,mdfObj):
            raise MException('mdfself:rmParent - Invalid selfect or uuid ')
        # end if

        # structure of the mdf_parent array
        # - mdf_uuid
        # - mdf_file
        # - mdf_type

        # check if parent is already present
        # get parents uuid
        pUuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_parents']]
        # search for uuid
        iParent = pUuids.index(uParent)

        # remove parent if needed
        if iParent:
            del self.mdf_def['mdf_parents'](iParent)
        # end if

        return True
    # end rmParent

    #
    def getParent(self, selector=0):
        # function parent = self.getParent(selector)
        #
        # return the selfect parent according to the selector
        #
        # Input
        # - selector: value used to select requested parent
        #      options
        #      * numeric: index of the parent within the parents array of
        #                 selfects
        #      * string: uuid of the parent
        #      * struct: query structure to find parent
        #
        # Output
        # - parents: (mdfself) parent(s) requested
        #

        # initialize index child selfect
        indexes = []
        # find which parent needs to be returned
        if isinstance(selector, int):
            # use selector a parent index
            indexes.append(selector)

        elif isinstance(selector, str):
            # selector is a string, we assume it is the parent uuid
            # find index of the selfect with this uuid
            uuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_parents']]
            indexes.append(uuids.index(selector))

        elif isinstance(selector, dict):
            # selector is astruct, we pass it to the query method and see what
            # we get back

            # now we are ready to build the json query
            query = mdfDB.prepQuery(selector);
            # runs query and hopes for the best
            mdf_data = odb.find(query);
            # extract uuids
            selUuids = [item['mdf_uuid'] for item in mdf_data.mdf_def]
            del mdf_data

            # get parents uuid
            uuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_parents']]
            # get index of selfects
            indexes = [i for i, v in enumerate(uuids) if v in selUuids]
            del selUuids
        else:
            # invalid selector
            return False
        # end if

        # initialize output list
        parents = {}
        # find parent selfect to be returned
        for index in indexes:
            # check if it is a valide index
            if index >= 0 & & index < len(self.mdf_def['mdf_parents']):
                # get child uuid
                uuid = self.mdf_def['mdf_parents'][index]['mdf_uuid']
                # get selfect from memory
                parent = mdf.load(uuid);
                # if valid selfect, insert it in output values
                if ~isempty(parent)
                    parents.append(parent)
                # end if
            # end if
        # end for
    # end def getParent
    
    #
    def addChild(self,prop,child=None,pos=None):
        # def res = obj.addChild(prop[,child[,pos]])
        #
        # create a <prop> child property if not already present
        # append child object to the property or insert it in the specified position pos
        #
        # input
        # - prop  = (string) child property to be create and/or populated
        # - child = (string or mdfObj) child to be inserted under child prop
        #           Optional. If left empty, no object is created, only the
        #           child property placemark
        #           If an mdfObj is passed, it extracts uuid automatically and
        #           if needed, it insert in mdfManage
        #           If a uuid is passed, it retrieves the mdfObj from mdfManage
        # - pos   = (numeric) position in which the child needs to be inserted.
        #           Optional. Default: end+1
        #           Value is contrained to values from 1 to end+1 of the index
        #           of the current length
        #

        # check if prop is a string
        if type(prop) != 'char':
            raise Exception('mdfObj:addChild - invalid prop. It should be a string')
        #end if

        # check if we need to create the child property or not
        if (not prop in self.mdf_def['mdf_children']['mdf_fields']):
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
        if child is None:
            # no other arguments, we are done
            return self;
        #end if

        # we got child to insert
        # let's check if have position too or not
        if pos is None:
            # we got only the child
            # no position, default to end
            pos = 1
            if prop in self.mdf_def['mdf_children']:
                pos = len(self.mdf_def['mdf_children']['prop'])
            # end if
        # we got position, extract it and check it
        elif not isinstance(pos,int) \
                or pos < 1 \
                or pos > len(self.mdf_def['mdf_children'][prop]):
            raise Exception('mdfObj:addChild - Invalid position (' + str(pos) + ')')
        # end if

        # get child uuid and object
        uChild, oChild = mdf.getUAO(child)

        # check if it is the first element
        if prop in self.mdf_def['mdf_children'] \
                or not self.mdf_def['mdf_children']['mdf_types'](ip) \
                or len(self.mdf_def['mdf_children'][prop]) == 0:
            # insert type of new child
            self.mdf_def['mdf_children']['mdf_types'][ip] = oChild.type
            # insert new child in new property
            self.mdf_def['mdf_children'][prop] = [{ \
                    'mdf_uuid': oChild.uuid, \
                    'mdf_type': oChild.type, \
                    'mdf_file': oChild.getMFN(False) }]
        else:
            # check if uuid is already in list
            uuids = [self.mdf_def['mdf_children'][key]['mdf_uuid'] for key in self.mdf_def['mdf_children'] if not 'mdf_' in key];
            i = uuids.index(uChild)
            if i:
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

            # prepare item for insertion
            item = {
                'mdf_uuid': oChild.uuid,
                'mdf_type': oChild.type,
                'mdf_file': oChild.getMFN(False)
                }

            # we are cleared to insert in position
            if pos <= len(self.mdf_def['mdf_children'][prop]):
                # insert in the list at the right position
                self.mdf_def['mdf_children'][prop].insert(item, pos-1 )
            else:
                # append at the end
                self.mdf_def['mdf_children'][prop].append(item)
            # end if/else
        # end if/else
    # end def addChild

    #
    def rmChild(self, prop, child=None):
        # function res = self.rmChild(self, prop, child)
        #
        # remove specific child or all children under prop
        #
        # input:
        # - prop  : (string) name of the child property
        # - child : (string or mdfself) child to be removed. Optional
        #           if no child is provided, all the children under prop will
        #           be removed
        #
    
        res = self;
    
        # check if prop exists
        ip = self.mdf_def['mdf_children']['mdf_fields'].index(prop)
        if not prop in self.mdf_def['mdf_children'].keys() or not ip:
            raise Exception('mdfself:rmChild - Invalid prop name or selfect corrupted')
        # end if
    
        # check if we got child or we need to remove everything
        if child
            # single child to be removed
            #
            # get uuid from child
            [uChild, oChild] = mdf.getUAO(child)
            #
            # find child in list
            uuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_children']]
            pos = uuids.index(uChild)
            if not pos:
               raised Exception('mdfself:rmChild - Child uuid not found in children property.')
            # end if
            #
            # remove child from all the lists
            # remove requested child from property list
            del self.mdf_def['mdf_children'][prop][pos]
            # check if the list is now empty
            if len(self.mdf_def['mdf_children'][prop]) == 0:
                # reset property type
                self.mdf_def['mdf_children']['mdf_types'][ip] = None
                # reset property type, remove structure
                self.mdf_def['mdf_children'][prop] = None
            3 end if

        else:
            # all children under prop need to be removed
            # reset property
            # remove all the links and leave property empty
            self.mdf_def['mdf_children'][prop] = None
            # reset property type
            self.mdf_def['mdf_children']['mdf_type'][ip] = None
        # end if
    # end def rmChild

    #
    def getChild(obj, prop, selector):
        # function child = obj.getChild(prop, selector)
        #
        # return the object child of type prop accordign to the selector
        #
        # Input
        # - prop: (string) children property where we are looking for our child
        # - selector: value used to select requested child
        #      options
        #      * numeric: index of the child within the property array of
        #                 objects
        #      * string: uuid of the child
        #      * struct: query structure to find child
        #
        # Output
        # - children: (mdfObj) child(ren) requested
        #

        # check if children property exists and is valid
        if not prop in obj.mdf_def['mdf_children']['mdf_fields']:
            # invalid child property requested
            return children
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
            uuids = [item['mdf_uuid'] for item in obj.mdf_def['mdf_children'][prop]]
            indexes.append(uuids.index(selector))

        elif isinstance(selector,dict):
            # selctor is astruct, we pass it to the query method and see what
            # we get back

            # now we are ready to build the json query
            query = mdfDB.prepQuery(selector)
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
        else:
            return False
        # end if

        # find child object to be returned
        children = []
        for index in indexes:
            # check if it is a valide index
            if index >= 0 && index < len(obj.mdf_def['mdf_children'][prop]):
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
        # res = self.addLink(prop,link,dir,pos)
        #
        # insert link object under the link property requested at position specified
        #
        # input
        # - prop  = (string) child property to be create and/or populated
        # - link  = (string or mdfObj) link object to be inserted under link prop
        #           Optional. If left empty, no object is created, only the
        #            link property placemark
        #           If an mdfObj is passed, it extracts uuid automatically and
        #           if needed, it insert in mdfManage
        #           If a uuid is passed, it retrieves the mdfObj from mdfManage
        # - dir   = link directionality: uni(directional) or bi(directional)
        #           indicates if the link is uni or bi directional.
        # - pos   = (numeric) position in which the link needs to be inserted.
        #           Optional. Default: end+1
        #           Value is contrained to values from 1 to end+1 of the index
        #           of the current length

        # return object
        res = self;

        # check if prop is a string
        if type(prop) != 'char':
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
        if not prop in self.mdf_def.mdf_links.mdf_fields:
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
        if not link:
            # done
            return;
        # end if

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
            pos = 1
            if prop in self.mdf_def['mdf_links']:
                pos = len(self.mdf_def['mdf_links']['prop'])
            # end if
        # we got position, extract it and check it
        elif not isinstance(pos,int) \
                or pos < 1 \
                or pos > len(self.mdf_def['mdf_links'][prop]):
            raise Exception('mdfObj:addChild - Invalid position (' + str(pos) + ')')
        # end if

        # get link uuid and object
        [uLink, oLink] = mdf.getUAO(link)

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
            self.mdf_def['mdf_links'][prop] = [{ \
                'mdf_uuid', oLink.uuid, \
                'mdf_type', oLink.type, \
                'mdf_direction', dir, \
                'mdf_file', oLink.getMFN(False) }];
        else:
            # check if uuid is already in list
            uuids = [self.mdf_def['mdf_links'][key]['mdf_uuid'] for key in self.mdf_def['mdf_children'] if not 'mdf_' in key];
            i = uuids.index(uLink)
            if i:
                raise Exception('mdfObj:addLink - Object with uuid ' + uLink + ' already inserted')
            # end if

            # check if type matches the one already present
            if self.mdf_def['mdf_links']['mdf_types'][ip] != oLink.type:
                raise Exception('mdfObj:addLink - Invalid type ' + oLink.type  + '. Link under '  + prop + ' are of type ' + self.mdf_def['mdf_links']['mdf_types'][ip])
            # end if

            # prepare item to be inserted
            item =  { \
                 'mdf_uuid': oLink.uuid, \
                 'mdf_type': oLink.type, \
                 'mdf_direction': dir, \
                 'mdf_file': oLink.getMFN(False) }

            # we are cleared to insert in position
            if pos <= len(self.mdf_def['mdf_links'][prop]):
                # insert in the list at the right position
                self.mdf_def['mdf_links'][prop].insert(item, pos - 1)
            else:
                # append at the end
                self.mdf_def['mdf_links'][prop].append(item)
            # end if/else
        # end if/else
    # end addLink

    #
    def rmLink(self, prop, link=None):
        # function res = self.rmLink(self, prop, link)
        #
        # remove specific link or all links under prop
        #
        # input:
        # - prop  : (string) name of the link property
        # - link : (string or mdfself) link to be removed. Optional
        #           if no link is provided, all the links under prop will
        #           be removed
        #
    
        res = self;
    
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
            [uLink, oLink] = mdf.getUAO(link)
            #
            # extract uuids
            uuids = [item['mdf_uuid'] for item in self.mdf_def['mdf_links'][prop]]
            # find link in list
            pos = uuids.index(uLink)
            if not pos:
               raise Exception('mdfself:rmLink - Link uuid not found in links property.')
            # end if
            # remove link from all the lists
            del self.mdf_def['mdf_links'][prop][pos]
        else
            # reset property
            del self.mdf_def['mdf_links'][prop]
        # end if
        #
        # remove type and directionality if necessary
        if len(self.mdf_def['mdf_links'][prop]) == 0:
            del self.mdf_def['mdf_links']['mdf_types'][ip]
            del self.mdf_def['mdf_links']['mdf_directions'][ip]
            del self.mdf_def['mdf_links'][prop]
        # end if
    # end def rmLink

    #
    def getMetadataFileName(self,filtered = True):
        # mfn = obj.getMetadataFileName(filtered)
        #
        # returns the filename containing the metadata properties for this selfect
        # false if not defined. Filtered argument indicates if the path should
        # returned as it is or needs to be filtered with constants, aka
        # substitute any costant found in it.
        #
        # INPUT
        # - filtered : (boolean) OPTIONAL. Default: true.
        #

        # initialize output
        mfn = False;

        # check if user specified filtered or we should use default value
        filtered = (filtered == True)

        # check if metadata file name is defined
        if 'mdf_metadata' in self.mdf_def['mdf_files'].keys() \
                and self.mdf_def['mdf_files']['mdf_metadata']:
            # exists a file name for metadata
            mfn = self.mdf_def['mdf_files']['mdf_metadata']

        elif 'mdf_base' in self.mdf_def['mdf_files']['mdf_base'] \
                and self.mdf_def['mdf_files']['mdf_base']:
            # use basename to build data file name
            mfn = self.mdf_def['mdf_files']['mdf_base'] + '.md.yml'
            # save the file name
            self.mdf_def['mdf_files']['mdf_metadata'] = mfn
        #end if/e;if

        # filters if needed
        if filtered:
            mfn = mdfConf.sfilter(mfn)
        #end if

        return mfn
    #end def getMetadataFileName

    #
    def getMFN(self,filtered = True):
        # mfn = obj.getMFN(filtered)
        #
        # Please refer to mdfObj.getMetadataFileName function for help

        # check if user specified filtered or we should use default value
        filtered =  (filtered == True)

        # call getMetadataFileName
        mfn = self.getMetadataFileName(filtered)

        return mfn
    #end def getMFN

    #
    def getDataFileName(self,filtered = True):
        # dfn = self.getDataFileName(filtered)
        #
        # returns the filename containing the data properties for this object
        # false if not defined. Filtered argument indicates if the path should
        # returned as it is or needs to be filtered with constants, aka
        # substitute any costant found in it.
        #
        # INPUT
        # - filtered : (boolean) OPTIONAL. Default: true.
        #

        # initialize output
        dfn = False;

        # check if user specified filtered or we should use default value
        filtered = (filtered == True);

        if 'mdf_data' in self.mdf_def['mdf_files'].keys() \
                and self.mdf_def['mdf_files']['mdf_data']:
            # exists a file name for data
            dfn = self.mdf_def['mdf_files']['mdf_data'];
        elif 'mdf_base' in self.mdf_def['mdf_files'] \
                and self.mdf_def['mdf_files']['mdf_base']:
            # use basename to build data file name
            dfn = self.mdf_def['mdf_files']['mdf_base'] + '.data.mat'
            # save the file name
            self.mdf_def['mdf_files']['mdf_data'] = dfn
        # end if/elif

        # filters if needed
        if filtered
            dfn = mdfConf.sfilter(dfn)
        # end if

        return dfn
    # end function

    #
    def getDFN(self,filtered):
        # dfn = self.getDFN(filtered)
        #
        # Please refer to mdfObj.getDataFileName function for help

        # check if user specified filtered or we should use default value
        filtered = (filtered == True)

        # call getDataFileName method
        dfn = self.getDataFileName(filtered)

        return dfn
    # end function

    #
    def getFiles(self,filtered = True):
        # function res = self.getFiles(filtered)
        #
        # return files settings for the object
        # Filtered argument indicates if the path should
        # returned as it is or needs to be filtered with constants, aka
        # substitute any costant found in it.
        #
        # INPUT
        # - filtered : (boolean) OPTIONAL. Default: true.
        #
        # Output
        # - res (struct)
        #    .base = base path, if used
        #    .data = path for .mat data file
        #    .metadata = path for .yaml metadata file
        #

        # check if user specified filtered or we should use default value
        filtered = (filtered == True)

        # prepare output
        files = {};
        if filtered:
            files.base = mdfConf.sfilter(self.mdf_def['mdf_files']['mdf_base'])
        else
            files.base = self.mdf_def['mdf_files']['mdf_base']
        # end if
        files.data = self.getDataFileName(filtered)
        files.metadata = self.getMetadataFileName(filtered)

        return files
    # end def getFiles

    #
    def setFiles(self,indata):
        # function res = self.setFiles(indata)
        #
        # set files where data is going to be saved
        # if indata is a string, it is assumed that it is the base path used to
        # build data and metadata file names
        # if it is a structure, it has to contain the following fields:
        #  base, data, metadata
        # In this case base is not used. Data is the file name for the .mat
        # data file, whgile metadata is the file name of the yaml metadata file
    

        if isinstance(indata,str):
            # we got base path
            self.mdf_def['mdf_files']['mdf_base'] = indata
            self.mdf_def['mdf_files']['mdf_data'] = None;
            self.mdf_def['mdf_files']['mdf_metadata'] = None;

        elif isinstance(indata,dict):
            # we got whole of it: base, data and metadata
            self.mdf_def['mdf_files']['mdf_base'] = '' if not 'base' in indata else indata['base']
            self.mdf_def['mdf_files']['mdf_data'] = indata['data']
            self.mdf_def.mdf_files.mdf_metadata = indata['metadata']

        else:
            # wrong input, return false
            return False
        # end if

        # return all settings
        return self.getFiles()
    # end def setFiles

    #
    def getSize(self):
        # return the approximate size of the object
        return totalSize(self)

    #

    def getUuids(self,group,property='all',format='uuids'):
        # function outdata = self.getUuids(group,property, format)
        #
        # this function returns the list of uuids of the selfect in the
        # specified group of relationship: parents, children, links
        # this function uses only local information. it will not load any of
        # the selfect specified in the relationship
        #
        # input:
        #  - group: (string) group for which we would like to uuids
        #           There is no default for this
        #           Possible values:
        #           * children,child,c
        #               returns uuids for all the children selfects
        #           * links,l
        #               returns uuids for all the selfects linked to the this one
        #           * unidirectionallinks, unilinks, ulinks, ul
        #               returns uuids for all the selfects unidirectionally
        #               linked from the current one
        #           * bidirectionallinks, bilinks, blinks, bl
        #               returns uuids for all the selfects bidirectionally
        #               linked to the current one
        #           * parents, p
        #               returns uuids of all the parents
        #
        #  - property: (string) name of the property within the group that we
        #               would like to retrieve.
        #               If not specified, will return all properties within the
        #               group
        #               Not used for parents
        #
        #  - format: (string) type of output
        #            Possible values:
        #            * default, uuids = output is a cell array containing uuids
        #            * UuidWithPropName = structure with uuid and property
        #                                 associated
        #
        # output:
        #  - outdata: (cell array of strings or array of structs)
        #             list of uuids requested or uuids and property to access
        #             them
        #

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
        if fg == 'c':
            # check if we got a property or not
            if property in obj.mdf_def['mdf_children'].keys():
                # extract array of references
                temp = obj.mdf_def['mdf_children'][property]
                # set lists
                ul = [item['mdf_uuid'] for item in temp]
                pl = [property] * len(ul)
            elif property == 'all':
                # cycle on all the properties
                for prop in obj.mdf_def['mdf_children']['mdf_fields']:
                    # extract array of references
                    temp = obj.mdf_def['mdf_children'][prop]
                    # set lists
                    ult = [item['mdf_uuid'] for item in prop]
                    plt = [prop] * len(ult)
                    # append values in complete list
                    ul += ult
                    pl += plt
                # end for
            # end if
        elif fg in ['l', 'ul', 'bl']:
            # initialize the directionality list
            dl = []
            if property in obj.mdf_def['mdf_links'].keys():
                # extract array of references
                temp = obj.mdf_def['mdf_links'][property]
                # set lists
                ul = [item['mdf_uuid'] for item in temp]
                pl = [property] * len(ul)
                dl = [item['mdf_direction'] for item in temp]
            elif property == 'all':
                # cycle on all the properties
                for prop in self.mdf_def['mdf_links']['mdf_fields']:
                    # extract array of references
                    temp = self.mdf_def['mdf_links'][pn]
                    # set lists
                    ult = [item['mdf_uuid'] for item in temp]
                    plt = [prop] * len(ult)
                    dlt = [item['mdf_direction'] for item in temp]
                    # append values in complete list
                    ul += ult
                    pl += plt
                    dl += dlt
                # end for
                # filters accordingly to the request
                if group in ['ul', 'bl']:
                    # retains only the unidirectional links
                    ul = [ value for i, value in enumerate(ul) if dl[i] == group[0]]
                    pl = [ value for i, value in enumerate(pl) if dl[i] == group[0]]
                # end if

        elif fg in ['parents', 'p']
            # extract array of references
            temp = self.mdf_def.mdf_parents;
            # set lists
            if len(temp) > 0
                ul = [item['mdf_uuid'] for item in temp]
            # end if

        else:
            # error
            raise Exception( 'mdfself:getUuids - Invalid group option.')
        # end switch

        # prepare output according to format requested
        if format == 'UuidWithPropName':
            # initialize outdata
            outdata = { \
                'uuid': ul, \
                'prop': pl};
        elif format == 'UuidWithPropNameNoEmpty':
            # initialize outdata
            outdata = [];
            if len(ul) > 0:
                outdata = { \
                    'uuid': ul, \
                    'prop': pl);
            # end if
        else:
            # returns only uuids
            outdata = ul;
        # end if
    # end def getUuids

    #
    def setDataInfo(self,field):
        # function self.setDataInfo(field)
        #
        # update properties info in def structure for the field passed
        # input
        #  - field: data property to be updated
        #
        #

        # check if data property is valid
        if not field in self.data.keys():
            return False
        # end if

        # get info about the specific field
        size = self.data[field].shape()
        type = type(self.data[field])
        mem = totalSize(self.data[field])

        # check if info have changed,
        # if so, mark mdf_def changed
        if not field in self.mdf_def['mdf_data'] \
                or self.mdf_def['mdf_data'][field].mdf_class != type \
                or self.mdf_def['mdf_data'][field].mdf_size != size \
                or self.mdf_def['mdf_data'][field].mdf_mem != mem:
            self.mdf_status['changed']['data'][field] = True
        # end if
        # set info in the _mdf_Def structure
        self.mdf_def['mdf_data'][field] = { \
            'mdf_class': type, \
            'mdf_size': size, ...
            'mdf_mem': mem}
        return True
    # end function

    #
    def dataLoad(self,dp):
        # function res = obj.dataLoad(dp)
        #
        # load data property dp from data file
        #
    
        # check if the data property is loaded or not
        if not self.mdf_status['loaded']['data'][dp]:
            # data property not laoded yet
            #
            # check if we have a file name for the data file
            # if so, load just the property requested
            dfn = self.getDataFileName();
            if dfn:
                # ok we got a data file name
                # open it with matfile class
                dpo = hdf5storage.loadmat(dfn, variable_names=[dp])
                # load the data property requested
                self.mdfdata[dp] = dpo;
                # updates def properties
                self.setDataInfo(dp);
                # marked as loaded
                self.mdf_status['loaded']['data'][dp] = True
            # end if
        # end if
    # end def dataLoad
    
    #
    @staticmethod
    def fileLoadInfo(file):
        # function res = mdfObj.fileLodaInfo(file)
        #
        # loads mdfObj object from file
        # it expects a file of type: .yml, .mat, or .h5
        #
        # the file has to have a well defined structure.
        # mdfObj checks for the following variables:
        # - mdf_def
        # - mdf_metadata
        #
        # anything else is discarded.
        #
    
        # initialize output
        res = None;
    
        # check if input file is valid and exists
        if not os.path.exists(file):
            # invalid file name or file not existing
            return res
        # end if

        # make sure that we catch any issue
        try
            # extract filename and extension
            fn, fe = os.path.splitext(file)

            # decide how load it
            if fe in ['.yml']:
                # we need to load a yaml file
                res = yaml.load(file)
            elif fe in ['.mat', '.h5']:
                # we have a mat or an h5 file
                # load values through matfile function
                temp1 = matfile(file);
                # transfer what we need
                res = { \
                    'mdf_version':temp1.mdf_version, \
                    'mdf_def': temp1.mdf_def, \
                    'mdf_metadata', temp1.mdf_metadata );
            #end if
        except:
            # error, cannot do anything
            # just in case we re-initialize the output
            res = None
        # end try/except
        return res
    # end def fileLoadInfo

    @staticmethod
    def load(indata):
        # function outdata = mdfObj.load(indata)
        #
        # load data and metadata from file or db and return an RF object fully populated
        #
        # input:
        #   indata = single string or structure with one of the following fields
        #   - uuid   : if this field is specified, loads the object defined by this uuid
        #              uuid takes precedence over any other field
        #   - file   : if this field is defined, loads the object defined in the file itself
        #              file takes precedence over everything other field, after uuid
        #   - <type> : object type. users can specify a condition for a specific metadata fields
        #              each condition will be applied in AND with the others.
        #              if there are multiple values for each conditions, each value with be applied in OR
        #
        #            If indata is a string, it will be converted to a structure internally and the
        #            input value will be assigned to uuid and file
        #
        # output
        #   outdata = RF object instance fully populated

        # check if we got a string in input
        if isinstance(indata,str):
            indata = { \
                'uuid': indata, \
                'file': indata}
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

        # let's check if we have uuid field
        if 'uuid' in indata.keys():
            # check if object is already loaded
            # retrieve handler
            outdata = om.get(indata['uuid'])
            if outdata
                # object already loaded
                # return back the object in memory
                return outdata
            # end if

            # object is not loaded yet
            # try the db next
            mdf_data = odb.find('{ "mdf_def.mdf_uuid" : "' + indata['uuid'] + '" }')
            if mdf_data is not None:
                # no luck through the db
                # trys file
                mdf_data = mdfObj.fileLoadInfo(indata['uuid'] + '_md.yml')
            # end if
        # end if

        # if mdf_data does not contains anything, next check if we have a file name
        if mdf_data is None and 'file' in indata.keys():
            # check if the object has been loaded
            # tryig to retrieve it by file name
            # retrieve handler, pass it back and return
            outdata = om.get(indata['file'])
            if outdata is not None:
                # object already loaded
                # return back object in memory
                return outdata
            # end if

            # we could not retrieve the object by file name
            # try to load file
            mdf_data = mdfObj.fileLoadInfo(indata['file'])
            # check if we were successful to load the mdf data
            if mdf_data is not None:
                # check if object has already been loaded by uuid
                outdata = om.get(mdf_data['mdf_def']['mdf_uuid'])
                if outdata is not None:
                    # object already loaded
                    # return back object in memory
                    return outdata
                #end if
            # end if
        # end if

        # if mdf_data still does not contains any info,
        # we check if there is a field named mdf_query, that contains a json
        # mongodb query
        if mdf_data is None and 'mdf_query' in indata:
            # runs the query as it is
            mdf_data = odb.find(indata['mdf_query'])
        # end if

        # next we check all the other fields and we use them to
        # build a query and send it to the db
        if mdf_data is None:
            tmp1 = indata;
            # remove fields not needed
            if 'uuid' in tmp1.keys():
                del tmp1['uuid']
            # end if
            if 'file' in tmp1.keys():
                del tmp1['file']
            # end if
            if 'mdf_query' in tmp1.keys():
                del tmp1['mdf_query']
            # end if
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

            # loop on all the objects found
            for cdata in mdf_data:

                # create new object
                outdata.append(mdfObj())

                # populate it
                # def
                outdata[-1]['mdf_def'] = cdata['mdf_def'];
                # metadata
                outdata[-1]['metadata'] = cdata['mdf_metadata'];
                # create place marks for data properties
                for field in cdata['mdf_def']['mdf_data']['mdf_fields']:
                    outdata[-1]['data'][field] = []
                    outdata[-1]['status']['loaded']['data'][field] = 0
                    outdata[-1]['status']['size']['data'][field] = 0
                # end if
                # convert mdf_parent if needed
                outdata[-1]['mdf_def']['mdf_parents'] = mdf.c2s(outdata[-1]['mdf_def']['mdf_parents']
                # convert each childrens list if needed
                for field in outdata[-1]['mdf_def']['mdf_children']['mdf_fields']:
                    # convert the field
                    outdata[-1]['mdf_def']['mdf_children'][field] = mdf.c2s(outdata[-1]['mdf_def']['mdf_children'][field])
                # end for
                # convert each link list if needed
                for field in outdata[-1]['mdf_def']['mdf_links']['mdf_fields']:
                    # convert the field
                    outdata[-1]['mdf_def']['mdf_links'][field] = mdf.c2s(outdata[-1]['mdf_def']['mdf_links'][field])
                # end for

                # register RF object in memory structures
                om.insert(outdata[-1].uuid,outdata[-1].getMFN(),outdata[-1])
            # end for

            # clear mdf data from memory
            del mdf_data

            return outdata
        # end if
    # end function load


# end class mdfObj

# end class mdfObj
