# Grimoire
This repository contains a smart contract written in Solidity called Grimoire. The Grimoire contract facilitates the creation and management and emitting events of transcriptions, revisions and requests related to the transcript.

To interact with Grimoire smart contract, you need to have a web3 wallet like Metamask. Once you have it installed, you can connect to the Grimoire contract address and start using it.

## Usage
To use Grimoire, you can interact with the contract functions using a web3 provider like Metamask. Here's an example of how you can use Grimoire to create a transcript:

* Create a request by calling the createRequest function, providing the metadata URI and an array of collaborators Ethereum addresses.

* Create a transcription by calling the createTranscription function, providing the created request's ID, the metadata URI of the transcript, an array of contributors' Ethereum addresses, and an array of communities.

* Create a revision of the transcription by calling the createRevision function, providing the ID of the transcription, the content URI of the revision.

* Update the state of the request by calling the updateRequestStatus function, providing the ID of the request, and the new status of the receiving_transcripts and fulfilled variables.

**This is only an example, a transcription can be created WITHOUT a request!**


## Get started

* `gh repo clone grimoiredotxyz/smartContracts`
* `npm install`
* `npm init`
* `npm install --save-dev hardhat`
* `npx hardhat compile`
* `npm install dotenv --save` In .env get your private key from your wallet (be carefull not to accidentally push it to your github ) put it into the variable named STAGING_PRIVATE_KEY, if you are going to use Mumbai also create STAGING_INFURA_URL with the url of your Infura API and/or API_URL for goerli 
* `npx hardhat run scripts/deploy.ts --network [one of the networks specified in hardhat.config.ts]`

## Contract API


### Events
The Grimoire contract emits the following events:

**transcriptCreated**: emitted when a new transcript is created, with the transcript ID, creation and last updated timestamps, creator and contributors Ethereum addresses, revision metadata URIs, metadata URI, ID request, and communities array.

**transcriptDeleted**: emitted when a transcript is deleted, with the transcript ID.

**transcriptApproved**: emitted when a transcript is approved, with the request ID, transcript ID, and collaborator Ethereum address.

**requestCreated**: emitted when a new request is created, with the request ID, creation and last updated timestamps, creator Ethereum address, receiving_transcripts and fulfilled booleans, metadata URI, and collaborators Ethereum addresses array.

**requestStateUpdate**: emitted when the state of a request is updated on whether it still needs a transcript, with the request ID, receiving_transcripts and fulfilled booleans.

**requestDeleted**: emitted when a request is deleted, with the request ID.

**revisionCreated**: emitted when a new revision is created, with the revision ID, transcript ID, creator Ethereum address, content URI, and revision state.

**revisionStateChanged**: emitted when the state of a revision is changed, with the revision ID, transcript ID, and new revision state.


## Functions
The Grimoire contract provides the following functions:

**createRequest**: creates a new request, with the metadata URI and collaborators Ethereum addresses array.

**createTranscription**: creates a new transcript, with the ID of the request it belongs to, the metadata URI, contributors Ethereum addresses array, and communities array.

**createRevision**: creates a new revision, with the ID of the transcript it belongs to, the content URI, and the revision state.

**updateRequestStatus**: updates the state of a request, with the request ID and the new status of the receiving_transcripts and fulfilled booleans.

**getRequest**: retrieves the details of a request, with the request ID.

**deleteRequest**: deletes a request, with the request ID.

**updateRevisionState**: Updates the state of the revision state to be either accepted or rejected, if it is accepted, the revisions content_uri will be added to transcripts revision_metadata_uris, it is called by using the revisions ID, the transcripts ID and revisions new state.

**getRevisions**: This function returns the revision associated with the provided ID.

**getRevisionsByTranscriptionId**: Gets all the proposals made for a specific transcription request. It takes in a bytes32 type parameter called request_id. If the request exists, the function retrieves all the transcription IDs associated with the request and returns an array of Transcription objects. Each Transcription object represents a proposal made for the transcription request.

**getRevisionsByTranscriptionId**: Gets all the revisions, with a specific state made for a specific transcription proposal. It takes in two parameters - transcriptions ID, and  state, which is the state of the revisions to be retrieved. If the proposal exists, the function retrieves all the revision IDs associated with the proposal and the state specified and returns an array of Revision objects.


## Current testnet chains where it is deployed
* Polygon Mumbai -> 0xD9f939e8eCD876Ca0908E8CE35C109161488E895 -> https://mumbai.polygonscan.com/address/0xD9f939e8eCD876Ca0908E8CE35C109161488E895
* Gnosis Chiado -> 0x92C410556C7AeD3C9aa6ED3552431C876770FF99 -> https://repo.sourcify.dev/contracts/full_match/10200/0x92C410556C7AeD3C9aa6ED3552431C876770FF99/ 
* Optimism Goerli -> 0x239b986D8B3bAB3e89D9586a5D83c5C0B08Fc3D3 -> https://repo.sourcify.dev/contracts/full_match/420/0x239b986D8B3bAB3e89D9586a5D83c5C0B08Fc3D3/
* Scroll Alpha tesnet -> 0xF91F71e2AB73a5298CAb2aD8df0EBE6e176961Ce -> https://blockscout.scroll.io/address/0xF91F71e2AB73a5298CAb2aD8df0EBE6e176961Ce
* Filecoin Hyperspace -> 0xB293049B4940C3AF4191C8b03f79C8c0e5B39199 -> https://w3s.link/ipfs/bafkreighmwwfhnothnmw53y2fz5xesjr5d7lpxz5oavcg5h76geg42dp4m


## License
This project is licensed under the GNU General Public License v3.0