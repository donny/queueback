require 'sinatra/base'
require 'json'
require 'bunny'
require 'memcachier'
require 'dalli'

def get_queue(url)
    conn = Bunny.new(url)
    conn.start
    ch = conn.create_channel
    q = ch.queue('queue')
end

def get_rx_queue
    @rx_queue ||= settings.cache.fetch('rx_queue') do
        rx_queue = get_queue(ENV['RABBITMQ_BIGWIG_RX_URL'])
        settings.cache.set('rx_queue', rx_queue, 600)
        rx_queue
    end
end

def get_tx_queue
    @tx_queue ||= settings.cache.fetch('tx_queue') do
        tx_queue = get_queue(ENV['RABBITMQ_BIGWIG_TX_URL'])
        settings.cache.set('tx_queue', tx_queue, 600)
        tx_queue
    end
end

class QueueBack < Sinatra::Base
    set :cache, Dalli::Client.new

    get '/queue' do
        content_type :json

        delivery_info, metadata, payload = get_rx_queue.pop

        data = JSON.parse(payload)
        data = JSON.generate(data)

        return data
    end

    post '/queue' do
        content_type :json

        data = JSON.parse(request.body.read)
        data = JSON.generate(data)

        get_tx_queue.publish(data)

        return data
    end
end
