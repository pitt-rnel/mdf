function outobj = toBsonDocument(obj,inobj)
    % function outobj = obj.toBsonDocument(inobj)
    %
    % takes a obj as structure or string format and converts it 
    % to BSON Document ready to be used in a mongodb query

    % import query object
    import org.bson.Document
    
    switch class(inobj)
        case {'struct'}
            outobj = Document.parse(mdf.toJson(inobj));
        case {'char'}
            outobj = Document.parse(inobj);
        otherwise
            throw( ...
                MException( ...
                    'mdfDB:toBsonDocument', ...
                    'Invalid object type'));
    end %switch

end %function