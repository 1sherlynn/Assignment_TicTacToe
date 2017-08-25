#Pseudo Code 
#
#Used calls to clear the console and re-draw the screen (puts "\e[H\e[2J")
#
#Keeps score of how many rounds each player has won, and automatically toggles between p1 or p2 going first, to make sure the starting advantage is spread out evenly. 
#
#Design right now only recognizes a draw when there are no more possible moves to make. Ideally it should be recognizing drawn games that can happen prior to a full board.
#
#1. Game class 
#- methods: initialize, main_menu, main_loop 
#- primary loop class, entry point and conductor.
#- controls the game-state, loops to progress through turns
#- defines the overall program flow
#- game score/stats are tracked 
#
#
#2. GameBoard class 
#- methods: initialize, print_board, place_marker, check_winner
#- contains everything needed to set up the board
#- keep track of the board-state
#- place markers on the board
#- check for a win or a tie
#
#3. View class 
#- methods: main_menu, invalid_entry, player_info, instructions, game_state, final_score
#- screen output for the user 
#
# 4. Player class 
#- methods: initialize, id, name, marker
#- simple player info, like name and symbol


class Game

  def initialize
    @view = View.new
    @score = { rounds_played: 0, turns: 0, drawn: 0, p1: 0, p2: 0}
    @continue_game = true
    @continue_round = true

    puts "\e[H\e[2J"
    main_menu
  end


  def main_menu
    @view.main_menu
    selection = gets.chomp 

    if selection == "1" 
      @view.player_info(1)
      name = gets.chomp
      @player_one = Player.new(:p1, name, "X")
      
      @view.player_info(2)
      name = gets.chomp
      @player_two = Player.new(:p2, name, "O")
      
      @view.instructions
      print "Enter how many rounds to play: "
      @max_rounds = gets.chomp
      
      main_loop
    elsif selection == "2"
      abort("Thanks for playing!") 
    else 
      @view.invalid_entry # Notify user
      sleep 1
      main_menu; end 
  end


  def main_loop
    
    @continue_game = true

    while @continue_game

    
      @board = GameBoard.new      
      
      @score[:turns] = 0
      @score[:drawn] = 0
      @score[:p1] = 0
      @score[:p2] = 0
      #
      @score[:rounds_played] % 2 != 0 ? @active_player = @player_two : @active_player = @player_one

      @continue_round = true
      
      while @continue_round

        @score[:turns] += 1

        # The game view will repeat continuously each turn until a valid move is chosen
        valid_input = false
        until valid_input
          # Refresh the game view
          @view.game_state(@board, @score)
          print " #{@active_player.name}'s turn. Select (1-9): "
          location = gets.chomp
          # Check the input for validity
          if location.to_i.between?(1,9)
            valid_input = true
            # If we have valid input, try to place the marker, if occupied, invalidate input
            if @board.place_marker(location.to_i, @active_player.marker) == "occupied"
              puts "This spot is already occupied. Try another spot."
              valid_input = false
              sleep 1; end
          else
            puts "Invalid entry, please try again."
            sleep 1; end
        end

        # Update game view after new marker is placed
        @view.game_state(@board, @score)

        # Check for winner as soon as it becomes possible
        if @score[:turns] > 3
          if @board.check_winner == @player_one.marker || @board.check_winner == @player_two.marker
            @score[@active_player.id] += 1
            @continue_round = false
            puts "#{@active_player.name} is the winner!!"
            sleep 1; end
        end

        # If we've managed to hit the end of the 9th turn without a winner, it's a draw
        if @score[:turns] == 9 && @continue_round == true
          @score[:drawn] += 1
          @continue_round = false
          puts "It's a Draw!"
          sleep 1; end

        # At the end of each turn, swap out active player in preparation for the next turn
        @active_player == @player_one ? @active_player = @player_two : @active_player = @player_one
      end

      # Increase game count
      @score[:rounds_played] += 1
      @continue_game = false if @score[:rounds_played] >= @max_rounds.to_i

    end

    game_winner = ".. no one!" # default, used if it's a tie
    game_winner = @player_one.name if @score[:p1] > @score[:p2]
    game_winner = @player_two.name if @score[:p2] > @score[:p1]
    
    # Show the results
    @view.final_score(game_winner, @score)  
    
    # Return back to the main menu
    sleep 5
    main_menu
  end

end


