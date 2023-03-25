#Grimoire
This repository contains a smart contract written in Solidity called Grimoire. The Grimoire contract facilitates the creation and management and emitting events of transcriptions, revisions and requests related to the transcript.


##Table of contents
Installation
Usage
Contract API
License
Installation
To interact with Grimoire smart contract, you need to install a web3 provider like Metamask and an Ethereum wallet like Ganache. Once you have them installed, you can connect to the Grimoire contract address on the Ethereum network and start using it.

##Usage
To use Grimoire, you can interact with the contract functions using a web3 provider like Metamask. Here's an example of how you can use Grimoire to create a transcript:

First, you need to create a request by calling the createRequest function, providing the metadata URI and an array of collaborators Ethereum addresses.
Once the request is created, you can create a transcription by calling the createTranscription function, providing the created request's ID, the metadata URI of the transcript, an array of contributors' Ethereum addresses, and an array of communities.
You can then create a revision of the transcription by calling the createRevision function, providing the ID of the transcription, the content URI of the revision.
Finally, you can update the state of the request by calling the updateRequestStatus function, providing the ID of the request, and the new status of the receiving_transcripts and fulfilled variables.
##Contract API

###Events
The Grimoire contract emits the following events:

**transcriptCreated**: emitted when a new transcript is created, with the transcript ID, creation and last updated timestamps, creator and contributors Ethereum addresses, revision metadata URIs, metadata URI, ID request, and communities array.
**transcriptDeleted**: emitted when a transcript is deleted, with the transcript ID.
**transcriptApproved**: emitted when a transcript is approved, with the request ID, transcript ID, and collaborator Ethereum address.
**requestCreated**: emitted when a new request is created, with the request ID, creation and last updated timestamps, creator Ethereum address, receiving_transcripts and fulfilled booleans, metadata URI, and collaborators Ethereum addresses array.
**requestStateUpdate**: emitted when the state of a request is updated on whether it still needs a transcript, with the request ID, receiving_transcripts and fulfilled booleans.
**requestDeleted**: emitted when a request is deleted, with the request ID.
**revisionCreated**: emitted when a new revision is created, with the revision ID, transcript ID, creator Ethereum address, content URI, and revision state.
**revisionStateChanged**: emitted when the state of a revision is changed, with the revision ID, transcript ID, and new revision state.

##Functions
The Grimoire contract provides the following functions:

**createRequest**: creates a new request, with the metadata URI and collaborators Ethereum addresses array.
**createTranscription**: creates a new transcript, with the ID of the request it belongs to, the metadata URI, contributors Ethereum addresses array, and communities array.
**createRevision**: creates a new revision, with the ID of the transcript it belongs to, the content URI, and the revision state.
**updateRequestStatus**: updates the state of a request, with the request ID and the new status of the receiving_transcripts and fulfilled booleans.
**getRequest**: retrieves the details of a request, with the request ID.
**deleteRequest**: deletes a request, with the request ID.
**updateRevisionState**: Updates the state of the revision state to be either accepted or rejected, if it is accepted, the revisions content_uri will be added to transcripts revision_metadata_uris, it is called by using the revisions ID, the transcripts ID and revisions new state.
**getRevisions**: This function returns the revision associated with the provided ID.

License
This project is licensed under the GNU General Public License v3.0