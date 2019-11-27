
def population(*args)
  100.times(&method(:puts))
end

def creation(*args)
  File.open('WinCr', 'wb') { |file| file.write('54321') }
end

population
