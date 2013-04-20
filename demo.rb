require 'tweetstream'

Twitter.configure do |config|
  config.consumer_key       = ENV.fetch("TWITTER_KEY")
  config.consumer_secret    = ENV.fetch("TWITTER_SECRET")
  config.oauth_token        = ENV.fetch("TWITTER_TOKEN")
  config.oauth_token_secret = ENV.fetch("TWITTER_TOKEN_SECRET")
end

TweetStream.configure do |config|
  config.consumer_key       = ENV.fetch("TWITTER_KEY")
  config.consumer_secret    = ENV.fetch("TWITTER_SECRET")
  config.oauth_token        = ENV.fetch("TWITTER_TOKEN")
  config.oauth_token_secret = ENV.fetch("TWITTER_TOKEN_SECRET")
  config.auth_method        = :oauth
end

friends = Twitter.friends(skip_status: true, include_user_entities: false).all
puts "friends: #{friends.map(&:screen_name)}"

me = Twitter.user
client = TweetStream::Client.new

client.on_timeline_status do |status|
  begin
    puts "timeline status from user: #{status.from_user.inspect}"

    if friends.map(&:screen_name).include?(status.from_user) && status.user_mentions.map(&:id).include?(me.id)
      puts "allowed to retweet: #{status.id.inspect}"

      Twitter.retweet!(status.id)
    end
  rescue Exception
    $stderr.puts "exception: #{$!.inspect}"
    raise
  end
end

client.userstream
