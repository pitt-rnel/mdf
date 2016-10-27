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

        data = struct();
        metadata = struct();

    #
    #
    def addChild(self,prop,child=None,pos=-1):
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
        if pos < 0:
            # we got only the child
            # no position, default to end
            pos = 0
            if prop in self.mdf_def['mdf_children']:
                pos = len(self.mdf_def['mdf_children']['prop'])
            # end if
        # we got position, extract it and check it
        elif not isinstance(pos,int) \
                or pos < 0 \
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
            i = uuids.index(uChild);
            if i:
                raise Exception('mdfObj:addChild - Object with uuid ' + uChild + ' already inserted');
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
            if pos < len(self.mdf_def['mdf_children'][prop]):
                # insert in the list at the right position
                self.mdf_def['mdf_children'][prop].insert(item, pos )
            else:
                # append at the end
                self.mdf_def['mdf_children'][prop].append(item)
            #end if/else
        #end if/else
    #end def addChild

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
        
#end class mdfObj