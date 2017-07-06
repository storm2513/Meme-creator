# Initializing DB
class Database
  def initialize(id)
    user = User.new(id)
    # @redis = Redis.new(host: "127.0.0.1", port: 6379)
    @redis = Redis.new(url: ENV["REDIS_URL"])
    hash = get_std_hash(user)
    @redis.set(user.id, hash.to_json)
    @redis
  end

  def get_std_hash(user)
    hash = if !@redis.get(user.id).nil?
             JSON.parse(@redis.get(user.id)).to_hash
           else {}
           end
  end

  def get_hash(id)
    hash = JSON.parse(@redis.get(id)).to_hash
    hash
  end

  def set_hash(hash, id)
    @redis.set(id, hash.to_json)
  end

  attr_accessor :redis
end
