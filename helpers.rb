Thread.abort_on_exception = true

def every(seconds)
  Thread.new do
    loop do
      sleep seconds
      yield
    end
  end
end

def render_state
  system 'clear'
  puts "usuario: @#{USER_NAME}@http://localhost:#{PORT}".green
  puts "# INBOX (#{$INBOX.count})"
  $INBOX.each do |activity|
    puts "#{activity.actor.id} => #{activity.object.content}".blue
  end
  puts '-' * 40

  puts "# OUTBOX (#{$OUTBOX.count})"
  $OUTBOX.each do |activity|
    puts "=> #{activity.object.content}".yellow
  end
  puts '-' * 40
end
