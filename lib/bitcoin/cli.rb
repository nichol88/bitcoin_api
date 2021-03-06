class Bitcoin::CLI

  def initialize
    puts "Welcome!"
    menu
  end

  def main_menu_display
    system('clear')
    puts ""
    puts "Type 'exit' to quit"
    puts ""
    puts "***** [MAIN MENU] *****"
    puts "* What would you like to do?"
    puts "* [1] Select Symbol"
    puts "* [2] View Currency Information"
    puts "* [3] View Tickers"
    puts "* [4] User Dashboard"
    puts " "
  end

  def menu
    # Display options
    main_menu_display

    input = gets.strip
    symbol_menu   if input == '1'
    currency_menu if input == '2'
    ticker_menu   if input == '3'
    user_menu     if input == '4'
    exit          if input == 'exit'

    puts "Invalid command. Try again."
    menu

  end

  def iti(input)
    input.to_i - 1 # input to index
  end

  # input: array to choose from
  # output: object if choice is valid; -1 if '0', -2 if no choice (only return key is pressed)
  def choose(array)
    puts "Make a selection, or press return to show list"
    choice = gets
    if choice.strip == '0'
      return -2
    elsif choice == "\n" || choice.strip == ""
      return -1
    elsif choice.strip == '00'
      return -3
    elsif choice.strip != '0' && choice.to_i <= array.length
      return array[iti(choice)]
    else
      puts "Invalid selection. Try again"
      choose(array)
    end
  end

  ### TODO: USER SUBMENU ###
  def user_menu
    user_menu_display

    if !ENV['API_KEY']
      puts ''
      puts "Missing API KEY in your .env file! See README to learn how to add it."
      puts "Press enter to return to main menu."
      gets.strip
      menu
    end
    if !ENV['SECRET']
      puts ''
      puts "Missing SECRET in your .env file. See README to learn how to add"
      puts "your SECRET KEY. Press enter to return to main menu."
      gets.strip
      menu
    end

    input = gets.strip
    menu if input == '0'
    Bitcoin::Account.show_balances if input == '1'
    Bitcoin::Account.show_deposit_address if input == '2'
    exit if input == 'exit'
    user_menu
  end

  def user_menu_display
    puts ''
    puts 'Type "exit" to quit'
    puts ''
    puts '====== [User Menu] ======'
    puts '| [0] Main Menu'
    puts '| [1] View Account Balances'
    puts '| [2] View Deposit Address...'
    # puts "* [3] Order Menu" # Create New, Cancel, Get by ID, Get History
    # puts "* [4] Trade Menu"
    # puts "* [5] Transfer To / From Bank Account"
    # puts '* [5] Transfer To / From Bank Account'
  end

  ### SYMBOL SUBMENUS ###
  def symbol_menu(symbol = nil)

    # display list & get symbol if it hasn't been selected yet
    if !symbol
      list = list_by_id(Bitcoin::Ssymbol.all)
      selection = choose(list) #
      menu if selection == -2
      symbol_menu if selection == -1
      symbol = selection
    end

    # display menu options for a symbol
    symbol_menu_display(symbol)

    # route choice to appropriate submenu
    input = gets.strip
    menu                    if input == '0'
    trade_menu(symbol)      if input == '1'
    order_book_menu(symbol) if input == '2'
    candles_menu(symbol)    if input == '3'
    analysis_menu(symbol)   if input == '4'
    exit                    if input == 'exit'
    puts 'nope'
    symbol_menu(symbol) # menu loop after action

  end

  def symbol_menu_display(symbol)
    puts symbol.display_details
    puts ""
    puts "Type 'exit' to quit"
    puts ""
    puts "***** [Symbol Menu] #{symbol.id} *****"
    puts "* [0] Main Menu"
    puts "* [1] View Trades for #{symbol.id}"
    puts "* [2] View Order Book for #{symbol.id}"
    puts "* [3] View Candles for #{symbol.id}"
    puts "* [4] Analysis Mode"
  end

  def trade_menu(symbol, trades_array = nil)
    if !trades_array
      trades = Bitcoin::Trade.all(symbol.id)
      self.list_trades(trades)
    end

    trade_menu_display

    # User may either: select a trade to view, return to Main Menu, Symbol Menu,
    #   or loop method to show list again
    selection = choose(trades)
    trade_menu(symbol)  if selection == -1
    menu                if selection == -2
    symbol_menu(symbol) if selection == -3

    selection.display_details
    # Loop method without re-listing if action performed sucessfully
    trade_menu(symbol, trades)
  end

  def list_trades(trades)
    trades.each_with_index{ |trade, i|
      puts "#{(i+1).to_s.rjust(4)}. #{trade.timestamp.strftime("%Y-%m-%d %H:%M:%S")} #{trade.side.rjust(4)} #{trade.price}"
    }
  end

  def trade_menu_display
    puts ""
    puts " Type 'exit' to quit"
    puts ""
    puts "***** [Trades Menu] *****"
    puts "* [0] Main Menu"
    puts "* [00] Symbol Menu"
    puts "* [#] Select Entry to View Details"
    puts ""
  end

  def order_book_menu(symbol, orders = nil)
    if !orders
      orders = Bitcoin::OrderBook.all(symbol.id)
      self.list_order_book(orders)
    end

    order_book_menu_display

    selection = choose(orders)
    order_book_menu(symbol) if selection == -1
    menu                    if selection == -2
    symbol_menu(symbol)     if selection == -3

    selection.display_details

    order_book_menu(symbol, orders)
  end

  def order_book_menu_display
    puts ""
    puts "  Type 'exit' to quit"
    puts ""
    puts "***** [Order Book Menu] *****"
    puts "* [0] Main Menu"
    puts "* [00] Symbol Menu"
    puts "* [#] Select Entry to View Details"
    puts ""
  end

  def list_order_book(orderbook)
    orderbook.each_with_index{ |order, i|
      puts "#{(i+1).to_s.rjust(4)}. #{order.timestamp.strftime("%Y-%m-%d %H:%M:%S")}:  #{order.side.upcase} - Order Size: #{order.size.to_s.rjust(12)}, Price: #{order.price.to_s.rjust(12)}"
    }
  end

  def candles_menu(symbol, candles = nil)
    if !candles
      candles = Bitcoin::Candle.all(symbol.id)
      list_candles(candles)
    end

    candles_menu_display

    selection = choose(candles)
    candles_menu(symbol) if selection == -1
    menu                 if selection == -2
    symbol_menu(symbol)  if selection == -3

    selection.display_details
  end

  def candles_menu_display
    puts ""
    puts "  Type 'exit' to quit"
    puts ""
    puts "***** [Candles Menu] *****"
    puts "* [0] Main Menu"
    puts "* [00] Symbol Menu"
    puts "* [#] Select Entry to View Details"
    puts ""
  end

  def list_candles(candles)
    candles.each_with_index{ |candle, i|
      puts "#{(i+1).to_s.rjust(4)}. #{candle.timestamp} [#{candle.open.rjust(11)} -> #{candle.close.rjust(11)}] [#{candle.min.rjust(11)} - #{candle.max.rjust(11)}] vol: #{candle.volume.rjust(11)}"
    }
    # to do: insert key at top and bottom of list
  end

  ### CURRENCY SUBMENU ###
  def currency_menu(list = nil)
    if !list
      list = list_by_id(Bitcoin::Currency.all)
    end
    currency_menu_display
    selection = choose(list)
    currency_menu if selection == -1
    menu          if selection == -2

    selection.display_details
    currency_menu(list)
  end

  def currency_menu_display
    puts ""
    puts "  Type 'exit' to quit"
    puts ""
    puts "***** [Currency Menu] *****"
    puts "* [0] Main Menu"
    puts "* [#] Select Entry to View Details"
    puts ""
  end

  ### TICKER SUBMENU ###
  def ticker_menu(list = nil)
    if !list
      list = list_tickers(Bitcoin::Ticker.all)
    end

    ticker_menu_display

    selection = choose(list)
    ticker_menu if selection == -1
    menu        if selection == -2

    selection.display_details
    ticker_menu(list)
  end

  def ticker_menu_display
    puts ""
    puts "  Type 'exit' to quit"
    puts ""
    puts "***** [Ticker Menu] *****"
    puts "* [0] Main Menu"
    puts "* [#] Select Entry to View Details"
    puts ""
  end

  def list_tickers(tickers)
    tickers.each_with_index{ |ticker, i|
      puts "#{(i+1).to_s.rjust(4)}. #{ticker.symbol}"
    }
  end

  ### ANALYSIS SUBMENU ###
  def analysis_menu(symbol)

    analysis_menu_display(symbol)

    input = gets.strip
    menu if input == '0'
    symbol_menu(symbol) if input == '00'
    Bitcoin::Analyzer.analyze_trades symbol if input == '1'
    Bitcoin::Analyzer.analyze_candles symbol if input == '2'
    analysis_menu(symbol)
  end

  def analysis_menu_display(symbol)
    puts ""
    puts "  Type 'exit' to quit"
    puts ""
    puts "///// [Analysis Mode - #{symbol.id}] /////"
    puts "/  [0] Main Menu"
    puts "/ [00] Symbol Menu"
    puts "/  [1] Analyze Trades Within Range..."
    puts "/  [2] Analyze Candles Within Range..."
    puts ""
  end

  def list(array)
    numerize(array)
  end

  def list_by_symbol(array)
    numerize(array, :symbol)
  end

  def list_by_id(array)
    numerize(array, :id)
  end

  def numerize(array, attribute = nil)
    if attribute
      array.each_with_index{ |e, i| puts "#{i+1}. #{e.send("#{attribute}")}"}
    else
      array.each_with_index{ |e, i| puts "#{i+1}. #{e}"}
    end
  end
end
