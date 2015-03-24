
get '/categories' do
  redirect "/login" unless session[:user_id]
  @errors = []
  @categories = Category.all.order('name')
  erb :categories
end

get '/new_category' do  
  redirect "/login" unless session[:user_id]
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
        
        Log.new_entry "Category Added #{@category_name}"
        redirect "/categories"
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
        Log.new_entry "Category Saved #{@category_name}"
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
  redirect "/login" unless session[:user_id]

  @errors = []
  puts "/delete_category #{params}"
   if !params[:id].nil?
    begin

      @category = Category.find(params[:id])
      if @category
        #make sure no payments are associated with this category
        payments = Payment.where(category_id: @category.id)
        if payments.size > 0
          @on_complete_msg = "This category is associated with a payment and cannot be deleted #{@category_name}"
        else
          @category_name = @category.name
          Log.new_entry "Category Deleted #{@category_name}"
          @category.delete
          redirect "/categories"
        end
      else 
        @on_complete_msg =  "category not found id: #{params[:id]}"
      end

    rescue Exception => e
      puts "excpetion #{e.message}"
    end
  else
    @on_complete_msg =  "/delete_category params :id not found "
  end
  @on_complete_redirect=  "/categories"
  @on_complete_method=  "get"
  erb :done
end

post'/delete_category' do
  redirect "/login" unless session[:user_id]

  @errors = []
  puts "/delete_category #{params}"
   if !params[:id].nil?
    @category = Category.find(params[:id])
    if @category
      #make sure no payments are associated with this category
      payments = Payment.where(category_id: @category.id)
      if payments.size > 0
        @on_complete_msg = "This category is associated with a payment and cannot be deleted #{@category_name}"
      else
        @category_name = @category.name
        Log.new_entry "Category Deleted #{@category_name}"
        @category.delete
        redirect "/categories"
      end
    else 
      @on_complete_msg =  "category not found id: #{params[:id]}"
    end
  else
    @on_complete_msg =  "/delete_category params :id not found "
  end
  @on_complete_redirect=  "/categories"
  @on_complete_method=  "get"
  erb :done
end



get '/edit_category' do
  redirect "/login" unless session[:user_id]
  @errors = []
  @submit_callback = '/save_category'
  if !params[:id].nil?
    begin 
      @category = Category.find(params[:id])
      if @category
        erb
         :edit_category
      end   
      rescue Exception => e
        puts "excpetion #{e.message}"
      end
  end
end



