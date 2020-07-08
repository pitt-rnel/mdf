function outobj = toBasicDBObject(obj,inobj)
    % function outobj = obj.toBasicDBObject(inobj)
    %
    % takes a obj as structure or string format and converts it 
    % to BasicDBObject ready to be used in a mongodb query

    % import query object
    import com.mongodb.BasicDBObject
    
    switch class(inobj)
        case {'struct'}
            outobj = BasicDBObject.parse(mdf.toJson(inobj));
        case {'char'}
            outobj = BasicDBObject.parse(inobj);
        otherwise
            throw( ...
                MException( ...
                    'mdfDB:toBasicDBObject', ...
                    'Invalid object type'));
    end %switch

end %function
