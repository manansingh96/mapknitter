class WarperController < ApplicationController

  protect_from_forgery :except => [:update,:delete]  

  def new
    @map_id = params[:id]
  end

  def create
    @warpable = Warpable.new(params[:warpable])
    @warpable.map_id = params[:map_id]
    map = Map.find(params[:map_id])
    map.updated_at = Time.now
    if @warpable.save
      redirect_to :action => 'uploaded_confirmation',:id => @warpable.id
    else
      render :action => :new
    end
  end

  def uploaded_confirmation
    @warpable = Warpable.find params[:id]
  end
  
  def show
    @image = Warpable.find params[:id]
  end
  
  def list
    @warpables = Warpable.find :all, :conditions => ['parent_id is NULL AND deleted = false']
  end
  
  def update
    @warpable = Warpable.find params[:warpable_id]
    
    nodes = []
    author = Map.find @warpable.map_id

    params[:points].split(':').each do |point|
      lon = point.split(',')[0], lat = point.split(',')[1]
	node = Node.new({:color => 'black',
                :lat => lat,
                :lon => lon,
                :author => author,
                :name => ''
      })
      node.save
      nodes << node
    end

    node_ids = []
    nodes.each do |node|
      node_ids << node.id
    end
    @warpable.nodes = node_ids.join(',')
    @warpable.locked = params[:locked]    
    @warpable.save
    render :text => 'success'
  end
  
  def delete
    image = Warpable.find params[:id]
    image.deleted = true
    image.save
    render :text => 'successfully deleted '+params[:id]
  end
  
end
