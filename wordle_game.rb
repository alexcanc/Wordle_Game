require 'gosu'

class WordleGame < Gosu::Window
  def initialize
    super 900, 700
    self.caption = "Wordle Game"

    @font_title = Gosu::Font.new(60)
    @font_letters = Gosu::Font.new(40)
    @font_text = Gosu::Font.new(20)

    @title_offset_y = 20
    @square_size = 60
    @start_x = (self.width - 5 * @square_size - 40) / 2
    @start_y = (self.height - 6 * @square_size - 50) / 2 + 5

    @target_word = "HELLO"
    @current_row = 0
    @current_position = 0
    @letters_to_draw = Array.new(30) { { letter: "", color: Gosu::Color::WHITE } }
    @tries_remaining = 6
    @game_over = false

    @keyboard_letters = ("A".."Z").to_a
  end

  def draw
    # Draw title
    title_text = "Wordle"
    title_x = (self.width - @font_title.text_width(title_text)) / 2
    title_y = @title_offset_y
    @font_title.draw_text(title_text, title_x, title_y, 0)

    # Draw squares
    @letters_to_draw.each_with_index do |letter, index|
      i = index / 5
      j = index % 5
      x = @start_x + j * (@square_size + 10)
      y = @start_y + i * (@square_size + 10)

      color = letter[:color]
      Gosu.draw_rect(x, y, @square_size, @square_size, color, z = 0)
      draw_letter_in_square(letter[:letter], x, y, color) if letter[:letter]
    end

    # Draw tries remaining
    tries_text = "Tries Remaining: #{@tries_remaining}"
    tries_x = (self.width - @font_text.text_width(tries_text)) / 2
    tries_y = self.height - 50
    @font_text.draw_text(tries_text, tries_x, tries_y, 0)

    # Draw game over message
  if @game_over
    game_over_text = @win ? "Congratulations!" : "Game Over"
    restart_text = "Press SPACE to restart"

    game_over_width = @font_title.text_width(game_over_text)
    restart_width = @font_text.text_width(restart_text)

    box_width = [game_over_width, restart_width].max + 2 * 10
    box_height = @font_title.height + @font_text.height + 3 * 10

    box_x = (self.width - box_width) / 2
    box_y = (self.height - box_height) / 2

    Gosu.draw_rect(box_x, box_y, box_width, box_height, Gosu::Color::BLACK, z = 1)

    game_over_x = box_x + (box_width - game_over_width) / 2
    game_over_y = box_y + 10
    @font_title.draw_text(game_over_text, game_over_x, game_over_y, 1, 1, 1, Gosu::Color::WHITE)

    restart_x = box_x + (box_width - restart_width) / 2
    restart_y = game_over_y + @font_title.height + 10
    @font_text.draw_text(restart_text, restart_x, restart_y, 1, 1, 1, Gosu::Color::WHITE)

    return # Exit the method to prevent displaying the win message
  end
  end


  def draw_letter_in_square(letter, x, y, color)
    text_x = x + (@square_size - @font_letters.text_width(letter)) / 2
    text_y = y + (@square_size - @font_letters.height) / 2

    case color
    when Gosu::Color::GREEN
      background_color = Gosu::Color.argb(200, 0, 255, 0)
    when Gosu::Color::YELLOW
      background_color = Gosu::Color.argb(200, 255, 255, 0)
    when Gosu::Color::GRAY
      background_color = Gosu::Color.argb(200, 128, 128, 128)
    else
      background_color = Gosu::Color.argb(200, 255, 255, 255)
    end

    Gosu.draw_rect(x, y, @square_size, @square_size, background_color, z = 0)
    @font_letters.draw_text(letter, text_x, text_y, 0, 1, 1, Gosu::Color::BLACK)
  end

  def button_down(id)
    case id
    when Gosu::KB_RETURN
      submit_word
    when Gosu::KB_BACKSPACE
      delete_last_letter
    when Gosu::KB_SPACE
      restart_game if @game_over || @win
    else
      letter = Gosu.button_id_to_char(id).upcase if Gosu.button_down?(id) && Gosu.button_id_to_char(id)
      update_squares(letter)
    end
  end

  def restart_game
    @current_row = 0
    @current_position = 0
    @tries_remaining = 6
    @game_over = false
    @win = false

    @letters_to_draw.each { |letter| letter[:letter] = "" }
    @letters_to_draw.each { |letter| letter[:color] = Gosu::Color::WHITE }
  end

  def submit_word
    return if @game_over

    word = @letters_to_draw[@current_row * 5, 5].map { |letter| letter[:letter] }.join
    target_word_letters = @target_word.split("")

    correct_letters = 0

    @letters_to_draw[@current_row * 5, 5].each_with_index do |letter, index|
      if word[index] == target_word_letters[index]
        letter[:color] = Gosu::Color::GREEN
        correct_letters += 1
      elsif target_word_letters.include?(word[index])
        letter[:color] = Gosu::Color::YELLOW
      else
        letter[:color] = Gosu::Color::GRAY
      end
    end

    if correct_letters == 5
      @game_over = true
      @win = true
    else
      @current_row += 1
      @current_position = 0
      @tries_remaining -= 1
      if @current_row >= 6 || @tries_remaining <= 0
        @game_over = true
      end
    end
  end

  def update_squares(letter)
    return if @game_over || letter.nil?

    if @current_position < 5
      @letters_to_draw[@current_row * 5 + @current_position][:letter] = letter
      @current_position += 1
    end
  end

  def delete_last_letter
    return if @game_over || @current_position.zero?

    @current_position -= 1
    @letters_to_draw[@current_row * 5 + @current_position][:letter] = ""
  end

  def highlight_word(color)
    word = @letters_to_draw[@current_row * 5, 5]
    target_word_letters = @target_word.chars

    word.each_with_index do |letter, index|
      if letter[:letter] == target_word_letters[index]
        letter[:color] = Gosu::Color::GREEN
      elsif target_word_letters.include?(letter[:letter])
        letter[:color] = Gosu::Color::YELLOW
      else
        letter[:color] = Gosu::Color::GRAY
      end
    end
  end
end

WordleGame.new.show
