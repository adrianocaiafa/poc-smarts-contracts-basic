// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleNotes {
    // -------------------------------------------------------------------------
    // STRUCTS
    // -------------------------------------------------------------------------

    struct Note {
        uint64 id;
        uint64 createdAt;
        uint64 updatedAt;
        bool deleted;
        bool archived;
        bool isPublic;
        address owner;
        string text;
    }

    // -------------------------------------------------------------------------
    // STORAGE
    // -------------------------------------------------------------------------

    Note[] public notes;

    mapping(address => uint256[]) public noteIdsByOwner;
    mapping(uint256 => uint256) public likes;
    mapping(uint256 => mapping(address => bool)) public hasLiked;
    mapping(address => uint256) public pinnedNoteId;

    address public owner;
    bool public paused;

    // -------------------------------------------------------------------------
    // EVENTS
    // -------------------------------------------------------------------------

    event NoteCreated(uint256 indexed id, address indexed owner, string text);
    event NoteDeleted(uint256 indexed id);
    event NoteLiked(uint256 indexed id, address indexed user, uint256 totalLikes);
    event NotePinned(address indexed user, uint256 indexed noteId);
    event NoteArchived(uint256 indexed id);
    event NoteUnarchived(uint256 indexed id);
    event NoteVisibilityChanged(uint256 indexed id, bool isPublic);

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
                id: uint64(id),
                createdAt: uint64(block.timestamp),
                updatedAt: uint64(block.timestamp),
                deleted: false,
                archived: false,
                isPublic: true,
                owner: msg.sender,
                text: _text
            })
        );

        noteIdsByOwner[msg.sender].push(id);

        emit NoteCreated(id, msg.sender, _text);
    }

    function deleteNote(uint256 _id) external whenNotPaused {
        Note storage note = notes[_id];
        require(note.owner == msg.sender, "Not the owner");
        require(!note.deleted, "Already deleted");

        note.deleted = true;
        note.updatedAt = uint64(block.timestamp);

        emit NoteDeleted(_id);
    }

    function likeNote(uint256 _id) external whenNotPaused {
        Note storage note = notes[_id];
        require(!note.deleted, "Note deleted");
        require(!hasLiked[_id][msg.sender], "Already liked");

        hasLiked[_id][msg.sender] = true;
        likes[_id] += 1;

        emit NoteLiked(_id, msg.sender, likes[_id]);
    }

    function pinMyNote(uint256 _id) external whenNotPaused {
        Note storage note = notes[_id];
        require(note.owner == msg.sender, "Not the owner");
        require(!note.deleted, "Note deleted");

        pinnedNoteId[msg.sender] = _id;

        emit NotePinned(msg.sender, _id);
    }

    function archiveNote(uint256 _id) external whenNotPaused {
        Note storage note = notes[_id];
        require(note.owner == msg.sender, "Not the owner");
        require(!note.deleted, "Note deleted");
        require(!note.archived, "Already archived");

        note.archived = true;
        note.updatedAt = uint64(block.timestamp);

        emit NoteArchived(_id);
    }

    function unarchiveNote(uint256 _id) external whenNotPaused {
        Note storage note = notes[_id];
        require(note.owner == msg.sender, "Not the owner");
        require(note.archived, "Not archived");
        require(!note.deleted, "Note deleted");

        note.archived = false;
        note.updatedAt = uint64(block.timestamp);

        emit NoteUnarchived(_id);
    }

    function setVisibility(uint256 _id, bool _isPublic) external whenNotPaused {
        Note storage note = notes[_id];
        require(note.owner == msg.sender, "Not the owner");
        require(!note.deleted, "Note deleted");

        note.isPublic = _isPublic;
        note.updatedAt = uint64(block.timestamp);

        emit NoteVisibilityChanged(_id, _isPublic);
    }

    // -------------------------------------------------------------------------
    // READ FUNCTIONS
    // -------------------------------------------------------------------------

    function getNote(uint256 _id) external view returns (Note memory) {
        return notes[_id];
    }

    function getMyNotes() external view returns (Note[] memory) {
        uint256[] memory ids = noteIdsByOwner[msg.sender];
        uint256 len = ids.length;
        Note[] memory result = new Note[](len);

        for (uint256 i; i < len; ) {
            result[i] = notes[ids[i]];
            unchecked {
                ++i;
            }
        }

        return result;
    }

    function getNotesByOwner(address _owner)
        external
        view
        returns (Note[] memory)
    {
        uint256[] memory ids = noteIdsByOwner[_owner];
        uint256 len = ids.length;
        Note[] memory result = new Note[](len);

        for (uint256 i; i < len; ) {
            result[i] = notes[ids[i]];
            unchecked {
                ++i;
            }
        }

        return result;
    }

    function totalNotes() external view returns (uint256) {
        return notes.length;
    }

    function myNotesCount() external view returns (uint256) {
        return noteIdsByOwner[msg.sender].length;
    }

    function getActiveNotesByOwner(address _owner)
        external
        view
        returns (Note[] memory)
    {
        uint256[] memory ids = noteIdsByOwner[_owner];
        uint256 len = ids.length;
        // Primeiro conta quantas notas estão ativas
        uint256 count;
        for (uint256 i = 0; i < len; i++) {
            Note storage n = notes[ids[i]];
            if (!n.deleted && !n.archived) {
                count++;
            }
            unchecked {
                ++i;
            }
        }

        // Agora monta o array final
        Note[] memory result = new Note[](count);
        uint256 index;

        for (uint256 i = 0; i < len; i++) {
            Note storage n = notes[ids[i]];
            if (!n.deleted && !n.archived) {
                result[index] = n;
                index++;
            }
            unchecked {
                ++i;
            }
        }

        return result;
    }

    function getPublicNotesByOwner(address _owner)
        external
        view
        returns (Note[] memory)
    {
        uint256[] memory ids = noteIdsByOwner[_owner];
        uint256 len = ids.length;

        // Conta quantas são públicas (e não deletadas)
        uint256 count;
        for (uint256 i = 0; i < len; i++) {
            Note storage n = notes[ids[i]];
            if (!n.deleted && n.isPublic) {
                count++;
            }
            unchecked {
                ++i;
            }
        }

        Note[] memory result = new Note[](count);
        uint256 index;

        for (uint256 i = 0; i < len; i++) {
            Note storage n = notes[ids[i]];
            if (!n.deleted && n.isPublic) {
                result[index] = n;
                index++;
            }
            unchecked {
                ++i;
            }
        }

        return result;
    }
    // -------------------------------------------------------------------------
    // OWNER FUNCTIONS
    // -------------------------------------------------------------------------

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }
}
