require 'httparty'
require 'json'
require 'date'
require 'dotenv'
require 'csv'
require 'set'

class Redash
  def self.set_threshold(query, time_column, value_column, time_unit, value_type,metric_id)
    url = 'https://redash.bukalapak.io/api/queries/'<<query.to_s<<'/refresh'
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.post(url,:headers => headers)
    obj = response.parsed_response
    id_query = obj['job']['id']

    result_id = get_result_id id_query
    data = get_data result_id.to_s

    return HawkMain.calculate_data(data, time_column, value_column, time_unit, value_type,metric_id)
  end

  def self.get_redash_detail(query)
    url = 'https://redash.bukalapak.io/api/queries/'<<query.to_s
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)

    return response['name'],response['latest_query_data_id'],response['updated_at']
  end

  def self.get_csv(query, time_column, value_column, time_unit, value_type,metric_id)
    url = 'https://redash.bukalapak.io/api/queries/'<<query.to_s<<'/results.csv'
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)

    data = {}
    for i in 1..(response.count-1)
      data[i-1] = {}
      for j in 0..(response[0].count-1)
        data[i-1][response[0][j]] = response[i][j]
      end
    end

    return HawkMain.calculate_data(data, time_column, value_column, time_unit, value_type, metric_id)
  end

  def self.get_csv_dimension(query, time_column, value_column, time_unit, value_type, metric_id, dimension, dimension_column)
    url = 'https://redash.bukalapak.io/api/queries/'<<query.to_s<<'/results.csv'
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)
    dimension_position = 0
    counter = 0
    for i in 1..(response.count-1)
      for j in 0..(response[0].count-1)
        if response[0][j] == dimension_column
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
          data[counter][response[0][j]] = response[i][j]
        end
        counter = counter + 1
      end
    end
    return HawkMain.calculate_data(data, time_column, value_column, time_unit, value_type, metric_id)
  end

  def self.get_result_id(id_query)
		headers = {
		 "Authorization"  => ENV["REDASH_KEY"]
		}
		status = 0
		counter = 0
		while status != 3 && status != 4
			url = 'https://redash.bukalapak.io/api/jobs/'<<id_query.to_s
			# url = 'https://redash.bukalapak.io/api/jobs/'<<'d7e330da-a40b-4515-9c3b-8cdc721ecb99'
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

	def self.get_data(result_id)
		headers = {
		 "Authorization"  => ENV["REDASH_KEY"]
		}
		url = 'https://redash.bukalapak.io/api/query_results/'<<result_id
		response = HTTParty.get(url,:headers => headers)
		obj = response.parsed_response
		data = obj['query_result']['data']['rows']
		column = obj['query_result']['data']['columns']
		return data
	end

  def self.get_result(query,value_column,time_unit,time_column,value_type,metric_id)
    url = 'https://redash.bukalapak.io/api/queries/'<<query.to_s<<'/results.csv'
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)
    data = {}
    for i in 1..(response.count-1)
      data[i-1] = {}
      for j in 0..(response[0].count-1)
        data[i-1][response[0][j]] = response[i][j]
      end
    end

    return HawkMain.get_value(data,value_column,time_unit,time_column,value_type,metric_id)
  end

  def self.get_result_dimension(query,value_column,time_unit,time_column,value_type,metric_id,dimension_column,dimension)
    url = 'https://redash.bukalapak.io/api/queries/'<<query.to_s<<'/results.csv'
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)

    dimension_position = 0
    counter = 0
    for i in 1..(response.count-1)
      for j in 0..(response[0].count-1)
        if response[0][j] == dimension_column
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
          data[counter][response[0][j]] = response[i][j]
        end
        counter = counter + 1
      end
    end

    return HawkMain.get_value(data,value_column,time_unit,time_column,value_type,metric_id)
  end

  def self.get_outer_threshold(query, time_column, value_column, time_unit, value_type,batas_bawah,batas_atas)
    puts value_type
    url = 'https://redash.bukalapak.io/api/queries/'<<query.to_s<<'/results.csv'
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)

    data = {}
    for i in 1..(response.count-1)
      data[i-1] = {}
      for j in 0..(response[0].count-1)
        data[i-1][response[0][j]] = response[i][j]
      end
    end

    return HawkMain.calculate_outer_threshold(data, time_column, value_column, time_unit, value_type,batas_bawah,batas_atas,query)
  end

  def self.get_outer_threshold_dimension(query, time_column, value_column, time_unit, value_type,batas_bawah,batas_atas,dimension,dimension_column)
    puts value_type
    url = 'https://redash.bukalapak.io/api/queries/'<<query.to_s<<'/results.csv'
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)

    dimension_position = 0
    counter = 0
    for i in 1..(response.count-1)
      for j in 0..(response[0].count-1)
        if response[0][j] == dimension_column
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
          data[counter][response[0][j]] = response[i][j]
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

  def self.calculate_median(redash_id,date,param_time_unit,time_column,value_column,time_unit,value_type)
    url = 'https://redash.bukalapak.io/api/queries/'<<redash_id.to_s<<'/results.csv'
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)

    data = {}
    for i in 1..(response.count-1)
      data[i-1] = {}
      for j in 0..(response[0].count-1)
        data[i-1][response[0][j]] = response[i][j]
      end
    end

    return HawkMain.median(redash_id,date,param_time_unit,time_column,value_column,time_unit,value_type,data)
  end

  def self.calculate_median_dimension(redash_id,date,param_time_unit,time_column,value_column,time_unit,value_type,dimension,dimension_column)
    url = 'https://redash.bukalapak.io/api/queries/'<<redash_id.to_s<<'/results.csv'
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)

    dimension_position = 0
    counter = 0
    for i in 1..(response.count-1)
      for j in 0..(response[0].count-1)
        if response[0][j] == dimension_column
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
          data[counter][response[0][j]] = response[i][j]
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

  def self.get_redash_result_id(query)
    url = 'https://redash.bukalapak.io/api/queries/'<<query.to_s
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)
    return response['latest_query_data_id']
  end

  def self.refresh(query)
    url = 'https://redash.bukalapak.io/api/queries/'<<query.to_s<<'/refresh'
    headers = {
     "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.post(url,:headers => headers)
    obj = response.parsed_response
    id_query = obj['job']['id']

    return get_result_id id_query
  end

  def self.get_dimension(redash_id,dimension_column)
    url = 'https://redash.bukalapak.io/api/queries/'<<redash_id.to_s<<'/results.csv'
    headers = {
      "Authorization"  => ENV["REDASH_KEY"]
    }
    response = HTTParty.get(url,:headers => headers)

    data = {}
    counter = 0
    for i in 1..(response.count-1)
      for j in 0..(response[0].count-1)
        if response[0][j] == dimension_column
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

end
