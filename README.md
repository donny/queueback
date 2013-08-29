queueback
=========

A thin Sinatra wrapper of RabbitMQ running on Heroku. It's created as a quick and dirty data pipe between iOS apps for a prototype.

Don't forget to add the addons:

    $ heroku addons:add memcachier
    $ heroku addons:add rabbitmq-bigwig
