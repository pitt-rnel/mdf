#
# python implementation or mdf class
#
# by: Max Novelli
#     man8@pitt.edu
#

class mdf(object):

    #
    # load method
    @staticmethod
    def load(datain):
        # method dataout = pyMDF.mdf.load(datain)
        #
        # load one or more object according to the request specified in datain
        #
        # Input
        # - datain:
        #      (string) uuid of the object to be loaded, or .yml or .mat file to be loaded
        #      (dictionary) query to be used to load mdf objects
        #
        # Output
        # - dataout:
        #      (mdfObj or array of mdfObj) modfObj that matches the requests
        #

        # initialize return value
        dataout = False


        # return mdf object matching request
        return dataout


    #
    @staticmethod
    def getUuidAndObject(indata):
        # given the input(uuid or mdfObj), it returns both uuid and object
        #
        # input
        # - indata(string or mdfObj): it can be the mdfObj instance or the uuid of the object.
        #                             if uuid is passed, the object has to be already saved and
        #                             registered in the memory management object, because
        #                             we need to be able to load it by uuid
        #                             if mdfObj object is passed, the object can be a new one
        #                             and not already saved in the db. This allow looping and
        #                             creation of multiple object and relations before they are
        #                             saved in the db
        #
        # output
        # - uuid(string): object uuid
        # - object(mdfObj): handle to the mdfObj
        #

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
            object = indata;

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

        # check output
        if not isinstance(uuid,str) or not uuid or not isinstance(object, mdfObj):
            raise Exception(
                'mdf:getUuidAndObject:40 - Invalid output')
        # end if

        # return values
        return [uuid, object]
    # end def getUuidAndObject


    #
    # getUAO
    @staticmethod
    def getUAO(indata):
        # function[uuid, object] = mdf.getUAO(indata);
        #
        # place - mark for function mdf.getUuidAndObject
        # please see help for mdf.getUuidAndObject

        [uuid, object] = mdf.getUuidAndObject(indata)
        return [uuid, object]
    #end def getUAO
