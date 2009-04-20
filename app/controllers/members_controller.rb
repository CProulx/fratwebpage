class MembersController < ApplicationController
  before_filter :requires_login, :except => [:index, :show]
  
  
  def index
    @members = Member.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @members }
    end
  end

  def show
    @member = Member.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member }
    end
  end

  def new
    @member = Member.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @members }
    end
  end

  def edit
    @member = Member.find(params[:id])
  end

  def create
    @member = Member.new(params[:member])

    respond_to do |format|
      if @member.save
        flash[:notice] = 'Member was successfully created.'
        format.html { redirect_to(@member) }
        format.xml  { render :xml => @member, :status => :created, :location => @member }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @member = Member.find(params[:id])

    respond_to do |format|
      if @member.update_attributes(params[:member])
        flash[:notice] = 'Member was successfully updated.'
        format.html { redirect_to(@member) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @member = Member.find(params[:id])
    @member.destroy

    respond_to do |format|
      format.html { redirect_to(members_url) }
      format.xml  { head :ok }
    end
  end
  
  def make_phi
    unless @current_member.is_phi?
      flash[:error] = "You must be phi to transfer the presidency"
      redirect_to :action => :index
      return
    end
    
    @member = Member.find(params[:id])
    @member.update_attribute(:is_phi,true)
    @current_member.update_attribute(:is_phi,false)
    flash[:notice] = "You have passes on the torch. Well done..."
    redirect_to :action => :index
  end
end
