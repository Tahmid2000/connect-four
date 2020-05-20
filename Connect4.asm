.data
   grid: .byte 0,0,0,0,0,0,0	#the game board
         .byte 0,0,0,0,0,0,0
         .byte 0,0,0,0,0,0,0
         .byte 0,0,0,0,0,0,0
         .byte 0,0,0,0,0,0,0
         .byte 0,0,0,0,0,0,0
   
   rows: .word 6 #Stores how many rows the game board has
   cols: .word 7 #Stores how many columns the game board has
   prompt: .asciiz "Insert a number 0-6: "
   initial: .asciiz "Play Against Computer (Press 1) or Play Against Another Player (Press 0): "
   full: .asciiz "Full Column.\n"
   prompt1: .asciiz "(Player 1) Insert a number 0-6: "
   prompt2: .asciiz "(Player 2) Insert a number 0-6: "
   endl: .asciiz "\n"
   line: .asciiz "|"
   blank: .asciiz "_"
   player: .asciiz "0" #used to represent a player piece
   other: .asciiz "X" #used to represent a computer or player 2 piece
   gridCols: .asciiz " 0 1 2 3 4 5 6 \n"
   count: .word 1 #used to store a count of like-pieces in a row to see if 4 have been reached
   playerWinMessage: .asciiz "You Win! Game over."
   computerWinMessage: .asciiz "You Lose! Game over."
   player1WinMessage: .asciiz "Player 1 Wins! Game over."
   player2WinMessage: .asciiz "Player 2 Wins! Game over."
   inputErr: .asciiz "Player input out of bounds. Try again.\n"
   tie: .asciiz "Its a Tie!"
