Rails.application.routes.draw do
  get 'positions/:str' => 'positions#show', str: /[0-9a]{12}[0-2]{3}[0-1]/
  post 'positions/best'
  
  root :to => 'positions#show', :str => '4260800705130000'

  get '*path', to: 'application#routing_error'
end
