module UltimatePoints
  # map data from phpbb to discourse's postgresql
  class Map
    def initialize(con, data)
      @con = con
      @data = map(data)
    end

    def get
      @data
    end

    private

    def map(data)
      # map the data with the IDs in the postgresql db
      data.map! do |i|
        user_id = get_user_id(i[0])
        [user_id, i[1], i[2]]
      end
    end

    def get_user_id(id)
      ids = @con.exec "SELECT user_id FROM user_custom_fields WHERE name='import_id' AND value=\'#{id}\'"
      data = []
      return '-1' if ids.cmd_tuples.zero?
      ids.each do |row|
        data << row['user_id']
      end
      data[0]
    end
  end
end
