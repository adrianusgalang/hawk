require 'json'
require 'date'
require 'dotenv'

class HawkMain
  def self.compare(data,time_unit,value_column,time_column,redash_id)
    if time_unit != "hourly"
      day = 0
      case time_unit
      when 'daily'
        day = 28
      when 'weekly'
        day = 28
      end

      datacount = data.count
      countx = 0
      x = Array.new
      dateExclude = DateExc.where(note:redash_id)
      datecount = dateExclude.count
      for i in 0..(datacount-1)
        str = data[i][time_column]
        date = Date.parse str
        for j in 0..(datacount-1)
          str2 = data[j][time_column]
          date2 = Date.parse str2
          if day == 0
            date2 = date2.prev_month
          end

          if date == (date2 - day)

            status = false
            status,value = checkExDate(date,dateExclude,datecount,time_unit)
            if status == true
              data[j][value_column] = value
            end
            status = false
            status,value = checkExDate(date2,dateExclude,datecount,time_unit)
            if status == true
              data[i][value_column] = value
            end

            value = (data[j][value_column].to_f - data[i][value_column].to_f)/(data[i][value_column].to_f)
            x[countx] = Array.new
            x[countx][0] = 1/(1+Math.exp(-1*value))
            x[countx][1] = date2
            countx = countx + 1
            break
          end
        end
      end
      return x
    else
      datacount = data.count
      countx = 0
      x = Array.new
      dateExclude = DateExc.where(note:redash_id)
      datecount = dateExclude.count
      for i in 0..(datacount-1)
        str = data[i][time_column]
        date = DateTime.parse str
        for j in 0..(datacount-1)
          str2 = data[j][time_column]
          date2 = DateTime.parse str2

          if date.to_s[0..12] == (date2 - 7).to_s[0..12]

            status = false
            status,value = checkExDate(date,dateExclude,datecount,'hourly')
            if status == true
              data[j][value_column] = value
            end
            status = false
            status,value = checkExDate(date2,dateExclude,datecount,'hourly')
            if status == true
              data[i][value_column] = value
            end

            value = (data[j][value_column].to_f - data[i][value_column].to_f)/(data[i][value_column].to_f)
            x[countx] = Array.new
            x[countx][0] = 1/(1+Math.exp(-1*value))
            x[countx][1] = date2
            countx = countx + 1
            break
          end
        end
      end
      return x
    end
  end

  def self.checkExDate(date,dateExclude,excludeCount,type)
    if type != 'hourly'
      for i in 0..(excludeCount - 1)

        date_until = Date.parse dateExclude[i]['date']
        case type
        when 'daily'
          date_until = date_until
        when 'weekly'
          date_until = date_until + 7
        when 'monthly'
          date_until = date_until.next_month
        end

        if checkInRange(date,dateExclude[i]['date'],date_until)
          return true,dateExclude[i]['value']
          break
        end

      end
      return false,0
    else
      # hourly
      for i in 0..(excludeCount - 1)
        if dateExclude[i]['date'].length == 10
          if date.to_s[0..9] == dateExclude[i]['date'].to_s[0..9]
            return true,dateExclude[i]['value']
            break
          end
        else
          if date.to_s[0..12] == dateExclude[i]['date'].to_s[0..12]
            return true,dateExclude[i]['value']
            break
          end
        end
      end
      return false,0
    end
  end

  def self.checkInRange(date,date_from,date_until)
    c = Date.parse date_from.to_s
    d = Date.parse date.to_s
    e = Date.parse date_until.to_s
    # puts Date.parse date_from.to_s - Date.parse date.to_s
    if (c - d).to_s[0..0] == '-' || (c - d).to_s[0..0] == '0'
      if (d - e).to_s[0..0] == '-' || (d - e).to_s[0..0] == '0'
        return true
      end
    end
    return false
  end

  def self.lower_upper_bound(ratio)
    mean = get_mean(ratio)
    upper = mean + 3*Math.sqrt(mean * (1 - mean)/ratio.count)
    lower = mean - 3*Math.sqrt(mean * (1 - mean)/ratio.count)
    return lower,upper
  end

  def self.get_mean(ratio)
    total = 0
    for i in 0..(ratio.count-1)
      total += ratio[i][0].to_f
    end
    return total/ratio.count
  end

  def self.get_value(data,value_column,time_unit,time_column,value_type,metric_id)
    datacount = data.count
    if time_unit != "hourly"
      day = 0
      day2 = 0
      case time_unit
      when 'daily'
        day = 1
        day2 = 28
      when 'weekly'
        day = 7
        day2 = 28
      end
      value_counter = 0
      final_value = Array.new
      dateExclude = DateExc.where(note:metric_id)
      datecount = dateExclude.count
      for i in 0..(datacount-1)
        str = data[i][time_column]
        date = Date.parse str
        date_now = Date.current
        date_until = date_now
        if day == 0
          date_now = date_now.prev_month
        end
        date_now = date_now - day
        if date >= date_now && date < date_until
          for j in 0..(datacount-1)
            str2 = data[j][time_column]
            date2 = Date.parse str2
            if day2 == 0
              date2 = date2.next_month
            end
            if date == (date2 + day2)

              status = false
              status,value = checkExDate(date2,dateExclude,datecount,time_unit)
              if status == true
                data[j][value_column] = value
              end

              if value_type == 'absolute'
                final_value[value_counter] = Array.new
                value = (data[i][value_column].to_f - data[j][value_column].to_f)/(data[j][value_column].to_f)
                final_value[value_counter][0] = 1/(1+Math.exp(-1*value))
                final_value[value_counter][1] = date
                value_counter = value_counter + 1
              else
                final_value[value_counter] = Array.new
                final_value[value_counter][0] = data[i][value_column].to_f
                final_value[value_counter][1] = date
                value_counter = value_counter + 1
              end
              break
            end
          end
        end
      end
      return final_value
    else
      value_counter = 0
      final_value = Array.new
      dateExclude = DateExc.where(note:metric_id)
      datecount = dateExclude.count
      for i in 0..(datacount-1)
        str = data[i][time_column]
        date = DateTime.parse str
        date_now = DateTime.current
        date_now = date_now + 5.hours
        if date >= date_now && date < date_now + 1.hours
          for j in 0..(datacount-1)
            str2 = data[j][time_column]
            date2 = DateTime.parse str2
            # tanggal tidak masuk perhitungan di cek disini
            status = 0
            if date.to_s[0..12] == (date2 + 7).to_s[0..12]

              status = false
              status,value = checkExDate(date2,dateExclude,datecount,'hourly')
              if status == true
                data[j][value_column] = value
              end
              if value_type == 'absolute'
                final_value[value_counter] = Array.new
                value = (data[i][value_column].to_f - data[j][value_column].to_f)/(data[j][value_column].to_f)
                final_value[value_counter][0] = 1/(1+Math.exp(-1*value))
                final_value[value_counter][1] = date
                value_counter = value_counter + 1
              else
                final_value[value_counter] = Array.new
                final_value[value_counter][0] = data[i][value_column].to_f
                final_value[value_counter][1] = date
                value_counter = value_counter + 1
              end
              break
            end
          end
        end
      end
      return final_value
    end
  end

  def self.calculate_data(data, time_column, value_column, time_unit, value_type,redash_id)
    if value_type == 'absolute'
      ratio = compare(data,time_unit,value_column,time_column,redash_id)
    elsif value_type == 'ratio'
      temp = Array.new
      for i in 0..(data.count-1)
        dateExclude = DateExc.where(note:redash_id)
        datecount = dateExclude.length
        status = false
        status,value = checkExDate(data[i][time_column],dateExclude,datecount,time_unit)
        if status == true
          temp[i] = Array.new
          temp[i][0] = value
          temp[i][1] = data[i][time_column]
        else
          temp[i] = Array.new
          temp[i][0] = data[i][value_column]
          temp[i][1] = data[i][time_column]
        end
      end
      ratio = temp
    end

    if ratio.count > 25 && (time_unit == 'hourly' || time_unit == 'daily')
      lower_bound, upper_bound = lower_upper_bound(ratio)
      return lower_bound,upper_bound
    elsif ratio.count > 5 && (time_unit == 'weekly' || time_unit == 'monthly')
      lower_bound, upper_bound = lower_upper_bound(ratio)
      return lower_bound,upper_bound
    else
      lower_bound = 0
      upper_bound = 0
      return lower_bound,upper_bound
    end
  end

  def self.calculate_outer_threshold(data, time_column, value_column, time_unit, value_type,batas_bawah,batas_atas,query)
    if value_type == 'absolute'
      ratio = compare(data,time_unit,value_column,time_column,query)
    elsif value_type == 'ratio'
      temp = Array.new
      for i in 0..(data.count-1)
        temp[i] = Array.new
        temp[i][0] = data[i][value_column]
        temp[i][1] = data[i][time_column]
      end
      ratio = temp
    end
    result = Array.new
    counter = 0
    for j in 0..(ratio.count-1)
      if ratio[j][0].to_f < batas_bawah || ratio[j][0].to_f > batas_atas
      result[counter] = ratio[j]
      counter = counter + 1
      end
    end
    return result
  end

  def self.median(redash_id,date,param_time_unit,time_column,value_column,time_unit,value_type,data)
    if value_type == 'absolute'
      ratio = HawkMain.compare(data,time_unit,value_column,time_column,redash_id)
    elsif value_type == 'ratio'
      temp = Array.new
      for i in 0..(data.count-1)
        temp[i] = Array.new
        temp[i][0] = data[i][value_column]
        temp[i][1] = data[i][time_column]
      end
      ratio = temp
    end

    for i in 0..(ratio.count-2)
      for j in i..(ratio.count-1)
        if ratio[i][0] > ratio[j][0]
          temp1 = ratio[i][0]
          temp2 = ratio[i][1]
          ratio[i][0] = ratio[j][0]
          ratio[i][1] = ratio[j][1]
          ratio[j][0] = temp1
          ratio[j][1] = temp2
        end
      end
    end

    median = ratio.count/2.floor

    if value_type == 'absolute'
        date_compare = ''
        if time_unit != 'hourly'
          day = 0
          case time_unit
          when 'daily'
            day = 28
          when 'weekly'
            day = 28
          end

          for i in 0..(ratio.count-1)
            date2 = ratio[i][1]
            date1 = Date.parse date
            if date1 == (date2 + day)
              date_compare = date2
              break
            end
          end
        else
          for i in 0..(ratio.count-1)
            date2 = ratio[i][1]
            date1 = DateTime.parse date
            if date1.to_s[0..12] == (date2 + 7).to_s[0..12]
              date_compare = date2
              break
            end
          end
        end

        yT = 0.5
        for i in 0..(data.count - 1)
          if data[i][time_column].to_s[0..12] == date_compare.to_s[0..12]
            rT = Math.log((1/(ratio[median][0].to_f)) - 1,Math::E) * -1
            yT = rT * data[i][value_column].to_f + data[i][value_column].to_f
          end
        end

        return ratio[median][0].to_f,yT
    else
        return ratio[median][0].to_f,ratio[median][0].to_f
    end
  end
end