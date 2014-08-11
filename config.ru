# This file is used by Rack-based servers to start the application.
require 'p3p'
use P3P::Middleware

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
