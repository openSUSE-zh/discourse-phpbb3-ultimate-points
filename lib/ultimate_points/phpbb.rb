module UltimatePoints
  # extract data from phpbb3 mysql database
  class PHPBB
    def initialize(con)
      @con = con
    end

    def get
      read
    end

    private

    def read
      data = @con.query("SELECT user_id,holding FROM phpbb_points_bank")
      data1 = @con.query("SELECT user_id,user_posts,user_points FROM phpbb_users")
      data2 = @con.query("SELECT user_id,SUM(amount) FROM phpbb_points_lottery_history GROUP BY user_id")    
 
      bank = []
      hand = []
      lottery = []

      data.each do |d|
        bank << [d['user_id'], d['holding'].to_f]
      end

      data1.each do |d1|
        hand << [d1['user_id'], d1['user_posts'].to_i, d1['user_points'].to_f]
      end

      data2.each do |d2|
        lottery << [d2['user_id'], d2['SUM(amount)'].to_f]
      end

      hand.map! do |h|
        arr = []
        bank.each do |b|
          if h[0] == b[0]
            arr = [h[0], h[1], b[1] + h[2]]
          end
        end

        if arr.empty?
          h
        else
          arr
        end
      end

      hand.map! do |h1|
        arr = []
        lottery.each do |l|
          if h1[0] == l[0]
            arr = [h1[0], h1[1], h1[2] - l[1]]
          end
        end
        if arr.empty?
          h1
        else
          arr
        end
      end
    end

    def self.sort(arr, pos)
      # pos: 1, posts; 2, points
      flag = true
      while flag do
        k = 0
        arr.each_with_index do |i, j|
          unless j == arr.size - 1
            if arr[j + 1][pos] > i[pos]
              tmp = arr[j + 1]
              arr[j + 1] = i
              arr[j] = tmp
              k += 1
            end
          end
        end
        flag = false if k == 0
      end
      arr
    end
  end
end
