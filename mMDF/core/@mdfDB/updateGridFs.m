function res = updateGridFs(obj,name,value)
    % function res = obj.update(obj,query,values,upsert)
    %
    % update all the records matching the query with the passed values
    % input
    %   query  : string, or struct containing the query
    %            if it is a string, it is assumed that is the json rapresentation of the query.
    %            if it is a struct, it is the struct representation of the query
    %   values : string or structure contining the values to be set
    %            same as for query
    %
    % output
    %   res = 1 if the record has been update, 0 if not
    %
    
    import com.mongodb.Block;
    import com.mongodb.client.MongoClients;
    import com.mongodb.client.MongoClient;
    import com.mongodb.client.MongoDatabase;
    import com.mongodb.client.gridfs.*;
    import com.mongodb.client.gridfs.model.*;
    import org.bson.Document;
    import org.bson.types.ObjectId;
    import java.io.*;
    import java.nio.file.Files;
    import java.nio.charset.StandardCharsets;
    import com.mongodb.client.model.Filters.eq;

    % check if this is an exisiting record
    
    % remove existing record
    
    % Upload Array/Matrix to GridFS
    % Convert array to json bytes
    jsonBytes = uint8(jsonencode(value));
    % Create Java InputStream. Can probably just use ByteArrayInputStream because of import java.io.*;
    byteInputStream = java.io.ByteArrayInputStream(json_bytes); 
    % set metadata
    options = GridFSUploadOptions()
    options.metadata( ...
        obj.toBsonDocument( ...
            struct( ...
                'mdf_puuid', parent_uuid, ...
                'mdf_uuid' , object_uuid, ...
                'mdf_field', data_property_name[1],
                'mdf_type' , t2.__class__.__name__
                "mdf_type", "", ...
                "mdf_uuid", "", ...
                "mdf_prop", "")));
    % Upload. This may need a try catch
    fileId = gridFSBucket.uploadFromStream(name, byteInputStream, options); 
    
    % update info in mdfObj

end %function