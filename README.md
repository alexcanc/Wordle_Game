# Wordle Game

The Wordle game is a word-guessing game where you need to find a target word within a limited number of tries.

## Game Rules

- The target word is a randomly chosen 5-letter word from a dictionary.
- You have 6 tries to guess the target word.
- Guess a word by filling in the squares with letters. Each square represents a letter position in the word.
- When you submit a word, the letters in the squares will change color to indicate their correctness:
  - Green: The letter is correct and in the correct position.
  - Yellow: The letter is correct but in the wrong position.
  - Gray: The letter is incorrect and not in the word at all.
- If you guess the target word correctly, you win the game.
- If you run out of tries without guessing the target word, you lose the game.

## How to Play

- Use the keyboard letters (A-Z) to fill in the squares.
- Press Enter to submit the word.
- Press Backspace to delete the last letter.
- Press Space to restart the game after a win or a game over.

## Launching the Game

To play the Wordle game, you need to have Ruby and the Gosu gem installed on your machine. Here's how to set it up:

1. Install Ruby: If you don't have Ruby installed, visit the [official Ruby website](https://www.ruby-lang.org/en/downloads/) and follow the instructions for your operating system.

2. Install the Gosu gem: Open your terminal and run the following command to install the Gosu gem:

   ```bash
   gem install gosu
   ```
3. Download the source code for the Wordle game.

4. Open your terminal and navigate to the directory containing the game files.

5. Run the following command to launch the game:
  
   ```bash
   ruby wordle_game.rb
   ```
   Make sure you are in the same directory as the wordle_game.rb file.

Enjoy playing the Wordle game! It was made in Ruby using the Gosu gem.
