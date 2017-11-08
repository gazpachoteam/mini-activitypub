Thread.abort_on_exception = true

def every(seconds)
  Thread.new do
    loop do
      sleep seconds
      yield
    end
  end
end

def render_state(actor, inbox, outbox)
  system 'clear'
  puts "usuario: #{actor.id}".green
  puts "# INBOX (#{inbox.count})"
  inbox.each do |activity|
    puts "#{activity.actor.id} says: #{activity.object.content}".blue
  end
  puts '-' * 40

  puts "# OUTBOX (#{outbox.count})"
  outbox.each do |activity|
    puts "#{activity.object.content}".yellow
  end
  puts '-' * 40
end
