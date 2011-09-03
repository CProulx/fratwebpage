class WikiPagesController < ApplicationController
  before_filter :requires_login
  
  
  def index
    @wiki_pages = WikiPage.sorted_by_name
  end
  
  def new
    @wiki_page = WikiPage.new
  end
  
  def create
    @wiki_page = WikiPage.new(params[:wiki_page])
    @wiki_page.author = @current_member
   
    if @wiki_page.save
      flash[:notice] = 'Page was successfully Created.'
      redirect_to @wiki_page
    else
      @wiki_page.destroy
      render :action => "new"
    end
  end
  
  def edit
    @wiki_page = WikiPage.find(params[:id])
  end
  
  def update
    @wiki_page = WikiPage.find(params[:id])

    respond_to do |format|
      @wiki_page.last_edit_by = @current_member
      if @wiki_page.update_attributes(params[:wiki_page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(@wiki_page) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def show
    @wiki_page = WikiPage.find(params[:id])
  end
  
  def destroy
    @wiki_page = WikiPage.find(params[:id])
    @wiki_page.destroy
    redirect_to wiki_pages_path
  end
  
end
