# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

metrics_arr = Array.new

(1..5).each do |i|
	metrics_arr.push(Metric.create(redash_id: i, redash_title: 'test_'+ i.to_s, time_column: 'date',
		value_column: 'val', time_unit: 'weekly', value_type: 'absolute', email: 'example@lala.com',
		upper_threshold: 0.5, lower_threshold: 0.4))
end

(6..10).each do |i|
	metrics_arr.push(Metric.create(redash_id: i, redash_title: 'test_'+ i.to_s, time_column: 'date',
		value_column: 'val', time_unit: 'monthly', value_type: 'absolute', email: 'example@lala.com',
		upper_threshold: 0.5, lower_threshold: 0.4))
end

(1..50).each do |i|
	d = (i % 30) + 1
	id_random = rand(1...10)
	metric = Metric.where(redash_id: id_random).first
	Alert.create(value: i, is_upper: [true, false].sample, created_at: Time.new(2018, 4, d), metric: metric)
end

(1..50).each do |i|
	d = (1..30).step(2).to_a.sample
	id_random = rand(1...10)
	metric = Metric.where(redash_id: id_random).first
	Alert.create(value: i, is_upper: [true, false].sample, created_at: Time.new(2018, 4, d), metric: metric)
end

(1..40).each do |i|
	d = [1,7,14,28].sample
	id_random = rand(1...10)
	metric = Metric.where(redash_id: id_random).first
	Alert.create(value: i, is_upper: [true, false].sample, created_at: Time.new(2018, 4, d), metric: metric)
end

(1..30).each do |i|
	d = [2,8,15,29].sample
	id_random = rand(1...10)
	metric = Metric.where(redash_id: id_random).first
	Alert.create(value: i, is_upper: [true, false].sample, created_at: Time.new(2018, 4, d), metric: metric)
end

(1..20).each do |i|
	d = [5,10,20,30].sample
	id_random = rand(1...10)
	metric = Metric.where(redash_id: id_random).first
	Alert.create(value: i, is_upper: [true, false].sample, created_at: Time.new(2018, 4, d), metric: metric)
end