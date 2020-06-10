=begin
- Look at both sets of busy time
- Save every available time for both people
  with the interview time
- Compare both available times and eliminate the ones that are 
  before the latest starting schedule and after the earliest
  ending schedule 
=end

def get_available_time(busy_time, meeting_time, end_time)

    available_meeting_times = []
    # Will return available times for meetings list 
    busy_time.each_with_index do |hours, index|

            # Gets starting time for each of the following busy schedule times
            next_block_reached = 0

            # Getting the time between one busy block and another one
            if index < busy_time.length() - 1 
                following_start_time = busy_time[index + 1].split(',')[0]
                times = hours.split(',')
                available_time = [times[1], busy_time[index + 1].split(',')[0]]
            end

            # Getting the time between the last time of the busy block and the last working hour
            if index .eql? busy_time.length() - 1
                times = hours.split(',')
                available_time = [times[1], end_time]
            end

            # The case that a busy block of time will start right after the other
            if available_time[0] == available_time[1]
                next
            end

            f_block_time = available_time[0].split(':')
            counter = 0
            # Checks for every available space block of <meeting_time>
            while next_block_reached == 0 do
                
                hours_added = 0
                time_blocks = [] 

                if counter == 0
                    minutes = f_block_time[1].gsub!("'", "").to_i

                    if minutes.to_i < 10
                        start_time = "#{f_block_time[0].gsub("'", "").to_i}:#{minutes.to_s.insert(0,'0')}"
                    else 
                        start_time = "#{f_block_time[0].gsub("'", "").to_i}:#{minutes}"
                    end

                    time_blocks << start_time
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
                    new_hours = f_block_time[0].gsub!("'", "").to_i + hours_added
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
                time_blocks << hours_post_meeting
                available_meeting_times << time_blocks

                if hours_post_meeting .eql? available_time[1].gsub("'", "")
                    next_block_reached = 1
                end
            end
        end
    return available_meeting_times
end


def arrange_meeting_blocks(f_block, s_block, time_bounds)

    meeting_blocks = []
    temp_block = []

    counter = 0
    flag = 0

    # Search through all time blocks of the second person
    s_block.each_with_index do |e, index|

        if f_block.include?e
            # Check if the value included in both blocks is within the time bounds 
            if check_valid_block e, time_bounds[0], time_bounds[1]
                flag = 1
                if counter == 0
                    temp_block << e
                
                # merging time blocks in sequence
                elsif counter > 0
                    temp_block[0][1] = e[1]
                end
            end
        end

        if flag .eql? 1 and index < s_block.length()-1
            counter += 1
        elsif (flag .eql? 0 or index .eql? s_block.length()-1) and temp_block != []

            meeting_blocks << temp_block[0]
            counter = 0
            temp_block.clear
        end
        flag = 0
    end
    return meeting_blocks
end

def get_latest_time(f_person_time, s_person_time)
    # Get earliest time from a simple set of parameters like "'10:30'", "'10:00'"
    fp_hour = f_person_time.split(':')[0].gsub("'", "").to_i
    sp_hour = s_person_time.split(':')[0].gsub("'", "").to_i

    if fp_hour > sp_hour
        return f_person_time
    elsif sp_hour > fp_hour
        return s_person_time
    else
        fp_minutes = f_person_time.split(':')[1].gsub("'","").to_i
        sp_minutes = s_person_time.split(':')[1].gsub("'","").to_i
        if fp_minutes > sp_minutes
            return f_person_time
        elsif sp_minutes > fp_minutes
            return s_person_time
        end
    end
end


def get_earliest_time(f_person_time, s_person_time)
    # Get earliest time from a simple set of parameters like "'10:30'", "'10:00'"
    fp_hour = f_person_time.split(':')[0].gsub("'", "").to_i
    sp_hour = s_person_time.split(':')[0].gsub("'", "").to_i

    if fp_hour < sp_hour
        return f_person_time
    elsif sp_hour < fp_hour
        return s_person_time
    else
        fp_minutes = f_person_time.split(':')[1].gsub("'","").to_i
        sp_minutes = s_person_time.split(':')[1].gsub("'","").to_i
        if fp_minutes < sp_minutes
            return f_person_time
        elsif sp_minutes < fp_minutes
            return s_person_time
        end
    end
end


def check_valid_block(time_block, start_hour, end_hour)
    # Check if the start and end of the block are earlier than the start_hour
    # and if the start and end of the block are later than the end_hour

    f_check_earlier = get_latest_time time_block[0], start_hour
    s_check_earlier = get_latest_time time_block[1], start_hour

    if f_check_earlier .eql? start_hour or s_check_earlier .eql? start_hour
        return false
    end

    f_check_later = get_earliest_time time_block[0], end_hour
    s_check_later = get_earliest_time time_block[1], end_hour

    if f_check_later .eql? end_hour or s_check_later .eql? end_hour
        return false
    end
    
    return true

end


info = []
File.foreach('sample.txt'){ 
    |line| info.append(line.strip.tr('[', '').tr(' ', '').gsub(']]', '').split('],'))
}

meeting_time = info[4][0].to_i
f_person_start_time = info[1][0].split(',')[0]
f_person_end_time = info[1][0].split(',')[1].gsub(']', '')
s_person_start_time = info[3][0].split(',')[0]
s_person_end_time = info[3][0].split(',')[1].gsub(']', '')

ans_1 = get_available_time info[0], meeting_time, f_person_end_time
ans_2 = get_available_time info[2], meeting_time, s_person_end_time
new_latest_start_hour = get_latest_time f_person_start_time, s_person_start_time
new_earliest_end_hour = get_earliest_time f_person_end_time, s_person_end_time
time_bounds = [new_latest_start_hour, new_earliest_end_hour]

p arrange_meeting_blocks ans_1, ans_2, time_bounds





