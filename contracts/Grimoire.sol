pragma solidity ^0.8.17;
pragma abicoder v2;

contract Grimoire  {
    event transcriptCreated(
        bytes32 transcript_id,
        uint256 created_at,
        uint256 last_updated_at,
        address creator,
        address[] contributors,
        string[] revision_metadata_uris,
        string metadata_uri,
        bytes32 id_request,
        string[] communities    
    );

    event transcriptDeleted(
        bytes32 transcript_id
    );
/*    event transcriptRevised(
        bytes32 transcript_id,
        string revision,
        address creator
    );*/

/*    event transcriptUpdated(
        bytes32 transcript_id,
        uint256 last_updated_at,
        address[] contributors,
        bytes32[] communities,
        string metadata_uri
    );*/

    event requestCreated(
        bytes32 request_id,
        uint256 created_at,
        uint256 last_updated_at,
        address creator,
        bool receiving_transcripts,
        bool fulfilled,
        string original_media_metadata_uri,
        string reference_source_media,
        string metadata_uri
    );
    event requestStateUpdate(bytes32 request_id, bool receiving_transcripts, bool fulfilled);
    event requestDeleted(bytes32 request_id);

    event revisionCreated(bytes32 id_revision,
        bytes32 transcript_id,
        address creator,
        string content_uri,
        revisionStates state);
    event revisionStateChanged(bytes32 id_revision, bytes32 id_transcript ,revisionStates state);



    enum revisionStates{ PENDING, ACCEPTED, REJECTED}
    struct Transcription {
        bytes32 transcription_id;
        uint256 created_at;
        uint256 last_updated_at;
        address creator;
        address[] contributors;
        string[] revision_metadata_uris;
        string metadata_uri;
        bytes32 id_request;
        string[] communities;
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

    struct Request {
        bytes32 request_id;
        uint256 created_at;
        uint256 last_updated_at;
        address creator;
        bool receiving_transcripts;
        bool fullfiled;
        string original_media_metadata_uri;
        string reference_source_media;
        string metadata_uri;
        bool exists;
    }
//Input the request_id to fetch a certain Request struct
mapping(bytes32 => Request) public id_to_request;
mapping(address => bytes32[]) public address_to_request;
//Input the transcription_id to fetch a certain Transcription struct
mapping(bytes32 => Transcription) public id_to_transcription;
mapping(address => bytes32[]) public address_to_transcripts;

mapping(bytes32 => Revision) public id_to_revision;


function createRequest(
        uint256 created_at,
        uint256 last_updated_at,
        bool receiving_transcripts,
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
        receiving_transcripts,
        fulfilled,
        original_media_metadata_uri,
        reference_source_media,
        metadata_uri,
        true
    );
    address_to_request[msg.sender].push(request_id);
    emit requestCreated(
        request_id,
        created_at,
        last_updated_at,
        msg.sender,
        receiving_transcripts,
        fulfilled,
        original_media_metadata_uri,
        reference_source_media,
        metadata_uri
    );
}
function _getAddressToIdIndex(bytes32[] memory id_array, bytes32 id) view private returns(uint256) {
    for (uint256 i; i < id_array.length; i++){
        if (id_array[i] == id){
            return i;
        }
    }
}




function requestStatesUpdated(bytes32 request_id ,bool receiving_transcripts, bool fulfilled) public   {
    Request memory request = id_to_request[request_id]; 
    if (request.receiving_transcripts != receiving_transcripts){
        id_to_request[request_id].receiving_transcripts = receiving_transcripts;
    }
    if (request.fullfiled != fulfilled){
        id_to_request[request_id].fullfiled = fulfilled;
    }
    emit requestStateUpdate(request_id, id_to_request[request_id].receiving_transcripts, id_to_request[request_id].fullfiled);
}
function getRequests(address user_address) public view returns (Request[] memory requests) {
    bytes32[] memory request_address_ids = address_to_request[user_address];
    require(request_address_ids.length > 0, "This address didn't publish yet or has removed its requests");
    Request[] memory requests = new Request[](request_address_ids.length);
    for (uint256 i; i < request_address_ids.length; i++){
        requests[i] = id_to_request[request_address_ids[i]];
    }
    return requests;
}
function getRequest(bytes32 request_id) public view returns (Request memory request){
    return id_to_request[request_id];
}
function deleteRequest(bytes32 request_id) public {
    require(id_to_request[request_id].exists == true, "This Request does not exist" );
    require(id_to_request[request_id].creator == msg.sender, "Not the owner of this Request");
    id_to_request[request_id].exists = false;
    bytes32[] memory all_requests_user = address_to_request[id_to_request[request_id].creator];
    uint256 index = _getAddressToIdIndex(all_requests_user, request_id);
    address_to_request[id_to_request[request_id].creator][index] = address_to_request[id_to_request[request_id].creator][all_requests_user.length - 1];
    address_to_request[id_to_request[request_id].creator].pop();
    delete id_to_request[request_id];
    emit requestDeleted(request_id);
}
function createTranscription(
   uint256 created_at,
   address[] memory  contributors,
   string memory metadata_uri,
   bytes32 id_request,
   string[] calldata communities
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
    string[] memory revision_metadata_uris;
    id_to_transcription[transcription_id] = Transcription(
        transcription_id,
        created_at,
        created_at,
        msg.sender,
        contributors,
        revision_metadata_uris,
        metadata_uri,
        id_request,
        communities,
        true
    );
    address_to_transcripts[msg.sender].push(transcription_id);
    emit transcriptCreated(
        transcription_id,
        created_at,
        created_at,
        msg.sender,
        contributors,
        revision_metadata_uris,
        metadata_uri,
        id_request,
        communities);
}

function getTranscripts(address user_address) public view returns (Transcription[] memory transcripts) {
    bytes32[] memory transcript_address_ids = address_to_transcripts[user_address];
    require(transcript_address_ids.length > 0, "This address didn't publish yet or has removed its transcriptions");

    Transcription[] memory transcripts = new Transcription[](transcript_address_ids.length);
    for (uint256 i; i < transcript_address_ids.length; i++){
        transcripts[i] = id_to_transcription[transcript_address_ids[i]];
    }
    return transcripts;
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
    
    bytes32[] memory all_transcripts_user = address_to_transcripts[id_to_transcription[transcription_id].creator];
    uint256 index = _getAddressToIdIndex(all_transcripts_user, transcription_id);
    address_to_transcripts[id_to_transcription[transcription_id].creator][index] = address_to_transcripts[id_to_transcription[transcription_id].creator][all_transcripts_user.length - 1];
    address_to_transcripts[id_to_transcription[transcription_id].creator].pop();
    delete id_to_request[transcription_id];
    emit transcriptDeleted(transcription_id);
}
/*If a transcript is revised, the value will be pushed into revision_metadata_uris array where we keep track of all
 revisions that way, we can easily keep track of our values from newest to oldest
*/

function isContributor(bytes32 transcription_id, address contributor) private view returns (bool) {
    address[] memory contributors = id_to_transcription[transcription_id].contributors;
    for (uint256 i; i < contributors.length; i++ ){
        if (contributors[i] == contributor){
            return true;
        }
    }
    return false;
}
/*
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
*/
function createRevision(bytes32 transcript_id, address creator, uint256 updated_time, string memory content_uri, revisionStates state) private  {
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
        state,
        true
    );
    emit revisionCreated(
        revision_id,
        transcript_id,
        creator,
        content_uri,
        state
    );

}

