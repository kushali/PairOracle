require 'pp'

name_file_path = ARGV[0]
history_file_path = ARGV[1]

# Returns an array of pairing arrays
def generate_pairs(names)
  return [[names]] if names.length < 3

  pairs = []
  names.combination(2).each do |pair|
    others = generate_pairs(names - pair)
    others.each do |rest|
      pairs << ([pair] + rest)
    end
  end
  return pairs
end

def score_pairs(pairs, history)
  scored_pairs = []
  pairs.each do |pairing|
    score = pairing.map { |p| history[p.join] }.inject(&:+)
    scored_pairs << [score, pairing]
  end

  scored_pairs.sort { |a, b| a[0] <=> b[0] }
end

# Read in all the names from the file
names = File.readlines(name_file_path).map(&:strip).sort

# Read in the history file
history = Hash.new(0)
File.open(history_file_path).each do |line|
  next unless line.strip!
  history[line] += 1
end

possible_pairs = generate_pairs(names)
scored_pairs = score_pairs(possible_pairs, history)

# Suggest pairs  for approval

i = -1
response = nil
while response != 'y' do
  i += 1
  puts "Suggested pairing"
  pp scored_pairs[i][1]
  puts "Accept? Y/N"
  response = $stdin.gets.strip.downcase
end

# Write the history to the history file
File.open(history_file_path, 'a') do |f|
  scored_pairs[i][1].each do |pair|
    f.puts pair.join
  end
end
