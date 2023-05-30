module slime_wars::game {
    use std::vector;

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};


    // ======== Constants ========
    const EMPTY_MARK: u8 = 0;
    
    // Game status
    const GAME_IN_PROGRESS: u8 = 0;
    const PLAYER_ONE_WIN: u8 = 1;
    const PLAYER_TWO_WIN: u8 = 2;
    const DRAW: u8 = 3;

    // ======== Errors ========
    const EInvalidTurn: u64 = 0;
    const EGameEnded: u64 = 1;
    const EInvalidLocation: u64 = 2;
    const ECellInvalid: u64 = 3;
    const ECellOccupied: u64 = 4;

    // ======== Types ========
    struct GameBoard has key {
        id: UID,
        game_board: vector<vector<u8>>,
        game_status: u8,
        current_turn: u8,
        player_one: address,
        player_two: address,
    }

    // ======== Functions =========
    entry fun create_game(player_one: address, player_two: address, ctx: &mut TxContext) {
        let board_id = object::new(ctx);
        // 7 x 7 board
        let board = vector[
            vector[0, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, 1],
            vector[EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK],
            vector[EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK],
            vector[EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK],
            vector[EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK],
            vector[EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK],
            vector[1, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, EMPTY_MARK, 0],
        ];

        let game_board = GameBoard {
            id: board_id,
            game_board: board,
            game_status: GAME_IN_PROGRESS,
            current_turn: 0,
            player_one: player_one,
            player_two: player_two,
        };

        transfer::share_object(game_board);
    }

    entry fun place_mark(game: &mut GameBoard, from_row: u8, from_col: u8, to_row: u8, to_col: u8, ctx: &mut TxContext) {
        // Pre validation
        assert!(from_row < 7 && from_col < 7, EInvalidLocation);
        assert!(to_row < 7 && to_col < 7, EInvalidLocation);
        assert!(game.game_status == GAME_IN_PROGRESS, EGameEnded);
        let player_address = get_turn_players_address(game);
        assert!(player_address == tx_context::sender(ctx), EInvalidTurn);
        let player_mark = game.current_turn % 2;

        // Get from and to cells
        let from_row_borrow = *vector::borrow_mut(&mut game.game_board, (from_row as u64));
        let to_row_borrow = *vector::borrow_mut(&mut game.game_board, (to_row as u64));
        let from_cell = vector::borrow_mut(&mut from_row_borrow, (from_col as u64));
        let to_cell = vector::borrow_mut(&mut to_row_borrow, (to_col as u64));

        // Validate mark placement
        // Mark can be placed one or two cell away (any direction including diagonals) to an unoccupied cell.
        // If one cell away then a new mark is created and all surrounding opposing marks are converted to the player's mark.
        // If two cells away then the mark is moved to the new location, and all surrounding marks are converted to the player's mark.
        assert!(*from_cell == player_mark, ECellInvalid);
        assert!(*to_cell == EMPTY_MARK, ECellOccupied);
        // one cell movement
        // asser

        *to_cell = player_mark;

        game.current_turn = game.current_turn + 1;

    }

    fun get_turn_players_address(game: &GameBoard): address {
        if (game.current_turn % 2 == 0) {
            game.player_one
        } else {
            game.player_two
        }
    }

    // fun update_game_board(game: &mut GameBoard, )
}
