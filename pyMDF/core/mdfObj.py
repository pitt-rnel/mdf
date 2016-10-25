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


    #
    #
    def addChild(self,prop,*args):
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
        if (not prop in obj.mdf_def['mdf_children']['mdf_fields']):
            # we need to create the new property
            # append at the end of the list
            obj.mdf_def['mdf_children']['mdf_fields'].append(prop)
            obj.mdf_def['mdf_children']['mdf_types'].append('')
            obj.mdf_def['mdf_children'][prop] = []
        # end if
        #
        # find the index
        ip = obj.mdf_def['mdf_children']['mdf_fields'].index(prop)
        #
        # check if we have the object to insert or not
        if len(args) <= 0
            # no other arguments, we are done
            return self;
        #end if

        # we got child to insert
        child = args(1)
        # let's check if have position too or not
        if len(args) <= 1
            # we got only the child
            # no position, default to 1
            pos = 1
            if prop in obj.mdf_def['mdf_children']:
                pos = len(obj.mdf_def['mdf_children']['prop'] + 1
            # end if
        else
            # we got position, extract it and check it
            pos = args(2)
            if not isinstance(pos,int) or pos < 0 or pos > len(obj.mdf_def['mdf_children'][prop]) + 1:
                raise Exception('mdfObj:addChild - Invalid position (' + str(pos) + ')')
            # end if
        #end if

        # get child uuid and object
        uChild, oChild = mdf.getUAO(child)

        # check if it is the first element
        if prop in obj.mdf_def['mdf_children'] or \
                not obj.mdf_def['mdf_children']['mdf_types'](ip) or \
                len(obj.mdf_def['mdf_children']['prop']) == 0:
            # insert type of new child
            obj.mdf_def['mdf_children']['mdf_types'][ip] = oChild.type
            # insert new child in new property
            obj.mdf_def['mdf_children']['prop'] = { \
                    'mdf_uuid': oChild.uuid, \
                    'mdf_type': oChild.type, \
                    'mdf_file': oChild.getMFN(False) }
        else:
            # check if uuid is already in list
            uuids = [obj.mdf_def['mdf_children'][key]['mdf_uuid'] for key in obj.mdf_def['mdf_children'] if not 'mdf_' in key];
            i = uuids.index(uChild);
            if not i:
                raise Exception('mdfObj:addChild - Object with uuid ' + uChild + ' already inserted');
            #end if

            # check if type matches the one already present
            if ~strcmp(obj.mdf_def.mdf_children.mdf_types{ip},oChild.type)
                throw(MException('mdfObj:addChild',['Invalid type ' oChild.type '. Children under ' prop ' are of type ' obj.mdf_def.mdf_children.mdf_types{i}]));
            #end if

            # we are cleared to insert in position
            obj.mdf_def.mdf_children.(prop) = [ ...
                obj.mdf_def.mdf_children.(prop)(1:pos-1), ...
                struct( ...
                    'mdf_uuid', oChild.uuid, ...
                    'mdf_type', oChild.type, ...
                    'mdf_file', oChild.getMFN(false) ), ...
                obj.mdf_def.mdf_children.(prop)(pos:end)];
        #end if

    #end def addChild
#end class