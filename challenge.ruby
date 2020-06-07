=begin
- Look at both sets of busy time
- Save every available time for both people
  with the interview time
- Compare both available times and eliminate the ones that are 
  before the latest starting schedule and after the earliest
  ending schedule 
=end

def available_time(busy_time, meeting_time)

    available_meeting_times = []
    # Will return available times for meetings list 
    busy_time.each_with_index do |hours, index|

        if busy_time[index+1] != nil
            # Gets starting time for each of the following busy schedule times
            next_block_reached = 0
            following_start_time = busy_time[index + 1].split(',')[0]
            times = hours.split(',')
            available_time = [times[1], busy_time[index + 1].split(',')[0]]
            p available_time

            # The case that a busy block of time will start right after the other
            if available_time[0] == available_time[1]
                next
            end

            first_block_time = available_time[0].split(':')
            counter = 0
            # Checks for every available space block of <meeting_time>
            while next_block_reached == 0 do
                
                hours_added = 0
                time_blocks = [] 

                if counter == 0
                    minutes = first_block_time[1].gsub!("'", "").to_i

                    if minutes.to_i < 10
                        start_time = "#{first_block_time[0].gsub("'", "").to_i}:#{minutes.to_s.insert(0,'0')}"
                    else 
                        start_time = "#{first_block_time[0].gsub("'", "").to_i}:#{minutes}"
                    end

                    p "#{start_time}"
                    time_blocks << start_time
                    puts time_blocks.inspect

                    new_minutes = minutes + meeting_time.to_f
                else

                    minutes = new_minutes.to_f    
                    new_minutes = minutes + meeting_time
                end

                # when a block of meeting time is added and it passes the hour mark
                # it will check how many hours will be added
                if new_minutes >= 60
                    while new_minutes >= 60 do
                        new_minutes -= 60
                        hours_added += 1
                    end
                end

                if new_minutes < 10.0
                    new_minutes = new_minutes.to_s.delete_suffix('.0').insert(0,'0')
                else
                    new_minutes = new_minutes.to_s.delete_suffix('.0')
                end

                if counter == 0
                    new_hours = first_block_time[0].gsub!("'", "").to_i + hours_added
                else 
                    new_hours += hours_added
                    if minutes < 10
                        time_blocks << "#{new_hours-hours_added}:#{minutes.to_s.delete_suffix('.0').insert(0, '0')}"
                    else
                        time_blocks << "#{new_hours-hours_added}:#{minutes.to_i}"
                    end
                end 
                
                counter += 1
                hours_post_meeting = "#{new_hours}:#{new_minutes}"
                puts "HOURS: #{hours_post_meeting}"
                time_blocks << hours_post_meeting
                puts "PUTS #{time_blocks.inspect}"
                available_meeting_times << time_blocks
                puts "ALL TIMES: #{available_meeting_times.inspect}"
                puts "HOURS TO REACH: #{available_time[1].gsub("'", "")}\n\n"

                if hours_post_meeting .eql? available_time[1].gsub("'", "")
                    next_block_reached = 1
                end
            end
        end
    end
end



info = []
File.foreach('sample.txt'){ 
    |line| info.append(line.strip.tr('[', '').tr(' ', '').gsub(']]', '').split('],'))
}

meeting_time = info[4][0].to_i

available_time info[0], meeting_time



