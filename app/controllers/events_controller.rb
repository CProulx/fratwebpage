class EventsController < ApplicationController
  before_filter :requires_login, :except => [:index, :show]
  
  # GET /members
  # GET /members.xml
  def index
    @selected_date = (params[:year] and params[:month] and params[:day]) ? Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i) : false
    @events = @selected_date ? Event.find_all_by_date(@selected_date) :  Event.find(:all, :conditions => ["events.when > ?", (Time.now - 60.days).to_date])
    @events_by_month = @events.group_by{|e| e.when.month}

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end
  
  def new
    @event = Event.new
  end
  
  # POST /members
  # POST /members.xml
  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(@event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @event = Event.find(params[:id])
  end
  
  def edit
    @event = Event.find(params[:id])
  end
  
  def update
    @event = Event.find(params[:id])
    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(@event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
    
  end

  def destroy
    debugger
    puts "\nvllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll\n"
    @event = Event.find(params[:id])
    respond_to do |format|
      if @event.destroy
        format.html { redirect_to(events_url) }
        format.xml  { head :ok }
        format.js {
            render :update do |page|
              page["event_#{params[:id]}"].remove
            end
          }
      else
          format.html { render :action => "index" }
          format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end
