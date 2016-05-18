function uuid = UUID()
    % function uuid = rf.UUID()
    %
    % static function that generates a new uuid
    uuid = char(java.util.UUID.randomUUID);
end %function