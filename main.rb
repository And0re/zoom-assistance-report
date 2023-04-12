require 'csv'

# Read data
total_classes = []
Dir.glob('participants_84010232745*.csv').each do |csv_file|
  total_classes += CSV.read(csv_file, headers: true).map(&:to_h)
end

# Clean data
total_classes.each do |hash|
  # key "Name (Original Name)" has an empty char at the beginning
  hash.transform_keys! { |key| key.chars.size == 21 ? 'Name' : key }
  hash.reject! { |key| ['User Email', 'Guest'].include? key }
end

# Create report
minutes_report = []
total_classes.each do |hash|
  hash_reporte = minutes_report.find { |student| student['name'] == hash['Name'] }

  if hash_reporte
    hash_reporte['minutes'] << hash['Total Duration (Minutes)'].to_i
  else
    student = { 'name' => hash['Name'], 'minutes' => [] }
    student['minutes'] << hash['Total Duration (Minutes)'].to_i
    minutes_report << student
  end
end

# Format report
final_report = minutes_report.map do |student|
  { 'name' => student['name'], 'hours' => (student['minutes'].sum / 60.0).round(1) }
end

sorted_report = final_report.sort_by { |hash| hash['name'] }

# Write report
CSV.open('report.csv', 'w') do |csv|
  csv << sorted_report.first.keys
  sorted_report.each do |hash|
    csv << hash.values
  end
end
