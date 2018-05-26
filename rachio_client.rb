require 'rest-client'
require 'json'

class RachioClient

	API_URI = 'https://api.rach.io/1/public'

	def initialize key
		@key = key
	end

	def on
		device_id = devices.first[:id]
		query(:put, '/device/on', { id: device_id }) == 204
	end

	def off
		device_id = devices.first[:id]
		query(:put, '/device/off', { id: device_id }) == 204
	end

	private

	def person
		resp = query(:get, '/person/info')
		id = resp["id"]

		query(:get, "/person/#{id}")
	end

	def devices
		person['devices'].collect { |d| { id: d['id'], name: d['name'] }}
	end

	def query verb, path, body = {}
		url = API_URI + path
		auth_header = { 'Authorization' => "Bearer #{@key}"}

		resp = case verb
		when :get
			RestClient.get(url, auth_header)
		when :put
			RestClient.put(url, body.to_json, auth_header)
		else
			raise "unsupported verb \"#{verb}\""
		end

		resp.body.empty? ? resp.code : JSON.parse(resp.body)
	end

end