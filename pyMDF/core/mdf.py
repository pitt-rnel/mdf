#
# python implementation or mdf class
#
# by: Max Novelli
#     man8@pitt.edu
#

import mdfObj


class mdf(object):

    libraries = '../../libs';
    pattern = '/[@\w]+/\.\./';
    version = '1.6'

    @staticmethod
    def getInstance(**kwargs):
        '''
        return singleton instance of mdf class

        :param kwargs:
                - action: (string)
                    * release: delete the singleton
        :return: (mdf) it returns the singleton for this class
        '''

        #
        # see if we got an input
        action = ''
        if 'action' in kwargs.keys():
            action = kwargs['action']

        #
        # we check if the global place maker for mdf exists and if it has a valid mdfConf in it
        global omdfc
        if not isinstance(omdfc,dict):
            omdfc = dict()
        # end %if

        if 'mdf' not in omdfc:
            omdfc.mdf  = None
        # end %if

        # check if we need to release the current singleton
        if isinstance(action,str) and action.lower()_== 'release':
            # we need to clear the current unique instance
            # (aka singleton)
            if isinstance(omdfc.mdf,mdf):
                # delete isntance
                del omdfc['mdf']
                omdfc['mdf'] = None
                # we are done
                return None
            # end if
        # check if the singleton is already instantiated or not
        elif ( not omdfc['mdf'] or not isinstance(omdfc['mdf'],mdf) ):
            # singleton needs to be instantiated
            obj = mdf()
            # save it in persistent variable
            omdfc['mdf'] = obj
        else
            # returned singleton object
            obj = omdfc['mdf']
        # end %if

        return obj

    # end %function


    @staticmethod
    def load(**kwargs):
        '''
        load one or more object according to the request specified in datain

        :param kwargs:
               (string) uuid of the object to be loaded, or .yml or .mat file to be loaded
               (dictionary) query to be used to load mdf objects
               For more details please check mdfObj.load
        :return: (list of mdfObj) mdf objects that matches the requests
        '''

        # return mdf object matching request
        return mdfObj.load(**kwargs)
    #end def load

    @staticmethod
    def unload(**kwargs):
        '''
        unload the object from memory

        :param kwargs:
        :return:
        '''
        return mdfObj.unload(**kwargs)
    #end def

    @staticmethod
    def getUuidAndObject(indata):
        '''
        given the input(uuid or mdfObj), it returns both uuid and object

        :param indata: (string or mdfObj):
               it can be the mdfObj instance or the uuid of the object.
               if uuid is passed, the object has to be already saved and
               registered in the memory management object, because
               we need to be able to load it by uuid
               if mdfObj object is passed, the object can be a new one
               and not already saved in the db. This allow looping and
               creation of multiple object and relations before they are
               saved in the db

        :return:
          - uuid(string): object uuid
          - object(mdfObj): handle to the mdfObj
        '''

        # initialize output values
        uuid = None
        object = None

        # check what we get in input
        if isinstance(indata,mdfObj):
            # input is an mdfObj instance
            # get uuid from the object
            uuid = indata.uuid
            # check if uuid is a string and not empty
            if not isinstance(uuid,str) or not uuid:
                raise Exception(
                    'mdf:getUuidAndObject:10 - Invalid object uuid')
            # end if
            # set object
            object = indata

        elif isinstance(indata,str):
            # input is a string, so we assume that it is the uuid of the
            # object
            uuid = indata

            # load the object, just to be sure
            object = mdf.load(uuid);

            # check if we got an object
            if not isinstance(object, mdfObj):
                # no luck, something went wrong
                raise Exception(
                    'mdf:getUuidAndObject:20 - Object not found or invalid')
            #end if

        else:
            # if we get here, there is something wrong
            # we do not accept anything else in input
            raise Exception('mdf:getUuidAndObject:30 - Invalid input')
        #end if/elif/else

        # return values
        return [uuid, object]
    # end def getUuidAndObject


    #@staticmethod
    #def getUAO(indata):
    #    '''
    #    shortcut for function mdf.getUuidAndObject
    #    please see help for mdf.getUuidAndObject
    #    '''
    #    return mdf.getUuidAndObject(indata)
    #end def getUAO

    @staticmethod
    def addParentChildRelation(inparent, inchild, prop):
        '''
        create a parent - child relationship between object parent and child.
        in parent object, child will be accessible under the property prop

        :param inparent: (uuid or mdfObj) parent object or uuid of the parent object
        :param inchild: (uuid or mdfObj) child objecy or uuid of the child object
        :param prop: (string) property under which the child object will be
                    found in the parent object
        :return:
            - res: (boolean) true if successful
            - outparent: (mdfObj) parent mdf object
            - outchild: (mdfObj) child object
        '''

        # get parent uuid and object
        [uParent, oParent] = mdf.getUAO(inparent)
        # get child uuid and object
        [uChild, oChild] = mdf.getUAO(inchild)

        # add child under designated property in parent
        res1 = oParent.addChild(prop, oChild)

        # add parent under parent property in child object
        res2 = oChild.addParent(oParent)

        return (res1 and res2, oParent, oChild)

    #end function

    @staticmethod
    def rmParentChildRelation(inparent,inchild,prop):
        '''
        remove a parent-child relationship between object parent and child.
        in parent object, child should be accessible under the property prop

        :param inparent: (uuid or mdfObj) parent object or uuid of the parent object
        :param inchild: (uuid or mdfObj) child objecy or uuid of the child object
        :param prop: (string) property under which the child object will be
                                found in the parent object
        :return:
            - res       : (boolean) true if successful
            - outparent : (mdfObj) parent mdf object
            - outchild  : (mdfObj) child object
        '''

        # get parent uuid and object
        [uParent, oParent] = mdf.getUAO(inparent)

        # get child uuid and object
        [uChild, oChild] = mdf.getUAO(inchild)

        # add child under designated property in parent
        res1 = oParent.rmChild(prop,oChild)

        # add parent under parent property in child object
        res2 = oChild.rmParent(oParent)

        return (res1 and res2, oParent, oChild)
    # end function

    @staticmethod
    def addBidirectionalLink(insource,indest,sProp,dProp):
        '''
        create a bidirectional link from source object to destination object
        under sProp property in the source object and dProp in the
        destination object.
        this link allows to go from source to dest and viceversa

        :param insource: (uuid or mdfObj) source object or uuid of the source object
        :param indest: (uuid or mdfObj) destination object or uuid of the destination object
        :param sProp: (string) property under which the destination object will be
                        found in the source object
        :param dProp: (string) property under which the source object will be
                        found in the destination object
        :return:
            - res       : (boolean) true if success
            - outsource : (mdfObj) source mdf object
            - outdest   : (mdfObj) destination mdf object
        '''

        # get uuid and object for source
        [uSource, oSource] = mdf.getUAO(insource)

        # get uuid and object for dest
        [uDest, oDest] = mdf.getUAO(indest)

        # add destination object under designated property in source object
        res1 = oSource.addLink(sProp,oDest,'b')

        # add Source under Source property in Dest object
        res2 = oDest.addLink(dProp,oSource,'b')

        return (res1 and res2, oSource, oDest)
    # end function

    @staticmethod
    def rmBidirectionalLink(insource,indest,sProp,dProp):
        '''
        remove a bidirectional link between source and destination object.

        :param insource: (uuid or mdfObj) source object or uuid of the source object
        :param indest: (uuid or mdfObj) destination object or uuid of the destination object
        :param sProp: (string) property under which the destination object will be
                        found in the source object
        :param dProp: (string) property under which the source object will be
                        found in the destination object
        :return:
            - res       : (boolean) true if success
            - outsource : (mdfObj) source mdf object
            - outdest   : (mdfObj) destination mdf object
        '''


        # get source uuid and object
        [uSource, oSource] = mdf.getUAO(insource)

        # get dest uuid and object
        [uDest, oDest] = mdf.getUAO(indest)

        # remove link from source object
        res1 = oSource.rmLink(sProp,oDest)

        # remove link from destination object
        res2 = oDest.rmLink(dProp,oSource)

        return (res1 and res2, oSource, oDest)
    # end function

    @staticmethod
    def addUnidirectionalLink(insource,indest,sProp):
        '''
        create a unidirectional link from source object to destination object
        under prop property in the source object.
        destination object is not aware of the link

        :param insource: (uuid or mdfObj) source object or uuid of the source object
        :param indest: (uuid or mdfObj) destination object or uuid of the destination object
        :param sProp: (string) property under which the destination object will be
                found in the source object
        :return:
            - res       : (boolean) true if success
            - outsource : (mdfObj) source mdf object
            - outdest   : (mdfObj) destination mdf object
        '''

        # get uuid and object for source
        [uSource, oSource] = mdf.getUAO(insource)

        # get uuid and object for dest
        [uDest, oDest] = mdf.getUAO(indest)

        # add destination object under designated property in source object
        res = oSource.addLink(sProp,oDest,'u')

        return (res, oSource, oDest)
    # end function

    @staticmethod
    def rmUnidirectionalLink(insource,indest,sProp):
        '''
        remove a unidirectional link between source object.

        :param insource: (uuid or mdfObj) source object or uuid of the source object
        :param indest: (uuid or mdfObj) destination object or uuid of the destination object
        :param sProp: (string) property under which the destination object will be
                              found in the source object
        :return:
            - res       : (boolean) true if success
            - outsource : (mdfObj) source mdf object
            - outdest   : (mdfObj) destination mdf object
        '''

        # get source uuid and object
        [uSource, oSource] = mdf.getUAO(insource)

        # get dest uuid and object
        [uDest, oDest] = mdf.getUAO(indest)

        # remove link from source object
        res = oSource.rmLink(sProp,oDest)

        return (res, oSource, oDest)

    #end function

    @staticmethod
    def memoryUsage():
        '''
        returns the memory usage for the system

        :return:
            - total: total system memory
            - used: memory currently used
            - free: memory currently free and available for use
        '''
    #end function


# create shortcuts for functions
mdf.getUAO = mdf.getUuidAndObject
mdf.apcr = mdf.addParentChildRelation
mdf.rpcr = mdf.rmParentChildRelation
mdf.abl = mdf.addBidirectionalLink
mdf.rbl = mdf.rmBidirectionalLink
mdf.aul = mdf.addUnidirectionalLink
mdf.rul = mdf.rmUnidirectionalLink