.text    
   start: #inital starting prompt to choose game mode  
      la $a1, grid
      lw $a2, rows
      lw $a3, cols
      
      #print prompt to ask for game mode and store choice
      li $v0, 4
      la $a0, initial
      syscall
      li $v0, 5
      syscall
      move $t0, $v0
      beqz $t0, initialRoutine #if the user enters 0, 2 player mode
      #if the user does not input a 0 or 1 for the game mode, reprompt
      blt $t0, 0, start
      bgt $t0, 1, start
      
      jal printBoard    
       
   main: #main for player vs. computer
      li $t6, 0
      li $t7, 6 
      
      #prompt user for which column to place piece
      li $v0, 4
      la $a0, prompt
      syscall
      li $v0, 5
      syscall
      move $a0, $v0
      
      #if the user enters a column not between 0 and 6, print error and reprompt 
      blt $a0, $t6, inputError
      bgt $a0, $t7, inputError
      
      #run player's turn and check if player has reached a win or if the game is a tie             
      jal playerMove
      
      jal checkWinHor
      
      jal checkWinVert
      
      jal checkWinDiag
      
      jal checkWinDiag2
      
      jal checkTie
      
      #run computer's turn and check if computer has reached a win or if the game is a tie
      jal computerMove
      
      jal checkWinHor
      
      jal checkWinVert
      
      jal checkWinDiag
      
      jal checkWinDiag2
      
      jal checkTie
      
      jal printBoard
      
      #repeat process until winner or tie
      j main
      
      inputError: #print error if user did not put correct input and reprompt
          li $v0, 4
      	  la $a0, inputErr
          syscall
          j main
          
   initialRoutine: #print initial board and begin game
      jal printBoard   
   main2: #main for player vs. player
      li $t6, 0
      li $t7, 6 
      
      li $v0, 4
      la $a0, prompt1
      syscall
      li $v0, 5
      syscall
      move $a0, $v0
      
      #if player 1 enters a column not between 0 and 6, print error and reprompt  
      blt $a0, $t6, inputError2P1
      bgt $a0, $t7, inputError2P1
      
      #run player 1's turn and check if player 1 has reached a win or if the game is a tie
      jal player1Move
      
      jal checkWinHorP2
      
      jal checkWinVertP2
      
      jal checkWinDiagP2
      
      jal checkWinDiag2P2
      
      jal checkTie
      
      jal printBoard
 
  P2main: #main for player 2  
      li $t6, 0
      li $t7, 6  
      
      li $v0, 4
      la $a0, prompt2
      syscall
      li $v0, 5
      syscall
      move $a0, $v0
      
      #if player 2 enters a column not between 0 and 6, print error and reprompt
      blt $a0, $t6, inputError2P2
      bgt $a0, $t7, inputError2P2        
      
      #run player 2's turn and check if player 2 has reached a win or if the game is a tie
      jal player2Move
      
      jal checkWinHorP2
      
      jal checkWinVertP2
      
      jal checkWinDiagP2
      
      jal checkWinDiag2P2
      
      jal checkTie
      
      jal printBoard
      
      #repeat process until winner or tie
      j main2 
      
      inputError2P1: #print error for incorrect player 1 input and reprompt
          li $v0, 4
      	  la $a0, inputErr
          syscall
          j main2
      
      inputError2P2: #print error for incorrect player 2 input and reprompt
          li $v0, 4
      	  la $a0, inputErr
          syscall
          j P2main  
                            
   playerMove: #run process of player turn against computer
      li $t0, 0    #$t0 is rowIndex
      li $t2, 1    #$t2 has the value that stands for a player move
      loop: #loop to get to empty row of chosen column
         #calculate the index to place the game piece
         mul $t1, $t0, $a3	#$t1 = i*cols
         add $t1, $t1, $a0	#$t1 + colIndex
         add $t1, $t1, $a1	#$t1 + address of grid
         
         lb $t3, ($t1)
         beq $zero, $t3, empty #if the index is empty, place the piece
         addi $t0, $t0, 1 #the index is not empty, go to row above
         blt $t0, $a2, loop #if the column is not full, loop
      
      #the column chosen is full so reprompt for column
      li $v0, 4
      la $a0, full
      syscall
      j main
      
      empty: #place the piece and jump back to main
         sb $t2, ($t1)
         jr $ra
    
         
    player1Move: #run process of player 1's turn
      li $t0, 0    #$t0 is rowIndex
      li $t2, 1    #$t2 has the value that stands for a player move
      loop1: #loop to get to empty row of chosen column
         #calculate the index to place the game piece
         mul $t1, $t0, $a3	#$t1 = i*cols
         add $t1, $t1, $a0	#$t1 + colIndex
         add $t1, $t1, $a1	#$t1 + address of grid
         
         lb $t3, ($t1)
         beq $zero, $t3, empty1 #if the index is empty, place the piece
         addi $t0, $t0, 1 #the index is not empty, go to row above
         blt $t0, $a2, loop1 #if the column is not full, loop
      
      #the column chosen is full so reprompt for column
      li $v0, 4
      la $a0, full
      syscall
      j main2
      
      empty1: #place the piece and jump back to main2
         sb $t2, ($t1)
         jr $ra  
                      
    player2Move: #run process of player 2's turn
      li $t0, 0    #$t0 is rowIndex
      li $t2, 2    #$t2 has the value that stands for a player move
      loopP2: #loop to get the empty row of chosen column
         #calculate the index to place the game piece
         mul $t1, $t0, $a3	#$t1 = i*cols
         add $t1, $t1, $a0	#$t1 + colIndex
         add $t1, $t1, $a1	#$t1 + address of grid
         
         lb $t3, ($t1)
         beq $zero, $t3, empty #if the index is empty, place the piece
         addi $t0, $t0, 1 #the index is not empty, go to row above
         blt $t0, $a2, loopP2 #if the column is not full, loop
      
      #the column chosen is full so reprompt for column
      li $v0, 4
      la $a0, full
      syscall
      j P2main
      
      empty2: #place the piece and jump back to main2
         sb $t2, ($t1)
         jr $ra
         
   computerMove: #run the process for computer's turn
      #generate random number for the computer's move
      li $a1, 6  #Here you set $a1 to the max bound.
      li $v0, 42  #generates the random number.
      syscall
      la $a1, grid
      li $t0, 0    #$t0 is rowIndex
      li $t2, 2    #$t2 has the value that stands for a computer move
      loopC:
         #calculate the index to place the game piece
         mul $t1, $t0, $a3	#$t1 = i*cols
         add $t1, $t1, $a0	#$t1 + colIndex
         add $t1, $t1, $a1	#$t1 + address of grid
         
         lb $t3, ($t1)
         beq $zero, $t3, emptyC #if the index is empty, place the piece
         addi $t0, $t0, 1 #the index is not empty, go to row above
         blt $t0, $a2, loopC #if the column is not full, loop
      
      #column is full so choose new random index for computer
      j computerMove
      
      emptyC: #place the game piece and jump back to main
         sb $t2, ($t1)
         jr $ra
                     
   checkWinHor: #check horizontally if there is a win
      #load count and the last placed piece's index
      lw $t4, count
      move $t5, $t1
      move $t6, $t1
      checkLeft: #check to the left of the piece
         subi $t5, $t5, 1
         
         #if check goes past the left side of the game board, check right
         beq $t5, 0x1000ffff, checkRight
         beq $t5, 0x10010006, checkRight
         beq $t5, 0x1001000D, checkRight
         beq $t5, 0x10010014, checkRight
         beq $t5, 0x1001001B, checkRight
         beq $t5, 0x10010022, checkRight
         
         lb $t9, ($t5)
         bne $t9, $t2, checkRight #if a piece to the left does not match, then check right
         addi $t4, $t4, 1 #piece to the left matches so add to count
         beq $t4 , 4, winC #win has been reached
         j checkLeft #no win yet and left still possible win so loop
      checkRight: #check to the right of the piece
         addi $t6, $t6, 1
         
         #if the check goes past the right side of the game board, no horizontal win
         beq $t6, 0x10010007, noWin
         beq $t6, 0x1001000E, noWin
         beq $t6, 0x10010015, noWin
         beq $t6, 0x1001001C, noWin
         beq $t6, 0x10010023, noWin
         
         lb $t9, ($t6)
         bne $t9, $t2, noWin #if a piece to the right does not match, no horizontal win
         addi $t4, $t4, 1 #piece to the right matches so add to count
         beq $t4, 4, winC #win has been reached
         j checkRight #no win yet and right still possible so loop
       noWin: #no win so jump back to main game function
         jr $ra 
           
     checkWinVert: #check vertically if there is a win
      #load count and the last placed piece's index
      lw $t4, count
      move $t5, $t1
      move $t6, $t1
      checkDown: #check under the piece
         subi $t5, $t5, 7
         blt $t5, 0x10010000, checkUp #if the check goes past first row of game board, check up
         lb $t9, ($t5)
         bne $t9, $t2, checkUp #if the piece under does not match, check up
         addi $t4, $t4, 1 #piece under matches so add to count
         beq $t4 , 4, winC #win has been reached
         j checkDown #no win yet and down still possible so loop
      checkUp: #check above the piece
         addi $t6, $t6, 7
         bgt $t6, 0x10010029, noWin2 #if the check goes past the last row of the game board, no vertical win
         lb $t9, ($t6)
         bne $t9, $t2, noWin2 #if the piece above does not match, no vertical win
         addi $t4, $t4, 1 #piece above matches so add to count
         beq $t4, 4, winC #win has been reached
         j checkUp #no win yet and up still possible so loop
       noWin2: #no win so jump back to main game function
         jr $ra 
      
    checkWinDiag: #check diagonally (bottom left and top right)
      #load count and last placed piece's index
      lw $t4, count
      move $t5, $t1
      move $t6, $t1
      checkDiagD: #check bottom left piece
         subi $t5, $t5, 8
         blt $t5, 0x10010000, checkDiagU #if the check goes past the first row, check top right
         
         #if piece is on the left border of the game board, check top right
         beq $t5, 0x10010006, checkDiagU
         beq $t5, 0x1001000D, checkDiagU
         beq $t5, 0x10010014, checkDiagU
         beq $t5, 0x1001001B, checkDiagU
         
         lb $t9, ($t5)
         bne $t9, $t2, checkDiagU #if the bottom left does not match, check top right
         addi $t4, $t4, 1 #bottom left piece matches so add to count
         beq $t4 , 4, winC #win has been reached
         j checkDiagD #no win yet and bottom left still possible so loop
      checkDiagU: #check top right piece
         addi $t6, $t6, 8
         bgt $t6, 0x10010029, noWin3 #if the check goes past the last row, no diagonal win in this direction
         
         #if piece is on the right border of the game board, no diagonal win in this direction
         beq $t6, 0x1001000E, noWin3
         beq $t6, 0x10010015, noWin3
         beq $t6, 0x1001001C, noWin3
         beq $t6, 0x10010023, noWin3
         
         lb $t9, ($t6)
         bne $t9, $t2, noWin3 #if the top right piece does not match, no diagonal win in this direction
         addi $t4, $t4, 1 #top right piece matches so add to count
         beq $t4, 4, winC #win has been reached
         j checkDiagU #no win yet and top right still possible so loop
       noWin3: #no win so jump back to main game function
         jr $ra
         
    checkWinDiag2: #check bottom right and top left
      #load count and last place piece's index
      lw $t4, count
      move $t5, $t1
      move $t6, $t1
      checkDiagD2: #check bottom right piece
         subi $t5, $t5, 6
         blt $t5, 0x10010000, checkDiagU2 #if the check goes past the first row, check top left
         
         #if piece is on the right border of the game board, no diagonal win in this direction
         beq $t5, 0x10010007, checkDiagU2
         beq $t5, 0x1001000E, checkDiagU2
         beq $t5, 0x10010015, checkDiagU2
         beq $t5, 0x1001001C, checkDiagU2
         beq $t5, 0x10010023, checkDiagU2
         
         lb $t9, ($t5)
         bne $t9, $t2, checkDiagU2 #if the bottom right piece does not match, check top left
         addi $t4, $t4, 1 #bottom right piece matches so add to count
         beq $t4 , 4, winC #win has been reached
         j checkDiagD2 #no win yet and bottom right still possible so loop
      checkDiagU2: #check top left piece
         addi $t6, $t6, 6
         bgt $t6, 0x10010029, noWin4 #if the check goes past the last row check, no diagonal win in this direction
         
         #if piece is on the left border of the game board, no diagonal win in this direction
         beq $t6, 0x10010006, noWin4
         beq $t6, 0x1001000D, noWin4
         beq $t6, 0x10010014, noWin4
         beq $t6, 0x1001001B, noWin4
         beq $t6, 0x10010022, noWin4
         beq $t6, 0x10010029, noWin4
         
         lb $t9, ($t6)
         bne $t9, $t2, noWin4 #if the top left piece does not match, no diagonal win in this direction
         addi $t4, $t4, 1 #top left piece matches so add to count
         beq $t4, 4, winC #win has been reached
         j checkDiagU2 #no win yet and top left possible so loop
       noWin4: #no win so jump back to main game function
         jr $ra 
         
   checkTie: #check if the board is full after no check win returns a win (tie)
   	li $t1, 0x10010023 #the top left index of the game board
      tieLoop: #loop to go through last row
         lb $t3, ($t1)
         beq $zero, $t3, noTie #if there is an empty index on the top row, no tie
         addi $t1, $t1, 1 #no empty index yet so move to next column
         blt $t1, 0x1001002A, tieLoop #if last row not fully traversed, loop
      
      #tie has been reached so print tie and end game
      li $v0, 4
      la $a0, tie
      syscall
      j end
      
      noTie: #no tie so jump back to main game function
         jr $ra
         
   printBoard: #print the board
      move $t0, $a2     #i
      addi $t0, $t0, -1
      li $t1, 1 #1 indicates a player/player 1 piece (0)
      li $t2, 2 #2 indicates a computer/player 2 piece (X)
      li $v0, 4
      la $a0, endl
      syscall
      loopp:
         li $t3, 0     #set j to 0 when looping - starts at first index of the row
         loop2: #loop to print row of the game board
            #calculate index
            mul $t5, $t0, $a3
            add $t5, $t5, $t3
            add $t5, $t5, $a1
            
            #print the border of an index
            li $v0, 4
            la $a0, line
            syscall
            
            lb $t6, ($t5)
            beq $t1, $t6, print0 #if the index is a 1, print a 0
            beq $t2, $t6, printX #if the index is a 2, print a X
            
            print_: #print a blank space in the board (index has no piece)
               li $v0, 4
               la $a0, blank
               syscall
               
               addi $t3, $t3, 1
               blt $t3, $a3, loop2 #if the end of the row not reached, then print next index
               j loop2done #end of row reached
            
            print0: #print a 0 piece
               li $v0, 4
               la $a0, player
               syscall
               
               addi $t3, $t3, 1
               blt $t3, $a3, loop2 #if the end of the row not reached, print next index
               j loop2done #end of row reached
               
            printX: #print a X piece
               li $v0, 4
               la $a0, other
               syscall
               
               addi $t3, $t3, 1
               blt $t3, $a3, loop2 #if the end of the row not reached, print next index
               j loop2done #end of row reached
         
         loop2done: #row completed
            #print last border of the row
            li $v0, 4
            la $a0, line
            syscall
            li $v0, 4
            la $a0, endl
            syscall
            addi $t0, $t0, -1
            bgt $t0, -1, loopp #if there is another row needed to be printed, go to loopp
      
      #once all rows printed, print column option at the bottom and jump back main game function
      li $v0, 4
      la $a0, gridCols
      syscall
      jr $ra
      
  checkWinHorP2: #check horizontally if there is a win
      #load count and the last placed piece's index
      lw $t4, count
      move $t5, $t1
      move $t6, $t1
      checkLeftP2: #check to the left of the piece
         subi $t5, $t5, 1
         
         #if check goes past the left side of the game board, check right
         beq $t5, 0x1000ffff, checkRightP2
         beq $t5, 0x10010006, checkRightP2
         beq $t5, 0x1001000D, checkRightP2
         beq $t5, 0x10010014, checkRightP2
         beq $t5, 0x1001001B, checkRightP2
         beq $t5, 0x10010022, checkRightP2
         
         lb $t9, ($t5)
         bne $t9, $t2, checkRightP2 #if a piece to the left does not match, then check right
         addi $t4, $t4, 1 #piece to the left matches so add to count
         beq $t4 , 4, winP2 #win has been reached
         j checkLeftP2 #no win yet and left still possible win so loop
      checkRightP2: #check to the right of the piece
         addi $t6, $t6, 1
         
         #if the check goes past the right side of the game board, no horizontal win
         beq $t6, 0x10010007, noWinP2
         beq $t6, 0x1001000E, noWinP2
         beq $t6, 0x10010015, noWinP2
         beq $t6, 0x1001001C, noWinP2
         beq $t6, 0x10010023, noWinP2
         
         lb $t9, ($t6)
         bne $t9, $t2, noWinP2 #if a piece to the right does not match, no horizontal win
         addi $t4, $t4, 1 #piece to the right matches so add to count
         beq $t4, 4, winP2 #win has been reached
         j checkRightP2 #no win yet and right still possible so loop
       noWinP2: #no win so jump back to main game function
         jr $ra 
           
     checkWinVertP2: #check vertically if there is a win
      #load count and the last placed piece's index
      lw $t4, count
      move $t5, $t1
      move $t6, $t1
      checkDownP2: #check under the piece
         subi $t5, $t5, 7
         blt $t5, 0x10010000, checkUpP2 #if the check goes past first row of game board, check up
         lb $t9, ($t5)
         bne $t9, $t2, checkUpP2 #if the piece under does not match, check up
         addi $t4, $t4, 1 #piece under matches so add to count
         beq $t4 , 4, winP2 #win has been reached
         j checkDownP2 #no win yet and down still possible so loop
      checkUpP2: #check above the piece
         addi $t6, $t6, 7
         bgt $t6, 0x10010029, noWin2P2 #if the check goes past the last row of the game board, no vertical win
         lb $t9, ($t6)
         bne $t9, $t2, noWin2P2 #if the piece above does not match, no vertical win
         addi $t4, $t4, 1 #piece above matches so add to count
         beq $t4, 4, winP2 #win has been reached
         j checkUpP2 #no win yet and up still possible so loop
       noWin2P2: #no win so jump back to main game function
         jr $ra 
      
    checkWinDiagP2: #check diagonally (bottom left and top right)
      #load count and last placed piece's index
      lw $t4, count
      move $t5, $t1
      move $t6, $t1
      checkDiagDP2: #check bottom left piece
         subi $t5, $t5, 8
         blt $t5, 0x10010000, checkDiagUP2 #if the check goes past the first row, check top right
         
         #if piece is on the left border of the game board, check top right
         beq $t5, 0x10010006, checkDiagUP2
         beq $t5, 0x1001000D, checkDiagUP2
         beq $t5, 0x10010014, checkDiagUP2
         beq $t5, 0x1001001B, checkDiagUP2
         
         lb $t9, ($t5)
         bne $t9, $t2, checkDiagUP2 #if the bottom left does not match, check top right
         addi $t4, $t4, 1 #bottom left piece matches so add to count
         beq $t4 , 4, winP2 #win has been reached
         j checkDiagDP2 #no win yet and bottom left still possible so loop
      checkDiagUP2: #check top right piece
         addi $t6, $t6, 8
         bgt $t6, 0x10010029, noWin3P2 #if the check goes past the last row, no diagonal win in this direction
         
         #if piece is on the right border of the game board, no diagonal win in this direction
         beq $t6, 0x1001000E, noWin3P2
         beq $t6, 0x10010015, noWin3P2
         beq $t6, 0x1001001C, noWin3P2
         beq $t6, 0x10010023, noWin3P2
         
         lb $t9, ($t6)
         bne $t9, $t2, noWin3P2 #if the top right piece does not match, no diagonal win in this direction
         addi $t4, $t4, 1 #top right piece matches so add to count
         beq $t4, 4, winP2 #win has been reached
         j checkDiagUP2 #no win yet and top right still possible so loop
       noWin3P2: #no win so jump back to main game function
         jr $ra
         
    checkWinDiag2P2: #check bottom right and top left
      #load count and last place piece's index
      lw $t4, count
      move $t5, $t1
      move $t6, $t1
      checkDiagD2P2: #check bottom right piece
         subi $t5, $t5, 6
         blt $t5, 0x10010000, checkDiagU2P2 #if the check goes past the first row, check top left
         
       	 #if piece is on the right border of the game board, no diagonal win in this direction
         beq $t5, 0x10010007, checkDiagU2P2
         beq $t5, 0x1001000E, checkDiagU2P2
         beq $t5, 0x10010015, checkDiagU2P2
         beq $t5, 0x1001001C, checkDiagU2P2
         beq $t5, 0x10010023, checkDiagU2P2
       	
         lb $t9, ($t5)
         bne $t9, $t2, checkDiagU2P2 #if the bottom right piece does not match, check top left
         addi $t4, $t4, 1 #bottom right piece matches so add to count
         beq $t4 , 4, winP2 #win has been reached
         j checkDiagD2P2 #no win yet and bottom right still possible so loop
      checkDiagU2P2: #check top left piece
         addi $t6, $t6, 6
         bgt $t6, 0x10010029, noWin4P2 #if the check goes past the last row check, no diagonal win in this direction
         
         #if piece is on the left border of the game board, no diagonal win in this direction
         beq $t6, 0x10010006, noWin4
         beq $t6, 0x1001000D, noWin4
         beq $t6, 0x10010014, noWin4
         beq $t6, 0x1001001B, noWin4
         beq $t6, 0x10010022, noWin4
         beq $t6, 0x10010029, noWin4
         
         lb $t9, ($t6)
         bne $t9, $t2, noWin4P2 #if the top left piece does not match, no diagonal win in this direction
         addi $t4, $t4, 1 #top left piece matches so add to count
         beq $t4, 4, winP2 #win has been reached
         j checkDiagU2P2 #no win yet and top left possible so loop
       noWin4P2: #no win so jump back to main game function
         jr $ra
                
 winC: #Print a winner for player vs. computer
         jal printBoard
       	 beq $t9, 1, playerWin3 #if the winner is the player, print player win
       	 
       	 #print computer win and end the game
         li $v0, 4
         la $a0, computerWinMessage
         syscall
         j end
         
       	 playerWin3: #print player win and end the game
           li $v0, 4
           la $a0, playerWinMessage
           syscall
           j end     
                 
winP2: #Print winner for player 1 vs. player 2 
         jal printBoard
       	 beq $t9, 1, playerWin4P2 #if the winner is player 1, print player 1 win
       	 
       	 #print player 2 win and end the game
         li $v0, 4
         la $a0, player2WinMessage
         syscall
         j end
         
       	 playerWin4P2: #print player 1 win and end the game
           li $v0, 4
           la $a0, player1WinMessage
           syscall
           j end
                         
end: #end the game
  li $v0, 10
  syscall
