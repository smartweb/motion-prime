class ApiClient
  attr_accessor :access_token

  def initialize(options = {})
    self.access_token = options[:access_token]
  end

  def parse_json(text)
    BW::JSON.parse(text)
  rescue
    puts "Can't parse json: #{text}"
    false
  end

  def request_params(data)
    params = {payload: data}
    if MP::Config.api.http_auth.present?
      params.merge!(credentials: MP::Config.api.http_auth.to_hash)
    end
    params
  end

  def authenticate(username, password, &block)
    data = {
      grant_type: "password",
      username: username,
      password: password,
      client_id: MP::Config.api.client_id,
      client_secret: MP::Config.api.client_secret
    }
    use_callback = block_given?
    BW::HTTP.post("#{MP::Config.api.base}/oauth/token", request_params(data)) do |response|
      access_token = if response.ok?
        json = parse_json(response.body)
        json[:access_token]
      else
        false
      end
      self.access_token = access_token
      block.call(access_token) if use_callback
    end
    true
  end

  def api_url(path)
    return path if path =~ /^http(s)?:\/\//
    "#{MP::Config.api.base}/api/v1#{path}"
  end

  def resource_url(path)
    "#{MP::Config.api.base}#{path}"
  end

  def request(method, path, params = {}, &block)
    params.merge!(access_token: access_token)
    BW::HTTP.send method, api_url(path), request_params(params) do |response|
      json = parse_json(response.body.to_s)
      block.call(json, response.status_code)
    end
  end

  def get(path, params = {}, &block)
    request(:get, path, params, &block)
  end

  def put(path, params = {}, &block)
    request(:put, path, params, &block)
  end

  def post(path, params = {}, &block)
    request(:post, path, params, &block)
  end

  def delete(path, params = {}, &block)
    request(:delete, path, params, &block)
  end
end