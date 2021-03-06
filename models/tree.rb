require 'sequel'

class Tree
  public
  attr_reader :root_dir #<Fileinfo>
  attr_reader :dl_queue #<Download Queue>

  # Specify someone's file system
  # How to recover the whole tree from the sql table?
  def initialize(uid)
    @dl_queue = Queue.new
    fList = []
    ftable = Account[uid].fileinfos
    ftable.each do |file|
      fList[file.id] = file
    end
    ftable.each do |file|
      if file.parent_id == file.id
        @root_dir = file
      else
        fList[file.parent_id].add_file(file)
      end
    end
    if ftable.empty?
      @root_dir = CreateFileinfo.call(name: 'ROOT', account_id: uid, portion: 0)
      @root_dir.parent_id = @root_dir.id
      @root_dir.save
      # fList[@root_dir.id] = @root_dir
    end
  end

  # def find_file_by_path(folder, path, portion)
  #   list = path.split(/[\\\/]/)
  #   list.select! { |unit| !unit.empty? } # This line is very important !!
  #   find_file_by_unit(folder, list, portion)
  # end

  # Find the file/folder from the root directory.
  # The input argument pathUnits can be of String type or of Array type.
  def find_file(pathUnits, portion=0)
    pathUnits = SplitPath.call(pathUnits) if pathUnits.instance_of? String
    portion = Integer(portion) if portion.instance_of? String
    raise 'The path must be nonempty.' unless pathUnits.size > 0
    dir = @root_dir
    pathUnits.each_with_index do |fname, index|
      if dir != nil
        if (index<pathUnits.size-1) || (portion==0)
          dir = dir.find_file(fname) # folder
        else
          dir = dir.find_file(fname, portion) # file
        end
      end
    end
    return dir
  end

  # Note that everyone can only access Fileinfo database through this interface.
  # Otherwise the files in our tree may not be synced with those in the database.
  # This concept is very important and may cause lots of bugs if we are careless!!
  def get_file_instance(id)
    raise 'The primary key must be an integer.' unless id.instance_of? Integer
    name_list = []
    while true
      file = Fileinfo[id] 
      break if id == file.parent_id
      name_list.push(file.name)
      id = file.parent_id
    end
    find_file(name_list.reverse, 1)
  end
end
