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

    event transcriptApproved(
        bytes32 request_id,
        bytes32 transcript_id,
        address collaborator
    );
    event requestCreated(
        bytes32 request_id,
        uint256 created_at,
        uint256 last_updated_at,
        address creator,
        bool receiving_transcripts,
        bool fulfilled,
        string metadata_uri,
        address[] collaborators
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
    struct Request {
        bytes32 request_id;
        uint256 created_at;
        uint256 last_updated_at;
        address creator;
        bool receiving_transcripts;
        bool fullfiled;
        string metadata_uri;
        address[] collaborators;
        bytes32 id_linked_transcription;
        bool exists;
    }
mapping(bytes32 => Request) public id_to_request;
mapping(address => bytes32[]) public address_to_request;
mapping(bytes32 => Transcription) public id_to_transcription;
mapping(address => bytes32[]) public address_to_transcripts;

mapping(bytes32 => Revision) public id_to_revision;
mapping(address => bytes32[]) public address_to_revision;

mapping(bytes32 => bytes32[]) public request_id_to_proposals;
mapping(bytes32 => bytes32[]) public transcript_id_to_revisions;

function createRequest(
        uint256 created_at,
        string memory metadata_uri,
        address[] memory collaborators
) external {
    bytes32 request_id = keccak256(
        abi.encodePacked(
            msg.sender, 
            address(this),
            created_at,
            created_at,
            metadata_uri
        )
    );
    bytes32 transcript_id;
    require(id_to_request[request_id].exists == false, "This request already exists!");
     id_to_request[request_id] = Request(
        request_id,
        created_at,
        created_at,
        msg.sender,
        true,
        false,
        metadata_uri,
        collaborators,
        transcript_id,
        true
    );
    address_to_request[msg.sender].push(request_id);
    emit requestCreated(
        request_id,
        created_at,
        created_at,
        msg.sender,
        true,
        false,
        metadata_uri,
        collaborators
    );
}
function _getAddressToIdIndex(bytes32[] memory id_array, bytes32 id) pure private returns(uint256) {
    for (uint256 i; i < id_array.length; i++){
        if (id_array[i] == id){
            return i;
        }
    }
}




function updateRequestStatus(bytes32 request_id ,bool receiving_transcripts, bool fulfilled) public   {
    Request memory request = id_to_request[request_id]; 
    if (request.receiving_transcripts != receiving_transcripts){
        id_to_request[request_id].receiving_transcripts = receiving_transcripts;
    }
    if (request.fullfiled != fulfilled){
        id_to_request[request_id].fullfiled = fulfilled;
    }
    emit requestStateUpdate(request_id, id_to_request[request_id].receiving_transcripts, id_to_request[request_id].fullfiled);
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
    if (id_to_request[id_request].exists){
        request_id_to_proposals[id_request].push(transcription_id);
    }
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


function getTranscript(bytes32 transcript_id) public view returns (Transcription memory request){
    Transcription memory transcript = id_to_transcription[transcript_id];
    return transcript;
}

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



function isContributor(bytes32 transcription_id, address contributor) private view returns (bool) {
    address[] memory contributors = id_to_transcription[transcription_id].contributors;
    for (uint256 i; i < contributors.length; i++ ){
        if (contributors[i] == contributor){
            return true;
        }
    }
    return false;
}

function isColaborator(address collaborator, address[] memory collaborators) private pure returns(bool) {
    for (uint256 i; i < collaborators.length; i++){
        if (collaborator == collaborators[i]){
            return true;
        }
    }
    return false;
}

function approveTranscript(bytes32 transcript_id, bytes32 request_id, address collaborator ) public {
    require(isColaborator(collaborator ,id_to_request[request_id].collaborators) == true, "The request must be approved");
    id_to_request[request_id].id_linked_transcription = transcript_id;
    id_to_request[request_id].fullfiled = true;
    id_to_request[request_id].receiving_transcripts = false;
    emit transcriptApproved(transcript_id, request_id, collaborator);
}   
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
    if (state == revisionStates.ACCEPTED){
        transcript_id_to_revisions[transcript_id].push(revision_id);
    }
    id_to_revision[revision_id] = Revision(
        revision_id,
        transcript_id,
        creator,
        content_uri,
        state,
        true
    );
    address_to_revision[creator].push(revision_id);
    emit revisionCreated(
        revision_id,
        transcript_id,
        creator,
        content_uri,
        state
    );

}

function findRevisionApproved(string[] memory transcript_revisions, string memory revision_uri) private pure returns(bool exists) {
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
    bool revision_approved = findRevisionApproved(transcript_revisions, revision_uri);
    require(revision_approved == true, "Revision has not yet been approved");
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
    transcript_id_to_revisions[transcript_id].push(revision_id);

    emit revisionStateChanged(
        revision_id, transcript_id, revisionStates.ACCEPTED
    );
}

function proposeRevision(bytes32 transcript_id, uint256 updated_time, string memory content_uri) public {
        if (isContributor(transcript_id, msg.sender)){
            id_to_transcription[transcript_id].revision_metadata_uris.push(content_uri);
            createRevision(transcript_id, msg.sender, updated_time, content_uri, revisionStates.ACCEPTED);
        }
        else {
            createRevision(transcript_id, msg.sender, updated_time, content_uri, revisionStates.PENDING);
        }
}

function getProposalsByRequestId(bytes32 request_id ) public view returns(Transcription[] memory) {
    require(id_to_request[request_id].exists == true, "Request does not exist");
    uint256 array_len;
    for (uint256 i; request_id_to_proposals[request_id].length > i; i++){
            array_len += 1;
    }
    Transcription[] memory revisions = new Transcription[](array_len);
    uint256 counter = 0;
    for (uint256 i; request_id_to_proposals[request_id].length > i; i++){

        revisions[counter] = id_to_transcription[request_id_to_proposals[request_id][i]];
        counter += 1;
    }   
    return revisions;
}

function getRevisionsByTranscriptionId(bytes32 transcription_id) public view returns(Revision[] memory) {
    require(id_to_transcription[transcription_id].exists == true, "Request does not exist");
    Revision[] memory revisions = new Revision[](transcript_id_to_revisions[transcription_id].length);
    uint256 counter = 0;
    bytes32[] memory revisions_id_array = transcript_id_to_revisions[transcription_id];
    for (uint256 i; revisions_id_array.length > i; i++){
            revisions[counter] = id_to_revision[revisions_id_array[i]];
            counter += 1;
    }   
    return revisions;
}

}