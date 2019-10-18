require 'httparty'
require 'json'
require 'date'
require 'dotenv'
require 'csv'
require 'set'

class Redash
  def self.set_threshold(query, time_column, value_column, time_unit, value_type,metric_id,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << query.to_s << '/refresh'
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.post(url,:headers => headers)
    obj = response.parsed_response
    id_query = obj['job']['id']

    result_id = get_result_id(id_query,redash_used)
    data = get_data result_id.to_s

    return HawkMain.calculate_data(data, time_column, value_column, time_unit, value_type,metric_id)
  end

  def self.get_redash_detail(query,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << query.to_s
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)

    return response['name'],response['latest_query_data_id'],response['updated_at']
  end

  def self.get_csv(query, time_column, value_column, time_unit, value_type,metric_id,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << query.to_s << '/results.csv'
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)

    data = {}
    for i in 1..(response.count-1)
      data[i-1] = {}
      for j in 0..(response[0].count-1)
        data[i-1][response[0][j].downcase] = response[i][j]
      end
    end

    return HawkMain.calculate_data(data, time_column, value_column, time_unit, value_type, metric_id)
  end

  def self.get_csv_dimension(query, time_column, value_column, time_unit, value_type, metric_id, dimension, dimension_column,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << query.to_s << '/results.csv'
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)
    dimension_position = 0
    counter = 0
    for i in 1..(response.count-1)
      for j in 0..(response[0].count-1)
        if response[0][j].downcase == dimension_column
          dimension_position = j
        end
      end
    end

    data = {}
    counter = 0
    for i in 1..(response.count-1)
      if response[i][dimension_position] == dimension
        data[counter] = {}
        for j in 0..(response[0].count-1)
          data[counter][response[0][j].downcase] = response[i][j]
        end
        counter = counter + 1
      end
    end
    return HawkMain.calculate_data(data, time_column, value_column, time_unit, value_type, metric_id)
  end

  def self.get_result_id(id_query,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
		headers = {
		 "Authorization"  => redash_key
    }
		status = 0
    counter = 0
    result_id = 0
		while status != 3 && status != 4 && counter < 1000
			url = ENV["URL_REDASH"] << ':' << redash_port << '/api/jobs/' << id_query.to_s
			response = HTTParty.get(url,:headers => headers)
			obj = response.parsed_response
			status = obj['job']['status']
			result_id = obj['job']['query_result_id']
			sleep(1)
			puts url
			puts counter
			counter = counter + 1
    end
		return result_id
	end

	def self.get_data(result_id,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
		headers = {
		 "Authorization"  => redash_key
		}
		url = ENV["URL_REDASH"] << ':' << redash_port << '/api/query_results/' << result_id
		response = HTTParty.get(url,:headers => headers)
		obj = response.parsed_response
		data = obj['query_result']['data']['rows']
		column = obj['query_result']['data']['columns']
		return data
	end

  def self.get_result(query,value_column,time_unit,time_column,value_type,metric_id,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << query.to_s << '/results.csv'
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)
    data = {}
    for i in 1..(response.count-1)
      data[i-1] = {}
      for j in 0..(response[0].count-1)
        data[i-1][response[0][j].downcase] = response[i][j]
      end
    end

    return HawkMain.get_value(data,value_column,time_unit,time_column,value_type,metric_id)
  end

  def self.get_result_dimension(query,value_column,time_unit,time_column,value_type,metric_id,dimension_column,dimension,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << query.to_s << '/results.csv'
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)

    dimension_position = 0
    counter = 0
    for i in 1..(response.count-1)
      for j in 0..(response[0].count-1)
        if response[0][j].downcase == dimension_column
          dimension_position = j
        end
      end
    end

    data = {}
    counter = 0
    for i in 1..(response.count-1)
      if response[i][dimension_position] == dimension
        data[counter] = {}
        for j in 0..(response[0].count-1)
          data[counter][response[0][j].downcase] = response[i][j]
        end
        counter = counter + 1
      end
    end

    return HawkMain.get_value(data,value_column,time_unit,time_column,value_type,metric_id)
  end

  def self.get_outer_threshold(query, time_column, value_column, time_unit, value_type,batas_bawah,batas_atas,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    # puts value_type
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << query.to_s << '/results.csv'
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)

    data = {}
    for i in 1..(response.count-1)
      data[i-1] = {}
      for j in 0..(response[0].count-1)
        data[i-1][response[0][j].downcase] = response[i][j]
      end
    end

    return HawkMain.calculate_outer_threshold(data, time_column, value_column, time_unit, value_type,batas_bawah,batas_atas,query)
  end

  def self.get_outer_threshold_dimension(query, time_column, value_column, time_unit, value_type,batas_bawah,batas_atas,dimension,dimension_column,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    # puts value_type
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << query.to_s << '/results.csv'
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)

    dimension_position = 0
    counter = 0
    for i in 1..(response.count-1)
      for j in 0..(response[0].count-1)
        if response[0][j].downcase == dimension_column
          dimension_position = j
        end
      end
    end

    data = {}
    counter = 0
    for i in 1..(response.count-1)
      if response[i][dimension_position] == dimension
        data[counter] = {}
        for j in 0..(response[0].count-1)
          data[counter][response[0][j].downcase] = response[i][j]
        end
        counter = counter + 1
      end
    end

    # data = {}
    # for i in 1..(response.count-1)
    #   data[i-1] = {}
    #   for j in 0..(response[0].count-1)
    #     data[i-1][response[0][j]] = response[i][j]
    #   end
    # end

    return HawkMain.calculate_outer_threshold(data, time_column, value_column, time_unit, value_type,batas_bawah,batas_atas,query)
  end

  def self.calculate_median(redash_id,date,param_time_unit,time_column,value_column,time_unit,value_type,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << redash_id.to_s << '/results.csv'
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)

    data = {}
    for i in 1..(response.count-1)
      data[i-1] = {}
      for j in 0..(response[0].count-1)
        data[i-1][response[0][j].downcase] = response[i][j]
      end
    end

    return HawkMain.median(redash_id,date,param_time_unit,time_column,value_column,time_unit,value_type,data)
  end

  def self.calculate_median_dimension(redash_id,date,param_time_unit,time_column,value_column,time_unit,value_type,dimension,dimension_column,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << redash_id.to_s << '/results.csv'
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)

    dimension_position = 0
    counter = 0
    for i in 1..(response.count-1)
      for j in 0..(response[0].count-1)
        if response[0][j].downcase == dimension_column
          dimension_position = j
        end
      end
    end

    data = {}
    counter = 0
    for i in 1..(response.count-1)
      if response[i][dimension_position] == dimension
        data[counter] = {}
        for j in 0..(response[0].count-1)
          data[counter][response[0][j].downcase] = response[i][j]
        end
        counter = counter + 1
      end
    end

    # data = {}
    # for i in 1..(response.count-1)
    #   data[i-1] = {}
    #   for j in 0..(response[0].count-1)
    #     data[i-1][response[0][j]] = response[i][j]
    #   end
    # end

    return HawkMain.median(redash_id,date,param_time_unit,time_column,value_column,time_unit,value_type,data)
  end

  def self.get_redash_result_id(query,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << query.to_s
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)
    return response['latest_query_data_id']
  end

  def self.refresh(query,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << query.to_s << '/refresh'
    headers = {
     "Authorization"  => redash_key
    }
    response = HTTParty.post(url,:headers => headers)
    obj = response.parsed_response
    id_query = obj['job']['id']

    return get_result_id(id_query,redash_used)
  end

  def self.get_dimension(redash_id,dimension_column,redash_used)
    redash_url,redash_key,redash_port = get_redash_used(redash_used)
    url = ENV["URL_REDASH"] << ':' << redash_port << '/api/queries/' << redash_id.to_s << '/results.csv'
    headers = {
      "Authorization"  => redash_key
    }
    response = HTTParty.get(url,:headers => headers)

    data = {}
    counter = 0
    for i in 1..(response.count-1)
      for j in 0..(response[0].count-1)
        if response[0][j].downcase == dimension_column
          status = 0
          for k in 0..counter
            if data[k] == response[i][j]
              status = 1
            end
          end
          if status == 0
            data[counter] = response[i][j]
            counter = counter + 1
          end
        end
      end
    end
    return data
  end

  def self.get_redash_used(redash_used)
    case redash_used
    when 0
      return 'redash',ENV["REDASH_KEY"],ENV["REDASH_PORT"]
    when 1
      return 'cs-redash',ENV["REDASH_KEY_CS"],ENV["REDASH_PORT_CS"]
    when 2
      return 'dg-redash',ENV["REDASH_KEY_DG"],ENV["REDASH_PORT_DG"]
    when 3
      return 'rev-redash',ENV["REDASH_KEY_REV"],ENV["REDASH_PORT_REV"]
    when 4
      return 'supply-redash',ENV["REDASH_KEY_SUPPLY"],ENV["REDASH_PORT_SUPPLY"]
    when 5
      return 'trust-redash',ENV["REDASH_KEY_TRUST"],ENV["REDASH_PORT_TRUST"]
    when 6
      return 'adhoc-redash',ENV["REDASH_KEY_ADHOC"],ENV["REDASH_PORT_ADHOC"]
    end
  end

end
