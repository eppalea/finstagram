helpers do  
    def current_user
        User.find_by(id: session[:user_id])
    end

    def logged_in?
    !!current_user
  end
end

# homepage (index)
get '/' do
    @finstagram_posts = FinstagramPost.order(created_at: :desc)
    erb(:index)
end

# signup form
get '/signup' do
    @user = User.new
    erb(:signup)
end

# sign up a new user
post '/signup' do
    
    email = params[:email]
    avatar_url = params[:avatar_url]
    username = params[:username]
    password = params[:password]

    @user = User.new({ email: email, avatar_url: avatar_url, username: username, password: password})
        
    if @user.save
        redirect to('/login')
    
    else
        erb(:signup)
    end
end

# login form
get '/login' do   # when a GET request comes into /login
    erb(:login)   # render app/views/login.erb
end

# login a user
post '/login' do  
    username = params[:username]
    password = params[:password]

    user = User.find_by(username: username)

    if user && user.password == password
        session[:user_id] = user.id
        redirect to('/')
    else
        @error_message = "Login failed"
        erb(:login)
    end
end

get '/logout' do
    session[:user_id] = nil
    redirect to('/')
end

# create new post
post '/finstagram_posts' do
  photo_url = params[:photo_url]
  @finstagram_post = FinstagramPost.new({ photo_url: photo_url, user_id: current_user.id })
  if @finstagram_post.save
    redirect(to('/'))
  else
    erb(:"finstagram_posts/new")
  end
end
before '/finstagram_posts/new' do
  redirect to('/login') unless logged_in?
end


# form to create new post
get '/finstagram_posts/new' do
  @finstagram_post = FinstagramPost.new
  erb(:"finstagram_posts/new")
end


# show a single post
get '/finstagram_posts/:id' do
  @finstagram_post = FinstagramPost.find(params[:id])
  erb(:"finstagram_posts/show")
end

post '/comments' do
    # point values from params to variables
  text = params[:text]
  finstagram_post_id = params[:finstagram_post_id]

  # instantiate a comment with those values & assign the comment to the `current_user`
  comment = Comment.new({ text: text, finstagram_post_id: finstagram_post_id, user_id: current_user.id })

  # save the comment
  comment.save

  # `redirect` back to wherever we came from
  redirect(back)
end

post '/likes' do
    
  finstagram_post_id = params[:finstagram_post_id]


  like = Like.new({ finstagram_post_id: finstagram_post_id, user_id: current_user.id })


  # save the like
  like.save

  # `redirect` back to wherever we came from
  redirect(back)
end

delete '/likes/:id' do
  like = Like.find(params[:id])
  like.destroy
  redirect(back)
end