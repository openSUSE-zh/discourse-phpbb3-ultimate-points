module UltimatePoints
  class Discourse
    def initialize(con, data)
      @con = con
      @data = data
    end

    def push
      points = UltimatePoints::PHPBB.send(:sort, @data, 2)
      posts = UltimatePoints::PHPBB.send(:sort, @data, 1)
      total = points.size

      ten = (total * 0.1).to_i

      data = []
      level_three = []
      level_two = []

      points.each_with_index do |i, j|
        next unless j < ten
        posts.each_with_index do |m, n|
          if m[0] == i[0] && n < ten
            data << i if i[1] > 30
          end
        end
      end

      data.each_with_index do |k, v|
        if v < 20
          level_three << k
        else
          level_two << k
        end
      end

      level_3_name = 'trust_level_3'
      level_2_name = 'trust_level_2'

      time = Time.now.strftime('%Y-%m-%dT%H:%M:%SZ')
      three_id = @con.exec("SELECT id FROM groups WHERE name='#{level_3_name}'")[0]['id']
      two_id = @con.exec("SELECT id FROM groups WHERE name='#{level_2_name}'")[0]['id']

      level_three.each do |l3|
        @con.exec "UPDATE users SET trust_level='3' WHERE id='#{l3[0]}'"
        @con.exec "INSERT INTO group_users (group_id, user_id, created_at, updated_at, owner, notification_level) VALUES('#{three_id}', '#{l3[0]}', '#{time}', '#{time}', 'f', '3')"
        @con.exec "UPDATE groups SET user_count=user_count + 1 WHERE name='#{level_3_name}'"
      end

      level_two.each do |l2|
        @con.exec "UPDATE users SET trust_level='2' WHERE id='#{l2[0]}'"
        @con.exec "INSERT INTO group_users (group_id, user_id, created_at, updated_at, owner, notification_level) VALUES('#{two_id}', '#{l2[0]}', '#{time}', '#{time}', 'f', '3')"
        @con.exec "UPDATE groups SET user_count=user_count + 1 WHERE name='#{level_2_name}'"
      end
    end
  end
end
