desc 'Tasks to import previous holdings'

require 'csv'

DATE_INDEX = 0
INVESTMENT_INDEX = 1
TYPE_INDEX = 2
PRICE_INDEX = 3
SHARE_INDEX = 4

FILE_PATH = '/Users/mfornaciari/Documents/salesforce-401k.csv'
PORTFOLIO_NAME = 'retirement'

INVESTMENT_TO_SYMBOL = {
  FID_PURITAN: 'FPURX',
  JPM_SMRTRET_2055_I: 'JFFIX',
  SPTN_500_INDEX_INST: 'FXSIX',
  SPTN_EXT_MKT_IDX_ADV: 'FSEVX'
}

task :import_401k => :environment do
  abort("Unfortunately '#{FILE_PATH}' does not exist") if !File.exists?(FILE_PATH) 

  mattforni = User.where({email: 'mattforni@gmail.com'}).first
  abort("For some reason user 'mattforni@gmail.com' could not be found") if mattforni.nil?

  holdings = []
  CSV.read(FILE_PATH).each do |row|
    # Continue to next row if the date is not formed correctly
    date = Date.strptime(row[DATE_INDEX], "%m/%d/%y") rescue next

    # Continue to next row if the type is not a contribution
    next if row[TYPE_INDEX] != 'CONTRIBUTION'

    investment = row[INVESTMENT_INDEX].gsub(' ', '_').to_sym
    symbol = INVESTMENT_TO_SYMBOL[investment]

    shares = row[SHARE_INDEX].to_f
    price = row[PRICE_INDEX].to_f / shares.to_f

    holdings << Holding.new({
      commission_price: 0,
      purchase_date: date,
      purchase_price: price,
      quantity: shares,
      symbol: symbol,
      user: mattforni
    })
  end

  ActiveRecord::Base.transaction do
    portfolio = Portfolio.by_user_and_name(mattforni, PORTFOLIO_NAME)

    if portfolio.nil?
      portfolio = Portfolio.new({
        name: PORTFOLIO_NAME,
        user: mattforni
      })
      portfolio.save!
    end

    holdings.each do |holding|
      position = Position.where({
        portfolio: portfolio,
        symbol: holding.symbol,
        user: mattforni
      }).first

      exists = Holding.where({
        position: position,
        purchase_date: holding.purchase_date,
        quantity: holding.quantity,
        symbol: holding.symbol,
        user: mattforni
      }).first != nil

      if exists
        puts 'Holding already exists, skipping creation'
        next
      end

      holding.creation_portfolio = portfolio
      holding.create!

      puts "Created #{holding}"
    end
  end
end

