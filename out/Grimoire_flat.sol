pragma solidity 0.8.17;
pragma abicoder v2;

contract Grimoire  {
    event transcriptCreated(
        bytes32 transcript_id,
        uint256 created_at,
        uint256 last_updated_at,
        address creator,
        address[] contributors,
        string[] revision_metadata_uris,
        string reference_source_media,
        string reference_source_media_metadata_uri,
        bytes32 id_request,
        bytes32[] communities    
    );

    event transcriptRevised(
        bytes32 transcript_id,
        string revision,
        address creator
    );

    event transcriptUpdated(
        bytes32 transcript_id,
        uint256 last_updated_at,
        address[] contributors,
        bytes32[] communities,
        string reference_source_media_metadata_uri
    );

    event transcriptDeleted(
        bytes32 transcript_id
    );

    enum revisionStates{ PENDING, ACCEPTED, REJECTED}

    struct Transcription {
        bytes32 transcription_id;
        uint256 created_at;
        uint256 last_updated_at;
        address creator;
        address[] contributors;
        string[] revision_metadata_uris;
        string reference_source_media;
        string reference_source_media_metadata_uri;
        bytes32 id_request;
        bytes32[] communities;
        bool exists;
    }

    struct Revision {
        bytes32 id_revision;
        bytes32 transcript_id;
        address creator;
        string content_uri;
        revisionStates state;
        bool exists;
    }

    //requests are created for media that doesn't have a transcription yet, or the users arent satisfied with the current transcriptions
    event requestCreated(
        bytes32 request_id,
        uint256 created_at,
        uint256 last_updated_at,
        address creator,
        bool fulfilled,
        string original_media_metadata_uri,
        string reference_source_media,
        string metadata_uri
    );
    event requestFullfiled(bytes32 request_id);
    event requestDeleted(bytes32 request_id);
    struct Request {
        bytes32 request_id;
        uint256 created_at;
        uint256 last_updated_at;
        address creator;
        bool fulfilled;
        string original_media_metadata_uri;
        string reference_source_media;
        string metadata_uri;
        bool exists;
    }
//Input the request_id to fetch a certain Request struct
mapping(bytes32 => Request) public id_to_request;
//Input the transcription_id to fetch a certain Transcription struct
mapping(bytes32 => Transcription) public id_to_transcription;

mapping(bytes32 => Revision) public id_to_revision;
function createRequest(
        uint256 created_at,
        uint256 last_updated_at,
        bool fulfilled,
        string memory original_media_metadata_uri,
        string memory reference_source_media,
        string memory metadata_uri
) external {
    bytes32 request_id = keccak256(
        abi.encodePacked(
            msg.sender, 
            address(this),
            created_at,
            last_updated_at,
            original_media_metadata_uri
        )
    );
    require(id_to_request[request_id].exists == false, "This request already exists!");
     id_to_request[request_id] = Request(
        request_id,
        created_at,
        last_updated_at,
        msg.sender,
        fulfilled,
        original_media_metadata_uri,
        reference_source_media,
        metadata_uri,
        true
    );
    emit requestCreated(
        request_id,
        created_at,
        last_updated_at,
        msg.sender,
        fulfilled,
        original_media_metadata_uri,
        reference_source_media,
        metadata_uri
    );
}
function getRequest(bytes32 request_id) public view returns (Request memory request){
    Request memory request = id_to_request[request_id];
    return request;
}
function deleteRequest(bytes32 request_id) public {
    require(id_to_request[request_id].exists == true, "This Request does not exist" );
    require(id_to_request[request_id].creator == msg.sender, "Not the owner of this Request");
    id_to_request[request_id].exists = false;
    delete id_to_request[request_id];
    emit requestDeleted(request_id);
}
function createTranscription(
   uint256 created_at,
   address creator,
   address[] memory  contributors,
   string[] memory  revision_metadata_uris,
   string memory reference_source_media,
   string memory reference_source_media_metadata_uri,
   bytes32 id_request,
   bytes32[] calldata communities
) external {
    bytes32 transcription_id = keccak256(
        abi.encodePacked(
            msg.sender, 
            address(this),
            created_at,
            created_at
        )
    );
    require(id_to_transcription[transcription_id].exists == false, "This transcript already exists!");
    id_to_transcription[transcription_id] = Transcription(
        transcription_id,
        created_at,
        created_at,
        creator,
        contributors,
        revision_metadata_uris,
        reference_source_media,
        reference_source_media_metadata_uri,
        id_request,
        communities,
        true
    );
    emit transcriptCreated(
        transcription_id,
        created_at,
        created_at,
        creator,
        contributors,
        revision_metadata_uris,
        reference_source_media,
        reference_source_media_metadata_uri,
        id_request,
        communities);
}
function getTranscript(bytes32 transcript_id) public view returns (Transcription memory request){
    Transcription memory transcript = id_to_transcription[transcript_id];
    return transcript;
}
/*
    Checks if value exists and if the owner is the one that wants too delete it, then deletes the Transcript from the mapping
*/
function deleteTranscription(bytes32 transcription_id) public {
    require(id_to_transcription[transcription_id].exists == true, "This Transcript does not exist" );
    require(id_to_transcription[transcription_id].creator == msg.sender, "Not the owner of this Transcript");
    id_to_request[transcription_id].exists = false;
    delete id_to_request[transcription_id];
    emit transcriptDeleted(transcription_id);
}
/*If a transcript is revised, the value will be pushed into revision_metadata_uris array where we keep track of all
 revisions that way, we can easily keep track of our values from newest to oldest
*/

function isContributor(bytes32 transcription_id, address contributor) private returns (bool) {
    address[] memory contributors = id_to_transcription[transcription_id].contributors;
    for (uint256 i; i < contributors.length; i++ ){
        if (contributors[i] == contributor){
            return true;
        }
    }
    return false;
}

function reviseTranscription(string memory new_revision, bytes32 transcription_id, string memory reference_source_media) public {
    require(id_to_transcription[transcription_id].exists == true, "This Transcript does not exist" );
    require(id_to_transcription[transcription_id].creator == msg.sender, "Not the owner of this Transcript");
    id_to_transcription[transcription_id].revision_metadata_uris.push(new_revision);
    emit transcriptRevised(
        transcription_id,
        new_revision,
        id_to_transcription[transcription_id].creator
    );
}

function createRevision(bytes32 transcript_id, address creator, uint256 updated_time, string memory content_uri) private  {
    bytes32 revision_id = keccak256(
        abi.encodePacked(
            msg.sender, 
            address(this),
            updated_time,
            updated_time
        )
    );
    require(id_to_revision[revision_id].exists == false, "This revision already exists!");
    id_to_revision[revision_id] = Revision(
        revision_id,
        transcript_id,
        creator,
        content_uri,
        revisionStates.PENDING,
        true
    );

}


function getRevision(bytes32 revision_id) public view returns (Revision memory revision) {
    require(id_to_revision[revision_id].exists == true,"Revision does not exist");
    return id_to_revision[revision_id];

}

function rejectRevision(bytes32 revision_id) public {
    require(id_to_revision[revision_id].exists == true,"Revision does not exist");
    id_to_revision[revision_id].state = revisionStates.REJECTED;

}

function acceptRevision(bytes32 revision_id) public {
    bytes32 transcript_id = id_to_revision[revision_id].transcript_id;
    string memory metadata_uri = id_to_revision[revision_id].content_uri;
    id_to_transcription[transcript_id].revision_metadata_uris.push(metadata_uri);
    id_to_revision[revision_id].state = revisionStates.ACCEPTED;
}

function proposeRevision(bytes32 transcript_id, address creator, uint256 updated_time, string memory content_uri) public {
        if (isContributor(transcript_id, creator)){
            id_to_transcription[transcript_id].revision_metadata_uris.push(content_uri);
        }
        else {
            createRevision(transcript_id, creator, updated_time, content_uri);
        }
}
}


