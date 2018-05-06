# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

metrics_arr = Array.new

(1..10).each do |i|
	metrics_arr.push(Metric.create(redash_id: i, redash_title: 'test_'+ i.to_s, time_column: 'date',
		value_column: 'val', time_unit: 'daily', value_type: 'absolute', email: 'example@lala.com',
		upper_threshold: 0.5, lower_threshold: 0.4))
end

print metrics_arr[0]

(1..100).each do |i|
	j = i % 10
	print j
	Alert.create(value: i, is_upper: true, metric: metrics_arr[j])
end