function findRevsionApproved(string[] memory transcript_revisions, string memory revision_uri) private pure returns(bool exists) {
    for (uint256 i; i < transcript_revisions.length; i++){
        if (keccak256(abi.encodePacked(transcript_revisions[i])) == keccak256(abi.encodePacked(revision_uri))){
            return true;
        }
    }
    return false;
}

function getRevision(bytes32 revision_id) public view returns (string memory content_uri, uint256 revision_index) {
    require(id_to_revision[revision_id].exists == true,"Revision does not exist");
    string memory revision_uri = id_to_revision[revision_id].content_uri;
    string[] memory transcript_revisions = id_to_transcription[id_to_revision[revision_id].transcript_id].revision_metadata_uris;
    bool revision_approved = findRevsionApproved(transcript_revisions, revision_uri);
    require(revision_approved == true, "Revision has not yet been approved by the owners of the transcription");
    for (uint256 i; i < transcript_revisions.length; i++){
        if (keccak256(abi.encodePacked(transcript_revisions[i])) == keccak256(abi.encodePacked(revision_uri))){
            return (revision_uri, i);
        }
    }
}

function rejectRevision(bytes32 revision_id) public {
    require(id_to_revision[revision_id].exists == true,"Revision does not exist");
    id_to_revision[revision_id].state = revisionStates.REJECTED;
        emit revisionStateChanged(
        revision_id, id_to_revision[revision_id].transcript_id, revisionStates.ACCEPTED
    );
}

function acceptRevision(bytes32 revision_id) public {
    bytes32 transcript_id = id_to_revision[revision_id].transcript_id;
    string memory metadata_uri = id_to_revision[revision_id].content_uri;
    id_to_transcription[transcript_id].revision_metadata_uris.push(metadata_uri);
    id_to_revision[revision_id].state = revisionStates.ACCEPTED;
    emit revisionStateChanged(
        revision_id, transcript_id, revisionStates.ACCEPTED
    );
}

function proposeRevision(bytes32 transcript_id, address creator, uint256 updated_time, string memory content_uri) public {
        if (isContributor(transcript_id, creator)){
            id_to_transcription[transcript_id].revision_metadata_uris.push(content_uri);
            createRevision(transcript_id, creator, updated_time, content_uri, revisionStates.ACCEPTED);
        }
        else {
            createRevision(transcript_id, creator, updated_time, content_uri, revisionStates.PENDING);
        }
}
}