class GameBoard

  # Ready an empty board
  def initialize
    @board = { 1 => "_", 2 => "_", 3 => "_",
               4 => "_", 5 => "_", 6 => "_",
               7 => "_", 8 => "_", 9 => "_" }
  end

  def print_row(row = nil)

    return "|#{@board[1]}|#{@board[2]}|#{@board[3]}|" if row == 1
    return "|#{@board[4]}|#{@board[5]}|#{@board[6]}|" if row == 2
    return "|#{@board[7]}|#{@board[8]}|#{@board[9]}|" if row == 3
  end

  # Handles converting an empty space into a player's marker, if the space is taken
  # the method will leave it unchanged and return a notification
  def place_marker(location, marker)
    if @board[location] == "_"
      @board[location] = marker
    else
      return "occupied"; end
  end


  def check_winner(winner = nil)
    # Check rows
    (1..9).step(3) do |i|
      if @board[i] == @board[i+1] && @board[i] == @board[i+2]
        return winner = @board[i]; end; end

    # Check columns
    for i in 1..3
      if @board[i] == @board[i+3] && @board[i] == @board[i+6]
        return winner = @board[i]; end; end

    # Check top left - bottom right diag
    if @board[1] == @board[5] && @board[1] == @board[9]
      return winner = @board[1]; end

    # Check top right - bottom left diag
    if @board[3] == @board[5] && @board[3] == @board[7]
      return winner = @board[3]; end
  end

end

class View

  # The first thing the user sees
  def main_menu
    puts "\e[H\e[2J"
    puts "HELLO AND WELCOME!"
    puts "Find a friend to play a game of TIC-TAC-TOE."
    puts "{Human vs Human version}"
    puts ""
    puts ""
    puts ""
    puts "Press 1 to play a NEW GAME"
    puts "Press 2 to EXIT"
    puts ""
    puts ""
    print"Please select (press 1 or 2):"; end

  # Main menu error variant
 def invalid_entry
    puts "\e[H\e[2J"
    puts "HELLO AND WELCOME!"
    puts "Find a friend to play a game of TIC-TAC-TOE."
    puts "{Human vs Human version}"
    puts ""
    puts ""
    puts ""
    puts "Press 1 to play a NEW GAME"
    puts "Press 2 to EXIT"
    puts ""
    puts ""
    print"This is an invalid entry. Press (1-9)! "; end

  # Assigning symbols and taking names
  def player_info(player)
    puts "\e[H\e[2J"
    puts "Player #{player}"
    puts ""
    puts ""
    puts ""
    if player == 1
      puts "Your symbol will be X"
    elsif player == 2
      puts "Your symbol will be O."; end
    puts ""
    puts ""
    puts ""
    puts ""
    print "Please enter Player #{player}'s name:"; end

  # This screen runs briefly after the creation of a new game/players
  def instructions
    puts "\e[H\e[2J"
    puts "Instructions:"
    puts ""
    puts "In order to win, form a consecutive line of X-X-X or O-O-O"
    puts ""
    puts "The line can be vertical or horizontal or diagonal"
    puts ""
    puts "If no consecutive line is formed, it will be a tie"
    puts ""
    puts "    |1|2|3|     To make your move:     "
    puts "    |4|5|6|     Press numbers 1-9"
    puts "    |7|8|9|"
    puts ""; end

  # This is the primary gameplay screen that updates each turn
  def game_state(board, score)
    puts "\e[H\e[2J"
    puts "Tic-Tac-Toe"
    puts " "
    puts "Rounds played: #{score[:rounds_played]};   Turn: #{score[:turns]}"
    puts " "
    puts " "
    puts "           Board    "
    puts ""
    puts "|1|2|3|   #{board.print_row(1)}    "
    puts "|4|5|6|   #{board.print_row(2)}    "
    puts "|7|8|9|   #{board.print_row(3)}    "
    puts ""; end

  # Once the game is complete, a quick readout of the results
  def final_score(winner, score)
    puts "\e[H\e[2J"
    puts "The game is now over."
    puts " "
    puts "       Best of #{score[:rounds_played]} Rounds"
    puts "      "
    puts "        Player1:  #{score[:p1]}   Player 2:  #{score[:p2]}"
    puts "          Drawn:  #{score[:drawn]}"
    puts "     "
    puts "The winner is #{winner}!"; end
end


class Player

  def initialize(id, name, marker)
    @id = id
    @name = name
    @marker = marker
  end

  def id
    return @id
  end

  def name
    return @name
  end

  def marker
    return @marker
  end
end


thisgame = Game.new