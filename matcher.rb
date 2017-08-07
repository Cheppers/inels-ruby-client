file = File.read('rage.txt')
file.each_line do |line|
  match = line.match(/^(.+)\(\) (.*)/)
  if match
    puts %Q<"#{match[1]}": "#{match[2]}",>
  end
end