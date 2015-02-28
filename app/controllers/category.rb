
get '/categories' do
  @errors = []
  @categories = Category.all.order('name')
  erb :categories
end

get '/new_category' do
  @errors = []
  @submit_callback = "/save_new_category"
  erb :add_category
end

post '/save_new_category' do
  puts "/save_new_category"
  puts "#{params}"
  if params[:commit] == 'Submit'
    @category_name = params[:name]
    @category = Category.find_by_name(@category_name)
    if @category.nil?
      @category = Category.new
      @category.name = @category_name
      puts "/save_new_category #{@category.name}"
      retval = @category.save
      if retval
        puts "retval from save:  #{retval}"
        puts "category #{@category.name} added"
        @on_complete_msg = "Category #{@category_name} has been added."
        @on_complete_redirect=  "/categories"
        @on_complete_method=  "get"
        erb :done
      else
        puts "Add Category returned and error and was not saved"
        @on_complete_msg = "Add Category returned and error and was not saved"
      end
  else
      puts "Category already exists #{@category.name}"
      @on_complete_msg = "Category already exists #{@category.name}"
    end
  end
  @on_complete_redirect=  "/categories"
  @on_complete_method=  "get"
  erb :done
end

post '/save_category' do
  if params[:commit] == 'Submit'
    @category_id = params[:id]
    puts "@category_id #{@category_id}"
    @category = Category.find(@category_id)
    if !@category.nil?
      @category_name = params[:name]
      @category.name = @category_name
      retval = @category.save
      if retval
        redirect "/categories"
      else
        puts "Save Category returned and error and was not saved"
        @on_complete_msg = "Save Category returned and error and was not saved"
      end
  else
      puts "Category id does not exist #{@category.id}"
      @on_complete_msg = "Category id does not exist #{@category.id} and could not be saved"
    end
  end
  @on_complete_redirect=  "/categories"
  @on_complete_method=  "get"
  erb :done
end

get '/delete_category' do

  @errors = []
  puts "/save_category #{params}"
   if !params[:id].nil?
    @category = Category.find(params[:id])
    if @category
      @category_name = @category.name
      @category.delete
    else 
      puts "category not found id: #{params[:id]}"
    end
    puts "delete category"
    @on_complete_msg = "Category #{@category_name} has been removed."
    @on_complete_redirect=  "/categories"
    @on_complete_method=  "get"
    erb :done
  else
    puts "/delete_category params :id not found "
    @errors << "Category Not Found"
    erb :categories
  end
end



get '/edit_category' do
  @errors = []
  @submit_callback = '/save_category'
  if !params[:id].nil?
    @category = Category.find(params[:id])
    if @category
      erb :edit_category
    end
  end
end



