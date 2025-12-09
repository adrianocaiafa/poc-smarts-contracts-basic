// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleNotes {
    // -------------------------------------------------------------------------
    // STRUCTS
    // -------------------------------------------------------------------------

    struct Note {
        uint256 id;
        address owner;
        string text;
        uint256 createdAt;
        uint256 updatedAt;
        bool deleted;
    }

    // -------------------------------------------------------------------------
    // STORAGE
    // -------------------------------------------------------------------------

    Note[] public notes;

    mapping(address => uint256[]) public noteIdsByOwner;
    mapping(uint256 => uint256) public likes;
    mapping(uint256 => mapping(address => bool)) public hasLiked;
    mapping(address => uint256) public pinnedNoteId;

    // Pause control
    address public owner;
    bool public paused;

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event NoteCreated(uint256 indexed id, address indexed owner, string text);
    event NoteDeleted(uint256 indexed id);
    event NoteLiked(uint256 indexed id, address indexed user, uint256 totalLikes);
    event NotePinned(address indexed user, uint256 indexed noteId);
    event TagAdded(uint256 indexed id, string tag);

    // -------------------------------------------------------------------------
    // MODIFIERS
    // -------------------------------------------------------------------------

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Paused");
        _;
    }

    // -------------------------------------------------------------------------
    // CONSTRUCTOR
    // -------------------------------------------------------------------------

    constructor() {
        owner = msg.sender;
    }

    // -------------------------------------------------------------------------
    // WRITE FUNCTIONS
    // -------------------------------------------------------------------------

    function addNote(string calldata _text) external whenNotPaused {
        uint256 id = notes.length;

        notes.push(
            Note({
                id: id,
                owner: msg.sender,
                text: _text,
                createdAt: block.timestamp,
                updatedAt: block.timestamp,
                deleted: false,
                tags: new string // FIX: cria array vazio corretamente
            })
        );

        noteIdsByOwner[msg.sender].push(id);

        emit NoteCreated(id, msg.sender, _text);
    }

    function deleteNote(uint256 id) external whenNotPaused {
        Note storage note = notes[id];
        require(note.owner == msg.sender, "Not the owner");
        require(!note.deleted, "Already deleted");

        note.deleted = true;
        note.updatedAt = block.timestamp;

        emit NoteDeleted(id);
    }

    function likeNote(uint256 id) external whenNotPaused {
        Note storage note = notes[id];
        require(!note.deleted, "Note deleted");
        require(!hasLiked[id][msg.sender], "Already liked");

        hasLiked[id][msg.sender] = true;
        likes[id] += 1;

        emit NoteLiked(id, msg.sender, likes[id]);
    }

    function pinMyNote(uint256 id) external whenNotPaused {
        Note storage note = notes[id];
        require(note.owner == msg.sender, "Not the owner");
        require(!note.deleted, "Note deleted");

        pinnedNoteId[msg.sender] = id;

        emit NotePinned(msg.sender, id);
    }

    function addTag(uint256 id, string calldata tag) external whenNotPaused {
        Note storage note = notes[id];
        require(note.owner == msg.sender, "Not the owner");
        require(!note.deleted, "Note deleted");

        note.tags.push(tag);

        emit TagAdded(id, tag);
    }

    // -------------------------------------------------------------------------
    // READ FUNCTIONS
    // -------------------------------------------------------------------------

    function getNote(uint256 id) external view returns (Note memory) {
        return notes[id];
    }

    function getMyNotes() external view returns (Note[] memory) {
        uint256[] memory ids = noteIdsByOwner[msg.sender];
        Note[] memory result = new Note[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            result[i] = notes[ids[i]];
        }

        return result;
    }

    function getNotesByOwner(address _owner)
        external
        view
        returns (Note[] memory)
    {
        uint256[] memory ids = noteIdsByOwner[_owner];
        Note[] memory result = new Note[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            result[i] = notes[ids[i]];
        }

        return result;
    }

    function totalNotes() external view returns (uint256) {
        return notes.length;
    }

    function myNotesCount() external view returns (uint256) {
        return noteIdsByOwner[msg.sender].length;
    }

    // -------------------------------------------------------------------------
    // OWNER FUNCTIONS
    // -------------------------------------------------------------------------

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }
}
